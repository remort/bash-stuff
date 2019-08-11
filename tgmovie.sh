#!/bin/bash

set -u -e

FILE=$1
FILENAME=${FILE%.*}

ffmpeg -i ${FILE} -vf "scale=iw/2:ih/2" -c:v libx264 -preset slow -b:v 500k -c:a aac -b:a 128k "${FILENAME}.mp4"
