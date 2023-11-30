#!/bin/bash

DATABASE=/var/tdk.tar.gz
CACHE=/dev/shm/rofi-tdk-cache # /dev/shm/'de veriler RAM'de tutulur. Hızlı erişim için tercih ediyorum, /tmp'yi kullanabilirsiniz.

COLOR_WORD='#E48F45'

if ! [ -d "$CACHE" ]; then
    mkdir $CACHE
    tar -xvzf $DATABASE -C $CACHE/
fi

if [ "$1" = 'init' ]; then exit; fi



ROFI_BIN=$(command -v rofi)

runrofi () {
    $ROFI_BIN -sort fzf -normalize-match "$@"
}

if [ "$1" = 'word' ]; then 
    echo -ne 'exit' > $TMP
    if [ -n "$2" ]; then 
        file="$CACHE/$(echo -ne $2 | md5sum | cut -c -32)"
        if ! [ -f "$file" ]; then
            echo -e "error\nKelime bulunamadı." > $TMP
        else
            echo 'word' > $TMP
            cat $file >> $TMP
        fi
    else
        cat $CACHE/list
    fi
else
    export TMP=$(mktemp /tmp/rofi-tdk.XXXXXXXX)
    echo -ne 'start' > $TMP
    while true; do
        fl=$(cat $TMP | head -n 1)
        mesg=${fl//[$'\t\r\n']}
        data=$(cat $TMP | tail -n +2)
        >$TMP
        case $(echo $mesg | head -n 1) in
            start) 
                runrofi -modi "TDK:$0 word" -show TDK 
            ;;error)
                runrofi -e "$data"
                echo "start" > $TMP
            ;;word) 
                tmp=$(mktemp /tmp/rofi-tdk-word.XXXXXXXX)
                echo '' > $tmp
                meaning=1; writer=; features=; suffix=
                echo "$data" | while read line; do 
                    type=$(echo $line | cut -c 1)
                    data=$(echo $line | cut -c 2-)
                    if [ -z "$data" ]; then data=$(echo $line | sed -n 's/^\s*\w\s\+\(.*\)$/\1/p'); fi
                    case $type in
                        'm') 
                            echo "<i><span fgcolor='$COLOR_WORD'>$data$suffix</span></i>" >> $tmp
                            suffix=
                        ;;'a')
                            echo -ne "<b>$meaning.</b><span fgcolor='red'><i>$features</i></span> $data\n" >> $tmp
                            ((meaning ++)); features=
                        ;;'o') 
                            echo -ne "<span>$data</span> <i>$writer</i>\n" >> $tmp
                            writer=
                        ;;'y') writer="- $data"
                        ;;'z') features=" $data"
                        ;;'t') if [ -n "$data" ]; then suffix=", -$data"; fi
                        ;;'') echo -ne "\n\n" >> $tmp
                        ;;*) if [ -n "$data" ]; then echo "$data" >> $tmp; fi
                    esac


                done
                cat $tmp | rofi -p 'TDK' -dmenu -markup-rows
                echo -ne 'start' > $TMP
                ;;
            *) 
                rm $TMP
                exit
        esac
    done
fi
