#!/bin/bash
#youtube-dl http://youtube-dl.org/
#新版的youtube-dl 參數-b被拿掉囉，所以若是不能使用請自己修正

url="https://youtu.be/uuwfgXD8qV8" && \
wget -q -O - `youtube-dl -b -g ${url}`| \
ffmpeg -i - -f mp3 -vn -acodec libmp3lame -| \
mpg123  -
