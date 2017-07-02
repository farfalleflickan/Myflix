#! /bin/bash
TVpath=../TV/;
MoviesPath=../Movies/;

. config.cfg
find $MoviesPath -iname "*.mp4" -exec ./parseMfilename.cgi {} \;
find $TVpath -iname "*.mp4" -exec ./parseTVfilename.cgi {} \;
