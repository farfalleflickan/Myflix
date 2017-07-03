#! /bin/bash
TVpath=../TV/;
MoviesPath=../Movies/;

cd "$(dirname "$0")"
. config.cfg

find $MoviesPath -iname "*.mp4" -exec ./parseMfilename.cgi {} \;
find $TVpath -iname "*.mp4" -exec ./parseTVfilename.cgi {} \;
