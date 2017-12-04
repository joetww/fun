#!/bin/sh

SISBASEURL="http://sis001.com/forum/"
SISURL="${SISBASEURL}forumdisplay.php?fid=25&filter=86400&orderby=dateline&ascdesc=DESC"
CURL="$(which curl) -s --header \"User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.89 Safari/537.36\""
XMLLINT=$(which xmllint)
FIRSTPAGE=$(echo "${CURL} \"${SISURL}\"" | bash | ${XMLLINT} --html --xpath '//html' - 2>/dev/null)
VIEWTHREAD=$(echo ${FIRSTPAGE} | ${XMLLINT} --html --xpath '//*[@id="wrapper"]/div[1]/div[5]/div/em' - 2>/dev/null | sed -e 's/<em>&#160;\([0-9]\+\)&#160;<\/em>/\1/')
THREADLIST=""
PAGE=$(expr ${VIEWTHREAD} / 50 + 1)
TORRENTDOWNLOAD=$(dirname "$0")/torrent/$(date +%Y%m%d%H)
mkdir -p ${TORRENTDOWNLOAD}
sleep $(( ( RANDOM % 2 )  + 1 ))
for ((i = 1; i <= PAGE; i++)); do
        echo "Page: $i"
        THREADLIST=${THREADLIST}$(echo "${CURL} \"${SISURL}&page=${i}\"" | bash | ${XMLLINT} --html --xpath '//td[@class="nums" and contains(., "GB")]/..//span/a/..' - 2>/dev/null )
        sleep $(( ( RANDOM % 2 )  + 1 ))
done

echo -e "${THREADLIST}" | iconv -f gbk -t utf8 | sed -e 's/<\/span><span/<\/span>\n<span/g'
for i in $(echo "${THREADLIST}" | ${XMLLINT} --html --xpath '//span/a/@href' - 2>/dev/null | sed -e 's/href=\"\([^"]\+\)\"/\1/g'); do
        echo "GoTo ${SISBASEURL}${i}"
        for j in $(echo "${CURL} \"${SISBASEURL}${i}\"" | bash | ${XMLLINT} --html --xpath '//a[contains(@href, "attachment.php")]/@href' - 2>/dev/null | sed -e 's/href=\"\([^"]\+\)\"/\1/'); do
                echo "Get Torrent From: ${SISBASEURL}${j}"
                FILENAME=$(echo "${CURL} -I \"${SISBASEURL}${j}\"" | bash | iconv -f gbk -t utf8 | \
                        grep 'Content-Disposition: attachment; filename=' | \
                        sed -e 's/Content-Disposition: attachment; filename="\([^"]\+\)"/\1/' | sed $'s/\r//' | \
                        perl -pe 'chomp if eof' )
                echo \"${FILENAME}\"
                echo "${CURL} \"${SISBASEURL}${j}\" -o \"${TORRENTDOWNLOAD}/${FILENAME}\"" | bash
                sleep $(( ( RANDOM % 2 )  + 1 ))
        done
done

