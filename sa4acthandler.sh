#!/bin/bash

# This script copies your mp3,flac,ogg albums to sa4act player and 
# strips tags so it could be played by GoGear device then. Also script 
# deletes TDBSTR.DAT and STDBDATA.DAT files from player every time.
#
# DONE:
# - Prepare the GoGear player and the script before use in next steps
# 1.Delete (and backup) all files from your GoGear sa4act player and
# create a music dir in the device's root.
# 2. Install 'id3v2', 'metaflac' and 'vorbiscomment' tools to let the
# script handle mp3,flac and ogg files accordingly.
# 3.Comment out an appropriate 'exit' line under 'checkTools()' function
# in this script for every tool that you won't use.
# 4. Run a script with a music album dir path as a first argument and a
# a player's music dir path as a second argument and see what happens ))
# Or Run script without arguments to see the arguments list.
#
# TODO:
# - Handle several music albums at one time in a loop
# - Recognize more audio files that GoGear plays and handle them right
# - Double check the real track order. According filenames (how it works
# now) and a track number tag in audio metadata (to be completely sure)
#
# Mail me at master@remort.net if you have some questions.

function checkTools(){
	if [ ! `which id3v2` ];then
	  echo "id3v2 not found. Install it first."
	  exit
	fi

	if [ ! `which vorbiscomment` ];then
	  echo "Vorbiscomment not found. Install it first."
	  exit
	fi

	if [ ! `which metaflac` ];then
	  echo "Metaflac not found. Install it first."
	  exit
	fi
}

function setDirs(){
	if [ -z "$1" ];then 
	  echo -e "You have to set your music album first !\nUsage: $0 <Path to music album dir to copy> <Path to music dir on your Gogear device>"
	  exit
	else
	  cd "$1" 2>/dev/null
	  if [ $? -eq 0 ] ; then
	    sourceDir="$(pwd)/"
	  else
	    echo "Can not cd to mentioned music album dir ($1). Try to set a full patht to a dir"
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
	    echo "Can not cd to mentioned gogear music dir ($2). Try to set a full patht to a dir"
	    exit
	  fi
	fi
}

function getAvailPrefix(){
	prefs='ABCDEFGHIJKLMNOPRSTUVWXYZ'
	bookedPrefs=()
	cd "$targetDir"
	for f in *; do  
	[[ "$f" != *mp3 && "$f" != *flac && "$f" != *ogg ]] && continue
	  curPref=${f:0:1}
	  prefs=$(echo "$prefs" | tr -d "$curPref")
	done
	echo "${prefs:0:1}" > "$tempfile"
}

function getTransportList(){
	prefix=$(cat "$tempfile")
	echo "Available prefix is : $prefix"
	tracknum=0

	cd "$sourceDir"
	for src in *; do
	  [[ "$src" != *mp3 && "$src" != *flac && "$src" != *ogg ]] && continue
	  tracknum=$(($tracknum+1))
	  [ ${#tracknum} -eq 1 ] && number=0${tracknum} || number=$tracknum
	  dst=$(echo "$targetDir""$prefix"-$number-"$src" | tr ' ' '_' | tr '|' '-')
	  paths="$paths"'|'"$src $dst"
    done
    
    echo "These are resulted paths. It shows which files will be copied to under what names :"
    echo "$paths" | tr '|' '\n'
    echo -e "\nDo you like your tracks to be moved to \n$targetDir under these names?\nAudio metadata will be cut off on copied files.\nPlease answer [y/n]"
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
	  cp -v "${path% *}" "${path##* }"
	  if [ "$?" ]; then

	    if [[ "${path##* }" = *mp3 ]]; then
	      echo "cleaning mp3 file"
	      id3v2 -D "${path##* }"
	    fi

	    if [[ "${path##* }" = *flac ]]; then
	      echo "cleaning flac file"
	      id3v2 -D "${path##* }"
	      metaflac --remove-all-tags "${path##* }" && \
	        echo "Flac audio metadata stripped"
	    fi

	    if [[ "${path##* }" = *ogg ]]; then
	      vorbiscomment -w -c /dev/null "${path##* }" && \
	        echo "Vorbiscomment metadata stripped"
	    fi

	  else
	    echo "Error copying file ${path% *} to ${path##* }"
	  fi
	done
	echo -e "\nFiles were copied. Copies were cropeed for audio metadata."
}

function delSysfiles(){
	[ -f "${targetDir}../STDBSTR.DAT" ] && rm -f "${targetDir}../STDBSTR.DAT" #main
	[ -f "${targetDir}../STDBDATA.DAT" ] && rm -f "${targetDir}../STDBDATA.DAT"
	sync
}

  checkTools
  setDirs "$1" "$2"
 
  tempfile=$(mktemp)
 
  getAvailPrefix
  getTransportList
  moveFiles
  delSysfiles
