#! /bin/bash
TVpath=../TV/;
MoviesPath=../Movies/;

if [ "$#" -ne 1 ]; then
    echo "${0}: usage: buildHtmls.cgi (1 for movies | 2 for tv shows | 3 for both )"
    exit 1
fi

cd "$(dirname "$0")"
. config.cfg

case "${1}" in
"1")
	./bMhtml.cgi;;
"2")
	./bTVhtml.cgi;;
"3")
	./bMhtml.cgi
	./bTVhtml.cgi;;
*)
	echo "Invalid input, use: #1 for only movies, #2 for only tv shows and #3 for both";;
esac

echo "Done building HTML"
