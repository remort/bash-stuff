#!/bin/bash
if [ "$#" != "1" ]; then
    echo -e "Использование: scan.sh [ 1 | 2 | 3 ]\nГде '1' значит Низкое качество, '2' - Среднее и '3' Лучшее качество изображения"
else
DATESTAMP="$(date +%T-%d_%B_%Y)"
    case $1 in
    1)
	echo 100
	scanimage -d hpaio:/net/HP_LaserJet_3055?ip=10.80.1.11 --format=pnm --compression JPEG --resolution 100 -x 220 -y 300 > /tmp/scanimage.pnm
	convert /tmp/scanimage.pnm /home/tremor/Ideco_$DATESTAMP.jpeg
    ;;
    2)
	echo 200
	scanimage -d hpaio:/net/HP_LaserJet_3055?ip=10.80.1.11 --format=pnm --compression JPEG --resolution 200 -x 220 -y 300 > /tmp/scanimage.pnm
	convert /tmp/scanimage.pnm /home/edward/Ideco_$datestamp.jpeg
    ;;
    3)
	echo 300
	scanimage -d hpaio:/net/HP_LaserJet_3055?ip=10.80.1.11 --format=pnm --compression JPEG --resolution 300 -x 220 -y 300 > /tmp/scanimage.pnm
	convert /tmp/scanimage.pnm /home/edward/Ideco_$datestamp.jpeg
    ;;

    *)
	echo $FILENAME
    ;;
    esac
fi