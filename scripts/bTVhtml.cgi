#! /bin/bash


cd "$(dirname "$0")"
dbNameTV="../dbTV.json"

. config.cfg

printf "<!DOCTYPE html>\n<html>\n<head>\n<title>Myflix</title>\n<meta charset=\"UTF-8\">\n<meta name=\"description\" content=\"Dario Rostirolla\">\n<meta name=\"keywords\" content=\"HTML, CSS\">\n<meta name=\"author\" content=\"Dario Rostirolla\">\n<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">\n<link href=\"css/tv.css\" rel=\"stylesheet\" type=\"text/css\">\n<link rel=\"icon\" type=\"image/png\" href=\"../img/favicon.png\">\n</head>\n<body>\n" > ../TV.html
myID=1
jq -r '.[].Show' $dbNameTV | while read i; do
	myImg=$(jq -r "map(select(.Show | contains(\"${i}\")) .Poster) | .[]" $dbNameTV)
	htmlStr="<div class=\"showDiv\">\n<input id=\"A${myID}\" class=\"myBtn\" onclick=\"javascript:showModal(this)\" type=\"image\" src=\"${myImg}\">"
	htmlStr+="\n<div id=\"B${myID}\" class=\"modal\">\n<div class=\"modal-content\">\n<span onclick=\"javascript:hideModal()\" class=\"close\">&times;</span>\n<select class=\"showSelect\">\n"
	numSeasons=$(jq -r "map(select(.Show | contains(\"${i}\")) .Seasons) | .[]" $dbNameTV)
	tempNum=0
	while [[ $tempNum -lt $numSeasons ]]; do
		((tempNum++))
		htmlStr+="<option value=\"${tempNum}\">Season $tempNum</option>\n"
	done
	htmlStr+="</select>\n</div>\n</div>\n</div>"
	echo -e $htmlStr >> ../TV.html
	((myID++))
done
echo -e '<script async type="text/javascript" src="js/cript.js"></script>\n</body>\n</html>' >> ../TV.html

chmod 755 ../TV.html;
