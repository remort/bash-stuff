#!/bin/bash

filename='secrets'

function readsecrets(){
  cat ~/Dropbox/$filename | base64 -d | openssl des3 -d
}

function decryptsecrets(){
  cat ~/Dropbox/$filename | base64 -d | openssl des3 -d -out ~/Dropbox/$filename.txt
}

function encryptsecrets(){
  cat ~/Dropbox/$filename.txt | openssl des3 | base64 > ~/Dropbox/$filename.$$
  cp $filename.$$ $filename
  rm ~/Dropbox/$filename.txt
}

function readwords(){
  str=$1
  service=$2
  r=0
  keys[0]='service'
  keys[1]='login'
  keys[2]='password'
  keys[3]='codeword'
  keys[4]='add info'
  while read record; do
    if [ $r -eq 0 ]; then
      [[ -n $(echo "$record" | grep -E "$service" -o) ]] && echo "${keys[$r]} : $record" || return 1
    else
      echo "${keys[$r]} : $record"
    fi
    let r++
  done < <( echo "$str" | tr ';' '\n' )
  return 0
}

function getsecrets(){
  [[ $# -lt 1 ]] && echo 'Usage: getsecrets <key>' && return 0
  srv=$1
  i=0
  while read str; do
    if readwords "$str" "$srv"; then
      let i++
    fi
  done < <(readsecrets)
  [ $i -eq 0 ] && echo "Ничего не найдено"
}