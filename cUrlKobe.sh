#!/bin/bash
# 靠北工程師
# 簡單用lynx 
#  lynx --dump -width=160 http://wttr.in/taipei 

curl curl.kobe.ga/img -d "msg=$((lynx --dump -width=160 http://wttr.in/taipei | head -n 7  && echo "程序組合 By Joe Yue" ) | sed ':a;N;$!ba;s/\n/%0a/g')"

lynx -display_charset=utf-8 --dump -width=128 http://wttr.in/new_taipei_city |  \
convert -background none -undercolor black -fill white -page 1024x900 \
-trim +repage -pointsize 12 -font ./dejavu-fonts-ttf-2.35/ttf/DejaVuSansMono.ttf \
text:- -bordercolor black  -border 3 text_manpage.gif


lynx -display_charset=utf-8 --dump -width=128 http://wttr.in/new_taipei_city | \
head -n 37 | \
convert -background none -undercolor black \
-fill white -trim +repage -pointsize 12 \
-font ./dejavu-fonts-ttf-2.35/ttf/DejaVuSansMono-Bold.ttf \
label:@- -bordercolor black  -border 10 ~/text_manpage.gif
