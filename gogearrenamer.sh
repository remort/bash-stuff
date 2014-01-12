#!/bin/bash

gogeardir="/home/remort/STORAGE/gogeartest/"

cd "$gogeardir"

for dir in */; do
  cd "$dir"

  echo "In dir - $dir"

  for f in ./*; do
    if [[ "$f" == ./*mp3 ]]; then
      prefix=`id3v2 -l "$f" | egrep "(Soloist*)|(Artist*:)" -m1 | awk -F: '{print $NF}' | tr -d ' '`
      #prefix=`echo ${artist##*:}`
    elif [[ "$f" == ./*flac ]];then
      prefix=`strings "$f" | head -n5 | fgrep artist= | awk -F= '{print $2}' | tr -d ' '`
    fi
    [[ -n "$prefix" ]] && break
  done

  [[ -z "$prefix" ]] && prefix="$$"
  echo "Current prefix is : $prefix"

  for f in ./* ;do
    if [[ "$f" == ./*mp3 || "$f" == ./*flac ]]; then
       echo "Move $f to ../$prefix$fname ..."
       fname=`echo ${f##*/}| tr -d ' '`
       mv "$f" "../$prefix$fname" || echo "...failed to move"
    else
       rm "$f"
    fi
  done

  cd ..

  dirsize=`du -s -BK "$dir" | cut -f 1 | tr -d 'K'`
  if [[ "$dirsize" -lt "2500" ]]; then
    echo "All done here. Delete the dir ($dir) , clean the prefix ($prefix)"
    rm -rf "$dir"
  else
    echo "All done here. But the dir ($dir) seems to be still filled with useful files. Will not delete it. The prefix ($prefix) is cleaned."
  fi

  prefix=''

done
