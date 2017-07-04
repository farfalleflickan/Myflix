#! /bin/bash
TVpath=../TV/;
MoviesPath=../Movies/;

cd "$(dirname "$0")"
. config.cfg

find $MoviesPath -iname "*.mp4" -exec ./parseMfilename.cgi {} \;
find $TVpath -name "*.mp4"| sort | while read file; do
./parseTVfilename.cgi $file
done
