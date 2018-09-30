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
		find $MoviesPath  -not -path '*/.*/*' -not -name '.*' -iname "*.mp4" -exec ./parseMfilename.sh {} \;
		./sortByName.sh ${1}
		;;
	"2")
		find $TVpath -not -path '*/.*/*' -not -name '.*' -name "*.mp4"| sort | while read file; do #sorts filenames and iterates through them
                    if [ ! -f $dbNameTV ]; then #creates the dbfile if missing
                        touch $dbNameTV;
                    fi
                    fileName=${file#../}
                    isPresent=$(grep -c "${fileName}" $dbNameTV)
                    if [ "$isPresent" -eq "0" ]; then #check if file is already present in database
	                ./parseTVfilename.sh $file	#parses through $file, adds it to database
                    fi
		done
		./sortByName.sh ${1}
		;;
	"3")
		find $MoviesPath -not -path '*/.*/*' -not -name '.*' -iname "*.mp4" -exec ./parseMfilename.sh {} \; &
		pid1=$!
		find $TVpath -not -path '*/.*/*' -not -name '.*' -name "*.mp4"| sort | while read file; do #see above
			if [ ! -f $dbNameTV ]; then #creates the dbfile if missing
            	touch $dbNameTV;
            fi
			fileName=${file#../}
            isPresent=$(grep -c "${fileName}" $dbNameTV)
            if [ "$isPresent" -eq "0" ]; then #check if file is already present in database
            	./parseTVfilename.sh $file	#parses through $file, adds it to database
            fi
		done
		wait $pid1;
		./sortByName.sh ${1}
		;;
	*)
		echo "Invalid input, use: #1 for only movies, #2 for only tv shows and #3 for both";;
esac
echo "Done building DBs"
