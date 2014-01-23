#!/bin/bash
. /etc/ics/ics.conf

bold=`tput bold`
normal=`tput sgr0`
red='\e[1;31m'
reset='\e[0m'

USERS=` echo -e "connect $DB_SERVER:$DB_NAME user $ISC_USER password $ISC_PASSWORD;set list on;\n select count(id) from users where id < 100000 and END_USER=1 and DELETED!=1;\n" | isql 2>/dev/null | iconv -f cp1251 -t utf8 | grep [0-9]* -o`
AUTHORIZED=`iptables -t nat -vnL | fgrep SNAT | wc -l`
#REG=`echo -e "connect $DB_SERVER:$DB_NAME user $ISC_USER password $ISC_PASSWORD;set list on;\n select REG_CODE, ACT_CODE, HWID from REG;\n" | isql 2>/dev/null | iconv -f cp1251 -t utf8 | awk '{print$2 }' |  tr -d '\n'`
REG=`echo -e "connect $DB_SERVER:$DB_NAME user $ISC_USER password $ISC_PASSWORD;set list on;\n select REG_CODE, ACT_CODE, HWID from REG;\n" | isql 2>/dev/null | iconv -f cp1251 -t utf8 | awk '{print$2" "}' |  tr -d '\n'`
REGCODE=`echo $REG|cut -f1 -d' '`
ACTCODE=`echo $REG|cut -f2 -d' '`
HWID=`echo $REG|cut -f3 -d' '`
STATE=`cat /var/lib/system.state`
VER=`cat /etc/version`
#HOSTNAME=`hostname`
WEBADMINPASS=` echo -e "set list on;\nselect uf_decrypt_pw(psw, 1979, 1234-(EXTRACT (MINUTE FROM current_time) / 10) *77) from users where id=2;\n" | isql 127.0.0.1:/var/db/ics_main.gdb -u SYSDBA -p $ISC_PASSWORD | grep -v "Database|SQL|=====|^$" | iconv -f cp1251 -t UTF8 | tr -d '\n' | awk '{print$2}'`
WEBADMINLOGIN=` echo -e "set list on;\nselect login from users where id=2;\n" | isql 127.0.0.1:/var/db/ics_main.gdb -u SYSDBA -p $ISC_PASSWORD | grep -v "Database|SQL|=====|^$" | iconv -f cp1251 -t koi8-r | tr -d '\n' | awk '{print$2}'`
EXTERNALIP=`echo $SSH_CONNECTION | cut -f3 -d' '`
ICSGENERATION=`echo ${VER:0:1}`

echo -e "\n${red}===== `hostname` statistics =====${reset}"
echo "Users\Autorized : $USERS \ $AUTHORIZED"
echo "Version\State : $VER \ $STATE"
echo "RW: Capacity ${bold}`df -h /mnt/rw_disc/ | tail -n 1 | awk '{print$2}'`${normal} , Used ${bold}`df -h /mnt/rw_disc/ | tail -n 1 | awk '{print$3}'`${normal}, Free ${bold}`df -h /mnt/rw_disc/ | tail -n 1 | awk '{print$4"("$5")"}'`${normal}"
echo "REG/ACT/HWID : $REGCODE / $ACTCODE / $HWID"

if [[ "$ICSGENERATION" == '4' ]]; then
    iptables -t nat -I PREROUTING -s ${SSH_CONNECTION%% *} -p tcp --dport 443 -j DNAT --to-dest 10.128.0.0:443; iptables -I INPUT -s ${SSH_CONNECTION%% *} -j ACCEPT; iptables -I OUTPUT -d ${SSH_CONNECTION%% *} -j ACCEPT
elif [[ "$ICSGENERATION" == '5' ]]; then
     iptables -t nat -I PREROUTING -s ${SSH_CONNECTION%% *} -p tcp --dport 443 -j DNAT --to-dest ${APACHE_L_CERT%%|*}; iptables -I INPUT -s ${SSH_CONNECTION%% *} -j ACCEPT; iptables -I OUTPUT -d ${SSH_CONNECTION%% *} -j ACCEPT
fi
[ "$?" ] && echo -e "\nConnect URI :\n https://$EXTERNALIP \n Login: ${bold}$WEBADMINLOGIN${normal} , Password : ${bold}$WEBADMINPASS${normal}" || echo "There was an error while DNAT'ing ssh port for your host"

echo ''

