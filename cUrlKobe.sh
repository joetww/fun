#!/bin/bash
#靠北工程師

curl curl.kobe.ga/img -d "msg=$((lynx --dump -width=160 http://wttr.in/taipei | head -n 7  && echo "程序組合 By Joe Yue" ) | sed ':a;N;$!ba;s/\n/%0a/g')"
