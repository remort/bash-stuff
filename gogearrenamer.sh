#!/bin/bash

function setDirs(){
	if [ -z "$1" ];then 
	  echo -e "You have to set your music album first !\nUsage: $0 <Path to music album dir to copy> <Path to music dir on your Gogear device>"
	  exit
	else
	  cd "$1" 2>/dev/null
	  if [ $? -eq 0 ] ; then
	    sourceDir="$(pwd)/"
	  else
	    echo 'Can not cd to mentioned music album dir. Try to set a full patht to a dir'
	    exit
	  fi
	fi
	
	if [ -z "$2" ];then 
	  echo -e "You have to set your gogear music dir too !\nUsage: $0 <Path to music album dir to copy> <Path to music dir on your Gogear device>"
	  exit
	else
	  cd "$2" 2>/dev/null
	  if [ $? -eq 0 ]; then
	    targetDir="$(pwd)/"
	  else
	    echo 'Can not cd to mentioned gogear music dir. Try to set a full patht to a dir'
	    exit
	  fi
	fi
}

function getAvailPrefix(){
	prefs='ABCDEFGHIJKLMNOPRSTUVWXYZ'
	bookedPrefs=()
	cd "$targetDir"
	for f in ./*; do  
	  curPref=${f%% *}
	  curPref=$(echo "$curPref" | tr -d './')
	  prefs=$(echo "$prefs" | tr -d "$curPref")
	done
	echo "pr - ${prefs:0:1}"
	echo "${prefs:0:1}" > "$tempfile"
}

function getTransportList(){
	prefix=$(cat "$tempfile")
	echo "prefix is : $prefix"
	tracknum=0
	mask=000
	tracks=()

	cd "$sourceDir"
	for src in ./*; do

	  [[ "$src" != ./*mp3 && "$src" != ./*flac ]] && continue

	  tracknum=$(($tracknum+1))
	  mod=$((${#mask}-${#tr}))
	  srcBase=$(basename "$src")
	  dst=$(echo "$targetDir""$prefix"-${mask:${#mod}}$tracknum-"$srcBase" | tr ' ' '_' | tr '|' '-')
	  paths="$paths"'|'"$src $dst"
      
    done
    
    echo -e "These are the resulted paths. It shows which files will be copied to under what names. :"
    echo "$paths" | tr '|' '\n'
    echo -e "Do you like your tracks to be moved to \n$targetDir under these names?\nID3v1 tags will be cut off on copied files.\nPlease answer [y/n]"
    while :; do
      read -sn1 answer
      case "$answer" in
        [Yy]) echo "$paths" > "$tempfile";return 0;;
        [Nn]) exit;;
        *) echo "Please answer 'y' to continue, 'n' to quit"; continue
      esac
    done
}

function moveFiles(){
	cd "$sourceDir"
	IFS='|'  
	for path in $(cat "$tempfile" );do
	  [ -z "$path" ] && continue
	  cp -v "${path% *}" "${path##* }" && \
	  id3v2 -s "${path##* }"
	done
	echo "Files were copied. Copies were cropeed for ID3v1 tags."
}


  setDirs "$1" "$2"
  tempfile=$(mktemp)
  getAvailPrefix
  getTransportList
  moveFiles

