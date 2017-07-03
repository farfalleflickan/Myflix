#! /bin/bash


cd "$(dirname "$0")"
dbNameMovie="../dbM.json"
Mhtml=../Movies.html

. config.cfg

printf "<!DOCTYPE html>\n<html>\n<head>\n<title>Myflix</title>\n<meta charset=\"UTF-8\">\n<meta name=\"description\" content=\"Dario Rostirolla\">\n<meta name=\"keywords\" content=\"HTML, CSS\">\n<meta name=\"author\" content=\"Dario Rostirolla\">\n<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">\n<link href=\"css/movie.css\" rel=\"stylesheet\" type=\"text/css\">\n<link rel=\"icon\" type=\"image/png\" href=\"img/favicon.png\">\n</head>\n<body>\n" > $Mhtml
myID=1
jq -r '.[].Movie' $dbNameMovie | while read i; do
	myImg=$(jq -r "map(select(.Movie | contains(\"${i}\")) .Poster) | .[]" $dbNameMovie)
        myFile=$(jq -r "map(select(.Movie | contains(\"${i}\")) .File) | .[]" $dbNameMovie)
	htmlStr="<div class=\"movieDiv\">\n<input id=\"A${myID}\" class=\"myBtn\" onclick=\"javascript:showModal(this)\" type=\"image\" src=\"${myImg}\">"
	htmlStr+="\n<div id=\"B${myID}\" class=\"modal\">\n<div class=\"modal-content\">\n<video id=\"C${myID}\" class=\"video_player\" controls preload=\"none\">\n<source src=\"${myFile}\" type=\"video/mp4\">\n</video>\n<span onclick=\"javascript:hideModal()\" class=\"close\">&times;</span>\n"
	htmlStr+="</div>\n</div>\n</div>"
	echo -e $htmlStr >> $Mhtml
	((myID++))
done
echo -e '<script async type="text/javascript" src="js/cript.js"></script>\n</body>\n</html>' >> $Mhtml

chmod 755 $Mhtml
