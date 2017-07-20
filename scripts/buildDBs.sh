#! /bin/bash

if [ "$#" -ne 1 ]; then
	echo "${0}: usage: buildDBs.sh (1 for movies | 2 for tv shows | 3 for both )"
	exit 1
fi

cd "$(dirname "$0")"
TVpath=../TV/;
MoviesPath=../Movies/;
. config.cfg

case "${1}" in #switch case for the program's argument
	"1")
		#find all files that end in mp4 and executes parseMfilename.sh for every one of them, sequentially
		find $MoviesPath -iname "*.mp4" -exec ./parseMfilename.sh {} \; 
		;;
	"2")
		find $TVpath -name "*.mp4"| sort | while read file; do #sorts filenames and iterates through them
			./parseTVfilename.sh $file	#parses through $file, adds it to database
		done
		;;
	"3")
		find $MoviesPath -iname "*.mp4" -exec ./parseMfilename.sh {} \;
		find $TVpath -name "*.mp4"| sort | while read file; do #see above
			./parseTVfilename.sh $file
		done
		;;
	*)
		echo "Invalid input, use: #1 for only movies, #2 for only tv shows and #3 for both";;
esac
echo "Done building DBs"
