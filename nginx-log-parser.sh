#!/bin/bash

# Находит в логах nginx строки вида:
# [30/Nov/2000:07:09:16 +0000] "POST /auth HTTP/2.0" 200 44 "https://domain.example/login?next=/videos/category/0/subcategory/4/video/27&code=65f57a1bde534ac82f69" "-"
# считает кол-во уникальных ссылок, удаляя часть с code=*
cat /path/to/logs/*.log | fgrep '"POST /auth HTTP/2.0" 200' | cut -d' ' -f 11 | sed -E -e 's/^"https:\/\/domain.example\///' | sed -e 's/[&?]code=.*$//' | sort | uniq -c | sort -k1 -n -r

# Делает то же самое добавляя третьим столбцом ID сщности video или books из строки.
cat /path/to/logs/*.log | fgrep '"POST /auth HTTP/2.0" 200' | cut -d' ' -f 11 | sed -E -e 's/^"https:\/\/domain.example\///' | sed -e 's/[&?]code=.*$//' | sed -e 's/\/$//'| awk -F '/' -v vsrch="video" -v bsrch="books" '{for(i=1;i<=NF;i++){if(match(vsrch,$i)){val=$(i+1)}else if(match(bsrch,$i)){val=$(i+1)}}print $0" "val}'| sort | uniq -c | sort -k1 -n -r
