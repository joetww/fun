#!/bin/sh

LOCKFILENAME="SiSBt.dat"
LOCKDBFOLDER="$(dirname $(find ~/ -type f -name "${LOCKFILENAME}") 2>/dev/null  || echo "./torrent")"
LOCKDB="${LOCKDBFOLDER}/${LOCKFILENAME}"
LOCKSHIFT=10074000
TORRENTDOWNLOAD=${LOCKDBFOLDER}/$(date +%Y%m%d)
SISBASEURL="http://sis001.com/forum/"
SISURL="${SISBASEURL}forumdisplay.php?fid=25&filter=86400&orderby=dateline&ascdesc=DESC"
CURL="$(which curl) -s --header \"User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.89 Safari/537.36\""
XMLLINT=$(which xmllint)
FIRSTPAGE=$(echo "${CURL} \"${SISURL}\"" | bash | ${XMLLINT} --html --xpath '//html' - 2>/dev/null)
VIEWTHREAD=$(echo ${FIRSTPAGE} | ${XMLLINT} --html --xpath '//*[@id="wrapper"]/div[1]/div[5]/div/em' - 2>/dev/null | sed -e 's/<em>&#160;\([0-9]\+\)&#160;<\/em>/\1/')
THREADLIST=""
PAGE=$(expr ${VIEWTHREAD} / 50 + 1)
mkdir -p ${TORRENTDOWNLOAD}
[[ -f $LOCKDB ]] || dd if=/dev/zero of=$LOCKDB bs=1 count=$(expr 10 \* 1024 \* 1024)

sleep $(( ( RANDOM % 2 )  + 1 ))
for ((i = 1; i <= PAGE; i++)); do
        printf "%s ... " "Page: $i"
        #THREADLIST=${THREADLIST}$(echo "${CURL} \"${SISURL}&page=${i}\"" | bash | ${XMLLINT} --html --xpath '//td[@class="nums" and contains(., "G")]/..//span/a/..' - 2>/dev/null )
        THREADLIST=${THREADLIST}$(echo "${CURL} \"${SISURL}&page=${i}\"" | bash | ${XMLLINT} --html --xpath '//tbody[//td/@class="nums" and contains(string(@id), "normalthread_")]//td[./@class="nums"][2]|//tbody[//td/@class="nums" and contains(string(@id), "normalthread_")]//span[./a/@href]' - 2>/dev/null )
        sleep $(( ( RANDOM % 20 )  + 1 ))
done

echo
echo -e "$THREADLIST" | tr '\r\n' ' ' > x.log
THREADFORMATLIST=$(echo $THREADLIST | tr '\r\n' ' ' | iconv -f gbk -t utf8 | sed -e 's@<span[^>]\+><a[^"]\+"\([^"]\+\)"[^>]*>\([^<]\+\)</a></span><td class="nums">\s*\([0-9.]\+\)\s*\([GM]\)[B]*[^<]\+</td>@"\1" "\2" \3 x\4x\n@ig' | sed -e 's@"\([^"]\+\)" "\([^"]\+\)" \([^\s]\+\) xGx@printf "\\"%s\\" \\"%s\\" %s" "\1" "\2" $(echo \"scale= 0; \3 * 1024 / 1\" | bc)@gie' -e 's@"\([^"]\+\)" "\([^"]\+\)" \([^\s]\+\) xMx@printf "\\"%s\\" \\"%s\\" %s" "\1" "\2" $(echo \"scale= 0; \3 * 1 / 1\" | bc)@gie')

echo -e "$THREADFORMATLIST" | awk 'BEGIN{FS="\""}{if($5>=600)printf("%5d\t%-70s\n", $5, $4)}' | sort
#exit
echo
#echo -e "${THREADLIST}" | sed -e 's/<\/span><span/<\/span><br \/><span/g' | iconv -f gbk -t utf8 | w3m -T text/html -o display_charset=UTF-8 -dump -cols 180
for i in $(echo -e "$THREADFORMATLIST" | awk 'BEGIN{FS="\""}{if($5>=600)print $2}'); do
        #echo "GoTo ${SISBASEURL}${i}"
        TID=$(echo ${i} | sed -e 's/.*?tid=\([0-9]\+\)&.*/\1/')
        #xxd.exe -p -l1 -s 452 SiSBt.dat
        LOCLCHECK=$(xxd -p -l1 -s $(expr $TID - $LOCKSHIFT) ${LOCKDB})
        if [ "${LOCLCHECK}" == "01" ]; then
                printf .
                continue
        fi
        echo

        THREADCONTAIN=$(echo "${CURL} \"${SISBASEURL}${i}\"" | bash)
        THREADTITLE=$(echo -e "${THREADCONTAIN}" | ${XMLLINT} --html --xpath '//*[@id="wrapper"]/div[1]/form/div[1]/h1/text()' - 2>/dev/null | iconv -f gbk -t utf8 | xargs)
        if [ -z "${THREADTITLE}" ]; then
                continue
        fi
        echo "${THREADTITLE}"
        echo "GoTo ${SISBASEURL}${i}"
        for j in $(echo -e "${THREADCONTAIN}" | ${XMLLINT} --html --xpath '//a[contains(@href, "attachment.php")]/@href' - 2>/dev/null | sed -e 's/href=\"\([^"]\+\)\"/\1/'); do
                echo
                echo "Get Torrent From: ${SISBASEURL}${j}"
                FILENAME=$(echo "${CURL} -I \"${SISBASEURL}${j}\"" | bash | iconv -f gbk -t utf8 | \
                        grep 'Content-Disposition: attachment; filename=' | \
                        sed -e 's/Content-Disposition: attachment; filename="\([^"]\+\)"/\1/' | sed $'s/\r//' | \
                        perl -pe 'chomp if eof' )
                echo \"${FILENAME}\"
                echo "${CURL} \"${SISBASEURL}${j}\" -o \"${TORRENTDOWNLOAD}/${FILENAME}\"" | bash && printf '\x01' | dd of=${LOCKDB} bs=1 seek=$(expr $TID - ${LOCKSHIFT}) count=1 conv=notrunc 1>/dev/null
                sleep $(( ( RANDOM % 10 )  + 1 ))
                echo
        done
done
echo
