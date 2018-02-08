#!/bin/sh

LOCKFILENAME="HileBt.dat"
LOCKDBFOLDER="$(dirname $(find ~/ -type f -name "${LOCKFILENAME}") 2>/dev/null  || echo "./torrent")"
LOCKDB="${LOCKDBFOLDER}/${LOCKFILENAME}"
LOCKSHIFT=500000

TORRENTDOWNLOAD=${LOCKDBFOLDER}/$(date +%Y%m%d)
HILETVBASEURL="http://www.hiletv.com/bt/"
HILETVURL="${HILETVBASEURL}thread.php?fid=16&search=14"
CURL="$(which curl) -s --header \"User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.89 Safari/537.36\""
FIRSTPAGE=$(echo "${CURL} \"${HILETVURL}\" | iconv -f gbk -t utf8 " | bash)
THREADLIST=""
#echo "$FIRSTPAGE"

PAGE=$(echo "${FIRSTPAGE}" | grep 'div class="pages"' | sed -e 's/.*Pages:\s\+(\s\+\([0-9]\+\)\/\([0-9]\+\)\s\+total\s\+).*/\2/g' | tail -n 1)
mkdir -p ${TORRENTDOWNLOAD}

[[ -f $LOCKDB ]] || dd if=/dev/zero of=$LOCKDB bs=1 count=$(expr 10 \* 1024 \* 1024)
sleep $(( ( RANDOM % 2 )  + 1 ))
for ((i = 1; i <= PAGE; i++)); do
        printf "%s ... \n" "Page: $i"
        #grep -P '<h3><a href="htm_data/[0-9]{2}/[0-9]{4}/[0-9]\+.html" id="a_ajax_[0-9]\+" target=_blank>[^<]\+</a></h3>'

        THREADLIST=${THREADLIST}$(echo "${CURL} \"${HILETVURL}&page=${i}\" | iconv -c -f gbk -t utf8" | \
                bash | grep -P '<h3><a href="htm_data/[0-9]{2}/[0-9]{4}/[0-9]+.html" id="a_ajax_[0-9]+" target=_blank>[^<]+</a></h3>')
        sleep $(( ( RANDOM %3 )  + 1 ))
done

echo "$THREADLIST" | sed -e 's/.*<h3><a href="\(htm_data\/[0-9]\{2\}\/[0-9]\{4\}\/[0-9]\+.html\)" id="a_ajax_\([0-9]\+\)" target=_blank>\([^<]\+\)<\/a><\/h3>.*/\1\t\2\t\3/g' | \
        while read THREADLINK TID THREADTITLE;
        do
                LOCLCHECK=$(xxd -p -l1 -s $(expr $TID - $LOCKSHIFT) ${LOCKDB})
                if [ "${LOCLCHECK}" == "01" ]; then
                        printf .
                        continue
                fi
                TORRENTDONE=0
                echo "$HILETVBASEURL$THREADLINK | $THREADTITLE" | php -r 'while(($line=fgets(STDIN)) !== FALSE) echo html_entity_decode($line, ENT_QUOTES|ENT_HTML401);'
                THREADCONTAIN=$(echo "${CURL} \"$HILETVBASEURL$THREADLINK\" | iconv -c -f gbk -t utf8" | \
                        bash )
                echo "$THREADCONTAIN" | grep -q 'http://www.jandown.com/link.php?ref=' && \
                {
                        THREADDOWNLOADCODE=$(echo "$THREADCONTAIN" | grep 'http://www.jandown.com/link.php?ref=' | sed -e 's/.*<a href="\(http:\/\/www\.jandown\.com\/link\.php?ref=\([^"]\+\)\)".*/\2/g')
                        TMPFILE=$(mktemp /tmp/HileTV.XXXXXXXX)
                        echo "${CURL} -X POST -d \"code=${THREADDOWNLOADCODE}\" \"http://www.jandown.com/fetch.php\" > $TMPFILE " | bash
                        transmission-show $TMPFILE 1>/dev/null && \
                        {
                                mv $TMPFILE $TORRENTDOWNLOAD/${THREADDOWNLOADCODE}.torrent
                                printf '\x01' | dd of=${LOCKDB} bs=1 seek=$(expr $TID - ${LOCKSHIFT}) count=1 conv=notrunc 1>/dev/null
                                TORRENTDONE=1
                        }
                }



                test $TORRENTDONE -eq 0 && echo "$HILETVBASEURL$THREADLINK | $THREADTITLE" > $LOCKDBFOLDER/HileBt_error.txt
                sleep $(( ( RANDOM % 10 )  + 1 ))
        done
