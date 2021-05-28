#! /bin/bash

cd "$(dirname "$0")"
dbNameMovie="../dbM.json"
Mhtml=../Movies.html
dMoImg=false
dMoFolder=../MoImg/
imgResizeMo="-resize 500x"
tinyPNGapi=""
compressImgMo=false
. config.cfg

printf "<!DOCTYPE html>\n<html>\n<head>\n<title>Myflix</title>\n<meta charset=\"UTF-8\">\n<meta name=\"description\" content=\"Dario Rostirolla\">\n<meta name=\"keywords\" content=\"HTML, CSS\">\n<meta name=\"author\" content=\"Dario Rostirolla\">\n<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">\n<link href=\"css/movie.css\" rel=\"stylesheet\" type=\"text/css\">\n<link rel=\"icon\" type=\"image/png\" href=\"img/favicon.png\">\n</head>\n<body>\n<script async type=\"text/javascript\" src=\"js/Mcript.js\"></script><div id=\"wrapper\">" > $Mhtml 
#html specific id given to elements 
# A+myID identifies the movie's "input button"
# B+myID identifies the movie's modal
# C+myID identifies the movie's video player
myID=1
IFS=$'\n'
MovieList=$(jq -r '.[].Movie' $dbNameMovie); #puts all movie titles in "MovieList variable
for i in $MovieList; do #loops through every movie in the database
	myImg=$(jq -r "map(select(.Movie==\"${i}\") .Poster) | .[]" $dbNameMovie)
	myFile=$(jq -r "map(select(.Movie==\"${i}\") .File) | .[]" $dbNameMovie)
	mySub=($(jq -r "map(select(.Movie==\"${i}\") .Subs[].subFile) | .[]" $dbNameMovie))
	mySubNum=${#mySub[@]}
	myAlt=$(echo ${i%.*} | sed "s/'//")
	htmlStr="<div class=\"movieDiv\">\n"
    	htmlStr+="<div class=\"HM_textContainer\"><div class=\"HM_text\">${i%.*}</div>"
    	htmlStr+="<input id=\"A${myID}\" class=\"myBtn\" value=\"\" onclick=\"javascript:showModal(this)\" type=\"image\" src=\"${myImg}\" onload=\"javascript:setAlt(this, '${myAlt}')\">"
	htmlStr+="\n<div id=\"B${myID}\" class=\"modal\">\n<div class=\"modal-content\">\n<video id=\"C${myID}\" class=\"video_player\" controls preload=\"none\">\n<source src=\"${myFile}\" type=\"video/mp4\">";
	htmlStr+=$tempHtml;
	htmlStr+="\n</video>\n<span onclick=\"javascript:hideModal()\" class=\"close\">&times;</span>\n";
	htmlStr+="</div>\n</div>\n</div>\n</div>";
	echo -e $htmlStr >> $Mhtml;
	htmlStr="";
	((myID++));
done
echo -e '\n<div id="paddingDiv">\n</div>\n</div>\n</body>\n</html>' >> $Mhtml
chmod 755 $Mhtml
