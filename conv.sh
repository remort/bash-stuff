#!/bin/bash -x

function translit ()
{
name=`echo $1 | tr '[:upper:]' '[:lower:]'`
name=`echo $name | sed -e 's/а/a/g; s/б/b/g; s/в/v/g ;s/г/g/g; s/д/d/g; s/е/e/g; s/ж/zh/g; s/з/z/g; s/и/i/g; s/й/i/g; s/к/k/g; s/л/l/g; s/м/m/g; s/н/n/g; s/о/o/g; s/п/p/g; s/р/r/g; s/с/s/g; s/т/t/g; s/у/u/g; s/ф/f/g; s/х/h/g; s/ц/ts/g; s/ч/ch/g; s/ш/sh/g; s/щ/sch/g; s/ъ/"/g; s/ь//g; s/ы/i/g; s/э/e/g; s/ю/yu/g; s/я/ya/g'`
}

translit трололо
echo $name
#TRS=`echo $NAME | tr абвгдезийклмнопрстуфхцы abvgdezijklmnoprstufxcy` TRS=`echo $TRS | tr АБВГДЕЗИЙКЛМНОПРСТУФХЦЫ ABVGDEZIJKLMNOPRSTUFXCY` TRS=${TRS//ч/ch}; TRS=${TRS//Ч/CH} TRS=${TRS//ш/sh}; TRS=${TRS//Ш/SH} TRS=${TRS//ё/jo}; TRS=${TRS//Ё/JO} TRS=${TRS//ж/zh}; TRS=${TRS//Ж/ZH} TRS=${TRS//щ/sh\'}; TRS=${TRS//Щ/SH\'} TRS=${TRS//э/je}; TRS=${TRS//Э/JE} TRS=${TRS//ю/ju}; TRS=${TRS//Ю/JU} TRS=${TRS//я/ja}; TRS=${TRS//Я/JA} TRS=${TRS//ъ/\`}; TRS=${TRS//ъ\`} TRS=${TRS//ь/\'}; TRS=${TRS//Ь/\'}