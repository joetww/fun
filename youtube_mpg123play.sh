#!/bin/bash
url="https://youtu.be/uuwfgXD8qV8" && \
wget -q -O - `youtube-dl -b -g ${url}`| \
ffmpeg -i - -f mp3 -vn -acodec libmp3lame -| \
mpg123  -
