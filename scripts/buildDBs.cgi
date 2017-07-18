#! /bin/bash
TVpath=../TV/;
MoviesPath=../Movies/;

if [ "$#" -ne 1 ]; then
    echo "${0}: usage: buildDBs.cgi (1 for movies | 2 for tv shows | 3 for both )"
    exit 1
fi

cd "$(dirname "$0")"
. config.cfg

case "${1}" in
"1")
	find $MoviesPath -iname "*.mp4" -exec ./parseMfilename.cgi {} \;
	;;
"2")
	find $TVpath -name "*.mp4"| sort | while read file; do
    	./parseTVfilename.cgi $file
	done
	;;
"3")
	find $MoviesPath -iname "*.mp4" -exec ./parseMfilename.cgi {} \;
	find $TVpath -name "*.mp4"| sort | while read file; do
        ./parseTVfilename.cgi $file
    done
	;;
*)
	echo "Invalid input, use: #1 for only movies, #2 for only tv shows and #3 for both";;
esac

echo "Done building DBs"
