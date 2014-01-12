#!/bin/bash

MAILDIR="/var/mail"
USAGE="USAGE : parser.sh <days_back_from_today> <mailbox_1> [mailbox_2] ... [mailbox_N]"

main(){

function is_integer() {
#    printf "%d" $1 > /dev/null 2>&1
    [ "$1" -eq "$1" ] > /dev/null 2>&1
    return $?
}

if [ $# == 0 ] || !(is_integer $1); then
    echo $USAGE
    exit 1
fi

DAYS=$1
shift

i=1
while (( $# )); do

    if ( ls $MAILDIR | fgrep "$1" > /dev/null 2>&1); then
        MAILBOXES[$i]="$1"
    fi
    i=$(( $i + 1 ))

    shift

done

}

find_mailboxes(){
COUNTER=0
a=0
if (mkdir -p /tmp/mail_parser_$$/{spam,baduser,badhost} > /dev/null 2>&1); then
    PARSED_DIR="/tmp/mail_parser_$$" 
else 
    echo "Can't create dir /tmp/mail_parser_$$"
    exit 1
fi

for BOX in ${MAILBOXES[@]} ;do
    find $MAILDIR/$BOX -type f -ctime -$DAYS | while read file; do
        #echo $file
        echo 1
        grep -q 'MAILER-DAEMON' "$file" || continue;
        echo 2
        RECIPIENT=$(grep "From:.*<news@ideco.*.ru>" "$file" -A1 | tail -n 1)
        if [ "$RECIPIENT" == '' ]; then
            RECIPIENT=$(grep "X-Failed-Recipients:*" "$file")
            RECIPIENT=${RECIPIENT##*:}
            echo $RECIPIENT
        else
            RECIPIENT=${RECIPIENT##*<}
            RECIPIENT=${RECIPIENT%%>*}
        fi
        
#        A=$(grep "news@ideco.ru" "$file" -A1 | tail -n 1)
        #echo "$file --- $A"
        cp "$file" "$PARSED_DIR/$RECIPIENT"
        echo -en '.'
        COUNTER=$(( $COUNTER + 1 ))
    done
#echo "Were found $COUNTER non-delivery-messages for $BOX email"
done

cd $PARSED_DIR && ls | while read file; do
#    echo "$file"
    cat "$file" | grep -qi "550 spam message rejected" && { echo -n ".";mv "$file" $PARSED_DIR/spam/ ; echo ${file##*/} >> spam.txt; continue; }

    cat "$file" | grep -qi "invalid recipient" && { echo -n "."; mv "$file" $PARSED_DIR/baduser/ ; echo ${file##*/} >> baduser.txt; continue; }
    cat "$file" | grep -qi "invalid mailbox" && { echo -n "."; mv "$file" $PARSED_DIR/baduser/; echo ${file##*/} >>baduser.txt; continue; }
    cat "$file" | grep -qi "unknown user" && { echo -n "."; mv "$file" $PARSED_DIR/baduser/; echo ${file##*/} >>baduser.txt; continue; }
    cat "$file" | grep -qi "unknown local user" && { echo -n "."; mv "$file" $PARSED_DIR/baduser/; echo ${file##*/} >>baduser.txt; continue; }
    cat "$file" | grep -qi "unknown or deactivated" && { echo -n ".";mv "$file" $PARSED_DIR/baduser/ ; echo ${file##*/} >>baduser.txt; continue; }
    cat "$file" | grep -qi "user unknown" && { echo -n ".";mv "$file" $PARSED_DIR/baduser/ ; echo ${file##*/} >>baduser.txt; continue; }
    cat "$file" | grep -qi "recipient unknown" && { echo -n ".";mv "$file" $PARSED_DIR/baduser/ ; echo ${file##*/} >>baduser.txt; continue; }
    cat "$file" | grep -qi "user not found" && { echo -n ".";mv "$file" $PARSED_DIR/baduser/ ; echo ${file##*/} >>baduser.txt; continue; }
    cat "$file" | grep -qi "no such user" && { echo -n ".";mv "$file" $PARSED_DIR/baduser/ ; echo ${file##*/} >>baduser.txt; continue; }
    cat "$file" | grep -qi "mailbox unavailable" && { echo -n ".";mv "$file" $PARSED_DIR/baduser/ ; echo ${file##*/} >>baduser.txt; continue; }
    cat "$file" | grep -qi "mailbox not found" && { echo -n ".";mv "$file" $PARSED_DIR/baduser/ ; echo ${file##*/} >>baduser.txt; continue; }
    cat "$file" | grep -qi "mailbox blocked" && { echo -n ".";mv "$file" $PARSED_DIR/baduser/ ; echo ${file##*/} >>baduser.txt; continue; }
    cat "$file" | grep -qi "recipient address rejected" && { echo -n ".";mv "$file" $PARSED_DIR/baduser/ ; echo ${file##*/} >>baduser.txt; continue; }
    cat "$file" | grep -qi "account is disabled" && { echo -n ".";mv "$file" $PARSED_DIR/baduser/ ; echo ${file##*/} >>baduser.txt; continue; }
    cat "$file" | grep -qi "no mailbox here by that name" && { echo -n ".";mv "$file" $PARSED_DIR/baduser/ ; echo ${file##*/} >>baduser.txt; continue; }
    cat "$file" | grep -qi "account has been disabled" && { echo -n ".";mv "$file" $PARSED_DIR/baduser/ ; echo ${file##*/} >>baduser.txt; continue; }
    cat "$file" | grep -qi "account that you tried to reach does not exist" && { echo -n ".";mv "$file" $PARSED_DIR/baduser/ ; echo ${file##*/} >>baduser.txt; continue; }
    cat "$file" | grep -qi "account that you tried to reach is disabled" && { echo -n ".";mv "$file" $PARSED_DIR/baduser/ ; echo ${file##*/} >>baduser.txt; continue; }
    cat "$file" | grep -qi "No such address" && { echo -n ".";mv "$file" $PARSED_DIR/baduser/ ; echo ${file##*/} >>baduser.txt; continue; }
    cat "$file" | grep -qi "Mailbox disabled for this recipient" && { echo -n ".";mv "$file" $PARSED_DIR/baduser/ ; echo ${file##*/} >>baduser.txt; continue; }
    cat "$file" | grep -qi "This user doesn't have a " && { echo -n ".";mv "$file" $PARSED_DIR/baduser/ ; echo ${file##*/} >>baduser.txt; continue; }
    cat "$file" | grep -qi "We do not relay" && { echo -n ".";mv "$file" $PARSED_DIR/baduser/ ; echo ${file##*/} >>baduser.txt; continue; }
    cat "$file" | grep -qi "Unknown recipient" && { echo -n ".";mv "$file" $PARSED_DIR/baduser/ ; echo ${file##*/} >>baduser.txt; continue; }
    cat "$file" | grep -qi "Unknown account" && { echo -n ".";mv "$file" $PARSED_DIR/baduser/ ; echo ${file##*/} >>baduser.txt; continue; }
    cat "$file" | grep -qi "quota exceeded" && { echo -n ".";mv "$file" $PARSED_DIR/baduser/ ; echo ${file##*/} >>baduser.txt; continue; }
    cat "$file" | grep -qi "said: 550" && { echo -n ".";mv "$file" $PARSED_DIR/baduser/ ; echo ${file##*/} >>baduser.txt; continue; }
    cat "$file" | grep -qi "permission denied" && { echo -n ".";mv "$file" $PARSED_DIR/baduser/ ; echo ${file##*/} >>baduser.txt; continue; }
    cat "$file" | grep -qi "connection refused" && { echo -n ".";mv "$file" $PARSED_DIR/baduser/ ; echo ${file##*/} >>baduser.txt; continue; }
    cat "$file" | grep -qi "mailbox is full" && { echo -n ".";mv "$file" $PARSED_DIR/baduser/ ; echo ${file##*/} >>baduser.txt; continue; }
    cat "$file" | grep -qi "address rejected" && { echo -n ".";mv "$file" $PARSED_DIR/baduser/ ; echo ${file##*/} >>baduser.txt; continue; }
    cat "$file" | grep -qi "bad address syntax" && { echo -n ".";mv "$file" $PARSED_DIR/baduser/ ; echo ${file##*/} >>baduser.txt; continue; }
    cat "$file" | grep -qi "user is over quota" && { echo -n ".";mv "$file" $PARSED_DIR/baduser/ ; echo ${file##*/} >>baduser.txt; continue; }
    cat "$file" | grep -qi "exceed maximum mailbox size" && { echo -n ".";mv "$file" $PARSED_DIR/baduser/ ; echo ${file##*/} >>baduser.txt; continue; }
    cat "$file" | grep -qi "user not exists" && { echo -n ".";mv "$file" $PARSED_DIR/baduser/ ; echo ${file##*/} >>baduser.txt; continue; }
    cat "$file" | grep -qi "said: 552" && { echo -n ".";mv "$file" $PARSED_DIR/baduser/ ; echo ${file##*/} >>baduser.txt; continue; }
    cat "$file" | grep -qi "said: 553" && { echo -n ".";mv "$file" $PARSED_DIR/baduser/ ; echo ${file##*/} >>baduser.txt; continue; }
    cat "$file" | grep -qi "exceeds user limit" && { echo -n ".";mv "$file" $PARSED_DIR/baduser/ ; echo ${file##*/} >>baduser.txt; continue; }
    cat "$file" | grep -qi "exceed account" && { echo -n ".";mv "$file" $PARSED_DIR/baduser/ ; echo ${file##*/} >>baduser.txt; continue; }
    cat "$file" | grep -qi "following recipients failed" && { echo -n ".";mv "$file" $PARSED_DIR/baduser/ ; echo ${file##*/} >>baduser.txt; continue; }
    cat "$file" | grep -qi "retry time not reached" && { echo -n ".";mv "$file" $PARSED_DIR/baduser/ ; echo ${file##*/} >>baduser.txt; continue; }
    cat "$file" | grep -qi "said: 551" && { echo -n ".";mv "$file" $PARSED_DIR/baduser/ ; echo ${file##*/} >>baduser.txt; continue; }
    cat "$file" | grep -qi "user does not exist" && { echo -n ".";mv "$file" $PARSED_DIR/baduser/ ; echo ${file##*/} >>baduser.txt; continue; }
    cat "$file" | grep -qi "diskspace quota" && { echo -n ".";mv "$file" $PARSED_DIR/baduser/ ; echo ${file##*/} >>baduser.txt; continue; }
    cat "$file" | grep -qi "does not exist" && { echo -n ".";mv "$file" $PARSED_DIR/baduser/ ; echo ${file##*/} >>baduser.txt; continue; }
    cat "$file" | grep -qi "over quota" && { echo -n ".";mv "$file" $PARSED_DIR/baduser/ ; echo ${file##*/} >>baduser.txt; continue; }
    cat "$file" | grep -qi "Status: 5.1.1" && { echo -n ".";mv "$file" $PARSED_DIR/baduser/ ; echo ${file##*/} >>baduser.txt; continue; }
    cat "$file" | grep -qi "553 sorry" && { echo -n ".";mv "$file" $PARSED_DIR/baduser/ ; echo ${file##*/} >>baduser.txt; continue; }
    cat "$file" | grep -qi " smtp; 550 " && { echo -n ".";mv "$file" $PARSED_DIR/baduser/ ; echo ${file##*/} >>baduser.txt; continue; }
    cat "$file" | grep -qi " The following address(es) failed:" && { echo -n ".";mv "$file" $PARSED_DIR/baduser/ ; echo ${file##*/} >>baduser.txt; continue; }
    cat "$file" | grep -qi "Failed to deliver to " && { echo -n ".";mv "$file" $PARSED_DIR/baduser/ ; echo ${file##*/} >>baduser.txt; continue; }
    cat "$file" | grep -qi "permanent fatal errors" && { echo -n ".";mv "$file" $PARSED_DIR/baduser/ ; echo ${file##*/} >>baduser.txt; continue; }
    cat "$file" | grep -qi "address no longer accepts mail" && { echo -n ".";mv "$file" $PARSED_DIR/baduser/ ; echo ${file##*/} >>baduser.txt; continue; }
    cat "$file" | grep -qi "sorry, quota" && { echo -n ".";mv "$file" $PARSED_DIR/baduser/ ; echo ${file##*/} >>baduser.txt; continue; }
    cat "$file" | grep -qi "5.1.1 - Bad destination email address" && { echo -n ".";mv "$file" $PARSED_DIR/baduser/ ; echo ${file##*/} >>baduser.txt; continue; }
    cat "$file" | grep -qi "cannot update mailbox" && { echo -n ".";mv "$file" $PARSED_DIR/baduser/ ; echo ${file##*/} >>baduser.txt; continue; }
    cat "$file" | grep -qi "has been delayed" && { echo -n ".";mv "$file" $PARSED_DIR/baduser/ ; echo ${file##*/} >>baduser.txt; continue; }
    cat "$file" | grep -qi "recipients mailbox is" && { echo -n ".";mv "$file" $PARSED_DIR/baduser/ ; echo ${file##*/} >>baduser.txt; continue; }
    cat "$file" | grep -qi "mailbox size over limit" && { echo -n ".";mv "$file" $PARSED_DIR/baduser/ ; echo ${file##*/} >>baduser.txt; continue; }
    cat "$file" | grep -qi "said: 452 4.2.2" && { echo -n ".";mv "$file" $PARSED_DIR/baduser/ ; echo ${file##*/} >>baduser.txt; continue; }
    cat "$file" | grep -qi "failed to mailbox" && { echo -n ".";mv "$file" $PARSED_DIR/baduser/ ; echo ${file##*/} >>baduser.txt; continue; }
    cat "$file" | grep -qi "bad address syntax" && { echo -n ".";mv "$file" $PARSED_DIR/baduser/ ; echo ${file##*/} >>baduser.txt; continue; }

    cat "$file" | grep -qi "connection timed" && { echo -n ".";mv "$file" $PARSED_DIR/badhost/ ; echo ${file##*/} >>badhost.txt; continue; }
    cat "$file" | grep -qi "]: Connection" && { echo -n ".";mv "$file" $PARSED_DIR/badhost/ ; echo ${file##*/} >>badhost.txt; continue; }
    cat "$file" | grep -qi "while receiving the initial SMTP greeting" && { echo -n ".";mv "$file" $PARSED_DIR/badhost/ ; echo ${file##*/} >>badhost.txt; continue; }
    cat "$file" | grep -qi "read timeout" && { echo -n ".";mv "$file" $PARSED_DIR/badhost/ ; echo ${file##*/} >>badhost.txt; continue; }
    cat "$file" | grep -qi "connection refused" && { echo -n ".";mv "$file" $PARSED_DIR/badhost/ ; echo ${file##*/} >>badhost.txt; continue; }
    cat "$file" | grep -qi "relay access denied" && { echo -n ".";mv "$file" $PARSED_DIR/badhost/ ; echo ${file##*/} >>badhost.txt; continue; }
    cat "$file" | grep -qi "Host or domain name not found" && { echo -n "."; mv "$file" $PARSED_DIR/badhost/; echo ${file##*/} >>badhost.txt; continue; }
    cat "$file" | grep -qi "Name service error" && { echo -n "."; mv "$file" $PARSED_DIR/badhost/; echo ${file##*/} >>badhost.txt; continue; }
    cat "$file" | grep -qi "Relay not permitted" && { echo -n ".";mv "$file" $PARSED_DIR/badhost/ ; echo ${file##*/} >>badhost.txt; continue; }
    cat "$file" | grep -qi "Unrouteable address" && { echo -n ".";mv "$file" $PARSED_DIR/badhost/ ; echo ${file##*/} >>badhost.txt; continue; }
    cat "$file" | grep -qi "No route to host" && { echo -n ".";mv "$file" $PARSED_DIR/badhost/ ; echo ${file##*/} >>badhost.txt; continue; }
    cat "$file" | grep -qi "loops back to myself" && { echo -n ".";mv "$file" $PARSED_DIR/badhost/ ; echo ${file##*/} >>badhost.txt; continue; }
    cat "$file" | grep -qi "local delivery failed" && { echo -n ".";mv "$file" $PARSED_DIR/badhost/ ; echo ${file##*/} >>badhost.txt; continue; }
    cat "$file" | grep -qi "route to host" && { echo -n ".";mv "$file" $PARSED_DIR/badhost/ ; echo ${file##*/} >>badhost.txt; continue; }
    cat "$file" | grep -qi "Antivirus check cannot be performed" && { echo -n ".";mv "$file" $PARSED_DIR/badhost/ ; echo ${file##*/} >>badhost.txt; continue; }
    cat "$file" | grep -qi "said: 451" && { echo -n ".";mv "$file" $PARSED_DIR/badhost/ ; echo ${file##*/} >>badhost.txt; continue; }
    cat "$file" | grep -qi "said: 450" && { echo -n ".";mv "$file" $PARSED_DIR/badhost/ ; echo ${file##*/} >>badhost.txt; continue; }
    cat "$file" | grep -qi "cannot be delivered" && { echo -n ".";mv "$file" $PARSED_DIR/badhost/ ; echo ${file##*/} >>badhost.txt; continue; }
    cat "$file" | grep -qi " timed out" && { echo -n ".";mv "$file" $PARSED_DIR/badhost/ ; echo ${file##*/} >>badhost.txt; continue; }
    cat "$file" | grep -qi "mail receiving disabled" && { echo -n ".";mv "$file" $PARSED_DIR/badhost/ ; echo ${file##*/} >>badhost.txt; continue; }
    cat "$file" | grep -qi "said: 530" && { echo -n ".";mv "$file" $PARSED_DIR/badhost/ ; echo ${file##*/} >>badhost.txt; continue; }
    cat "$file" | grep -qi "can not be delivered" && { echo -n ".";mv "$file" $PARSED_DIR/badhost/ ; echo ${file##*/} >>badhost.txt; continue; }
    cat "$file" | grep -qi "size exceeds fixed limit" && { echo -n ".";mv "$file" $PARSED_DIR/badhost/ ; echo ${file##*/} >>badhost.txt; continue; }
    cat "$file" | grep -qi "Maximum hop count" && { echo -n ".";mv "$file" $PARSED_DIR/badhost/ ; echo ${file##*/} >>badhost.txt; continue; }
    cat "$file" | grep -qi "sender address syntax" && { echo -n ".";mv "$file" $PARSED_DIR/badhost/ ; echo ${file##*/} >>badhost.txt; continue; }
    cat "$file" | grep -qi "size is too long" && { echo -n ".";mv "$file" $PARSED_DIR/badhost/ ; echo ${file##*/} >>badhost.txt; continue; }
    cat "$file" | grep -qi "]:25: Connection" && { echo -n ".";mv "$file" $PARSED_DIR/badhost/ ; echo ${file##*/} >>badhost.txt; continue; }
    cat "$file" | grep -qi ": temporary failure" && { echo -n ".";mv "$file" $PARSED_DIR/badhost/ ; echo ${file##*/} >>badhost.txt; continue; }
    cat "$file" | grep -qi "size exceeds fixed" && { echo -n ".";mv "$file" $PARSED_DIR/badhost/ ; echo ${file##*/} >>badhost.txt; continue; }
    cat "$file" | grep -qi "MX records point to" && { echo -n ".";mv "$file" $PARSED_DIR/badhost/ ; echo ${file##*/} >>badhost.txt; continue; }
    cat "$file" | grep -qi "lost connection with" && { echo -n ".";mv "$file" $PARSED_DIR/badhost/ ; echo ${file##*/} >>badhost.txt; continue; }
    cat "$file" | grep -qi "said: 513" && { echo -n ".";mv "$file" $PARSED_DIR/badhost/ ; echo ${file##*/} >>badhost.txt; continue; }
    cat "$file" | grep -qi "530 5.7.1" && { echo -n ".";mv "$file" $PARSED_DIR/badhost/ ; echo ${file##*/} >>badhost.txt; continue; }
    cat "$file" | grep -qi ": 587" && { echo -n ".";mv "$file" $PARSED_DIR/badhost/ ; echo ${file##*/} >>badhost.txt; continue; }
    cat "$file" | grep -qi "too many hops" && { echo -n ".";mv "$file" $PARSED_DIR/badhost/ ; echo ${file##*/} >>badhost.txt; continue; }
    cat "$file" | grep -qi "]: no route" && { echo -n ".";mv "$file" $PARSED_DIR/badhost/ ; echo ${file##*/} >>badhost.txt; continue; }
    cat "$file" | grep -qi "smtp; 550-rejected" && { echo -n ".";mv "$file" $PARSED_DIR/badhost/ ; echo ${file##*/} >>badhost.txt; continue; }
    cat "$file" | grep -qi "No route found" && { echo -n ".";mv "$file" $PARSED_DIR/badhost/ ; echo ${file##*/} >>badhost.txt; continue; }

    cat "$file" | grep -qi "suspicion of SPAM" && { echo -n ".";mv "$file" $PARSED_DIR/spam/ ; echo ${file##*/} >>spam.txt; continue; }
    cat "$file" | grep -qi "spamblock" && { echo -n ".";mv "$file" $PARSED_DIR/spam/ ; echo ${file##*/} >>spam.txt; continue; }
    cat "$file" | grep -qi "classified as SPAM" && { echo -n ".";mv "$file" $PARSED_DIR/spam/ ; echo ${file##*/} >>spam.txt; continue; }
    cat "$file" | grep -qi "identified as SPAM" && { echo -n ".";mv "$file" $PARSED_DIR/spam/ ; echo ${file##*/} >>spam.txt; continue; }
    cat "$file" | grep -qi "said: 554" && { echo -n ".";mv "$file" $PARSED_DIR/spam/ ; echo ${file##*/} >>spam.txt; continue; }
    cat "$file" | grep -qi "Blocked for abuse" && { echo -n ".";mv "$file" $PARSED_DIR/spam/ ; echo ${file##*/} >>spam.txt; continue; }
    cat "$file" | grep -qi "appears to be SPAM" && { echo -n ".";mv "$file" $PARSED_DIR/spam/ ; echo ${file##*/} >>spam.txt; continue; }
    cat "$file" | grep -qi "Considered UNSOLICITED BULK EMAIL" && { echo -n ".";mv "$file" $PARSED_DIR/spam/ ; echo ${file##*/} >>spam.txt; continue; }
    cat "$file" | grep -qi "You are still not in my white list" && { echo -n ".";mv "$file" $PARSED_DIR/spam/ ; echo ${file##*/} >>spam.txt; continue; }
    cat "$file" | grep -qi "Confirmed Spam Content" && { echo -n ".";mv "$file" $PARSED_DIR/spam/ ; echo ${file##*/} >>spam.txt; continue; }
    cat "$file" | grep -qi "said: 591" && { echo -n ".";mv "$file" $PARSED_DIR/spam/ ; echo ${file##*/} >>spam.txt; continue; }
    cat "$file" | grep -qi "]: 550" && { echo -n ".";mv "$file" $PARSED_DIR/spam/ ; echo ${file##*/} >>spam.txt; continue; }
    cat "$file" | grep -qi "message rejected" && { echo -n ".";mv "$file" $PARSED_DIR/spam/ ; echo ${file##*/} >>spam.txt; continue; }
    cat "$file" | grep -qi "Callout verification failed" && { echo -n ".";mv "$file" $PARSED_DIR/spam/ ; echo ${file##*/} >>spam.txt; continue; }
    cat "$file" | grep -qi "www.spamhaus.org" && { echo -n ".";mv "$file" $PARSED_DIR/spam/ ; echo ${file##*/} >>spam.txt; continue; }
    cat "$file" | grep -qi "DNSBL listed at" && { echo -n ".";mv "$file" $PARSED_DIR/spam/ ; echo ${file##*/} >>spam.txt; continue; }
    cat "$file" | grep -qi "message looks like SPAM to me" && { echo -n ".";mv "$file" $PARSED_DIR/spam/ ; echo ${file##*/} >>spam.txt; continue; }
    cat "$file" | grep -qi "address is blacklisted" && { echo -n ".";mv "$file" $PARSED_DIR/spam/ ; echo ${file##*/} >>spam.txt; continue; }
    cat "$file" | grep -qi "this message is unwanted here" && { echo -n ".";mv "$file" $PARSED_DIR/spam/ ; echo ${file##*/} >>spam.txt; continue; }
    cat "$file" | grep -qi "said: 535" && { echo -n ".";mv "$file" $PARSED_DIR/spam/ ; echo ${file##*/} >>spam.txt; continue; }
    cat "$file" | grep -qi "smtp: 421" && { echo -n ".";mv "$file" $PARSED_DIR/spam/ ; echo ${file##*/} >>spam.txt; continue; }

done

}

main $@
find_mailboxes