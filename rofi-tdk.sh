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
        hash=$(echo -ne $2 | md5sum | cut -c -32)
        if ! [ -f "$CACHE/$hash" ]; then
            echo -e "error\nKelime bulunamadı." > $TMP
        else
            echo -e "word\n$hash" > $TMP
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

            ;;line) 
                tmp=$(mktemp /tmp/rofi-tdk-line.XXXXXXXX)
                echo -ne "Geri" > $tmp
                details=$(echo "$data" | sed -n 3p) 
                if [ -n "$details" ]; then echo "|$details" >> $tmp
                else mesg='-mesg'; sentence="$(echo "$data" | sed -n 2p)"; fi
                line=$(cat $tmp | runrofi -dmenu $mesg "$sentence" -markup-rows -p 'TDK' -sep '|')
                if [ "$line" = "Geri" ] || [ -z "$line" ]; then
                    echo -e "word\n$(echo "$data" | sed -n 1p)" > $TMP
                else
                    echo -e "word\n$(echo -ne "$line" | md5sum | cut -c -32)" > $TMP
                fi
                rm $tmp

            ;;word) 
                tmp=$(mktemp /tmp/rofi-tdk-word.XXXXXXXX)
                details=$(mktemp /tmp/rofi-tdk-details.XXXXXXXX)
                hash=$data
                data=$(cat "$CACHE/$hash" | tail -n +2)

                echotmp () {
                    echo $@ >> $tmp
                    if [[ "$(tail -c 1 $tmp | od -An -t x1)" == ' 0a' ]]; then echo '' >> $details; fi
                }
                echodetails () {
                    echo -n $@ >> $details
                }

                echotmp ''
                meaning=1; writer=; features=; suffix=; origin=
                echo "$data" | while read line; do 
                    type=$(echo $line | cut -c 1)
                    data=$(echo $line | cut -c 2-)
                    if [ -z "$data" ]; then data=$(echo $line | sed -n 's/^\s*\w\s\+\(.*\)$/\1/p'); fi
                    case $type in
                        'm') 
                            echotmp "<i><span fgcolor='$COLOR_WORD'>$data$suffix $origin</span></i>"
                            suffix=; origin=
                        ;;'a')
                            echotmp -e "<b>$meaning.</b><span fgcolor='red'><i>$features</i></span> $data"
                            ((meaning ++)); features=
                        ;;'o') 
                            echotmp -e "<span>$data</span> <i>$writer</i>"
                            writer=
                        ;;'y') writer="- $data"
                        ;;'k') origin="($data)"
                        ;;'z') features=" $data"
                        ;;'t') if [ -n "$data" ]; then suffix=", -$data"; fi
                        ;;'b') 
                            if [ -n "$data" ]; then
                                echodetails $(echo "$data" | sed 's/, /|/g')
                                echotmp "Birleşik isimler: $data"
                            fi
                        ;;'s') 
                                echodetails "$data"
                                echotmp "Kalıp sözler: $(echo "$data" | sed 's/|/, /g')"
                        ;;'') echo '' >> $tmp
                        ;;*) if [ -n "$data" ]; then echotmp "$data"; fi
                    esac
                done

                selected=$(cat $tmp | rofi -p 'TDK' -dmenu -markup-rows -format "d:s")
                line=$(echo "$selected" | sed 's/^\([[:digit:]]\+\):.*$/\1/')
                markup=$(echo "$selected" | cut -c $((${#line} + 2))-)

                if [ -z "$line" ]; then echo -ne 'start' > $TMP
                elif [ -z "$markup" ]; then exit 0;
                else
                    echo -ne "line\n$hash\n$markup\n$(cat $details | sed -n ${line}p)" > $TMP
                fi
                rm $tmp $details
                ;;
            *) 
                rm $TMP; exit
        esac
    done
fi
