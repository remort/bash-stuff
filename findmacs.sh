#!/bin/bash 

findmacs_new()
{
#for iface in `ip -o link | awk '/ link\/ether / { print $2; }'`; do
for iface in `ip -o link | awk '/ link\/ether / && !/NOARP/ && !/MASTER/ {print$2}'`; do
    iface="${iface%:}"
    hwaddr=`ethtool -P "$iface" | awk '{print $3}'`
    echo $iface -- $hwaddr
    continue
    [ -z "$hwaddr" ] && continue
    [ "$hwaddr" = 00:00:00:00:00:00 ] && continue
    ethtool -i "$iface" > /tmp/mmeth.tmp
    driver=
    version=
    fwversion=
    businfo=
    while read key value; do
        [ "$key" = 'driver:' ] && { driver="$value"; continue; }
        [ "$key" = 'version:' ] && { version="$value"; continue; }
        [ "$key" = 'firmware-version:' ] && { fwversion="$value"; continue; }
        [ "$key" = 'bus-info:' ] && { businfo="$value"; continue; }
    done < /tmp/mmeth.tmp
    [ -z "$businfo" ] && continue
    lspci -mm -s "$businfo" > /tmp/mmeth.tmp
    read -r line < /tmp/mmeth.tmp
    eval "set -- $line"


    ident=$1; shift
    controller_type=$1; shift
    vendor=$1; shift
    name=$1; shift
    revision=$1; shift
    comment=$1; shift
    series=$1; shift

    list=("${list[@]}" "'${hwaddr,,}' '$name' '$vendor $name'")
done
}

findmacs_new

echo ${list[@]}
