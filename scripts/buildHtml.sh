#! /bin/bash

if [ "$#" -ne 1 ]; then
	echo "${0}: usage: buildHtmls.sh (1 for movies | 2 for tv shows | 3 for both )"
	exit 1
fi

cd "$(dirname "$0")"
TVpath=../TV/;
MoviesPath=../Movies/;
. config.cfg

case "${1}" in
	"1")	#build only movies
    if $homeMovies; then
        ./bHMhtml.sh;
    else
		./bMhtml.sh;
    fi
    ;;
	"2") 	#build only tv shows
		./bTVhtml.sh;;
	"3")	#build everything
		if $homeMovies; then
            ./bHMhtml.sh &
        else
            ./bMhtml.sh &
        fi
		pid1=$!
		./bTVhtml.sh &
		pid2=$!
		wait $pid1
		wait $pid2;;
	*)
		echo "Invalid input, use: #1 for only movies, #2 for only tv shows and #3 for both";;
esac
echo "Done building HTMLs"
