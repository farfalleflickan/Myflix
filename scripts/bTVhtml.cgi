#! /bin/bash


cd "$(dirname "$0")"
dbNameTV="../dbTV.json"
TVhtml=../TV.html

. config.cfg

printf "<!DOCTYPE html>\n<html>\n<head>\n<title>Myflix</title>\n<meta charset=\"UTF-8\">\n<meta name=\"description\" content=\"Dario Rostirolla\">\n<meta name=\"keywords\" content=\"HTML, CSS\">\n<meta name=\"author\" content=\"Dario Rostirolla\">\n<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">\n<link href=\"css/tv.css\" rel=\"stylesheet\" type=\"text/css\">\n<link rel=\"icon\" type=\"image/png\" href=\"img/favicon.png\">\n</head>\n<body>\n<script async type=\"text/javascript\" src=\"js/TVcript.js\"></script>" > $TVhtml
myID=1
jq -r '.[].Show' $dbNameTV | while read i; do
myAlt=$(echo ${i} | sed "s/'//g")
myAlt=$(echo ${myAlt} | sed "s/\"//g")
myImg=$(jq -r "map(select(.Show | contains(\"${i}\")) .Poster) | .[]" $dbNameTV)
htmlStr="<div class=\"showDiv\">\n<input id=\"A${myID}\" class=\"myBtn\" onclick=\"javascript:showModal(this)\" type=\"image\" src=\"${myImg}\" onload=\"javascript:setAlt(this, '${myAlt}')\">"
htmlStr+="\n<div id=\"B${myID}\" class=\"modal\">\n<div class=\"modal-content\">"
numSeasons=$(jq -r "map(select(.Show | contains(\"${i}\")) .Seasons) | .[]" $dbNameTV)
myEpisodes=($(jq -r "map(select(.Show | contains(\"${i}\")) .Episodes[].File) | .[]" $dbNameTV))
numEpisodes=${#myEpisodes[@]}
htmlStr+="\n<span onclick=\"javascript:hideModal()\" class=\"close\">&times;</span>\n<select id=\"selector${myID}_\" onchange=\"javascript:changeSeason(this)\" class=\"showSelect\">"
tempNum=0    
while [[ $tempNum -lt $numSeasons ]]; do
	((tempNum++))
	htmlStr+="\n<option value=\"${tempNum}\">Season $tempNum</option>"
done
tempNum=1
htmlStr+="\n</select>\n<ul id=\"C${myID}_${tempNum}\" class=\"showEpUl\">"
epNum=0
realEpNum=1
while [[ $epNum -le $numEpisodes ]] && [[ $tempNum -le $numSeasons ]]; do
	episode=$(jq -r "map(select(.Show | contains(\"${i}\")) .Episodes[${epNum}].File) | .[]" $dbNameTV)
	if [[ $episode == *"Season."$tempNum* ]] || [[ $episode == *"S0"$tempNum* ]] || [[ $episode == *"S"$tempNum* ]]; then
		name=$(jq -r "map(select(.Show | contains(\"${i}\")) .Episodes[${epNum}].Title) | .[]" $dbNameTV)
		htmlStr+="\n<li>\n<input id=\"D${myID}_${epNum}\" class=\"epButton\" onclick=\"javascript:showVideoModal(this)\" type=\"button\" value=\"${name}\" >\n"
		htmlStr+="<div id=\"E${myID}_${epNum}\" class=\"modal\">\n<div class=\"modal-content\">"
		htmlStr+="\n<video id=\"F${myID}_${epNum}\" class=\"video_player\" controls preload=\"none\">\n<source src=\"${episode}\" type=\"video/mp4\">\n</video>\n<span onclick=\"javascript:hideVideoModal()\" class=\"close\">&times;</span>\n<div class=\"nextEpDiv\">\n<input class=\"prevEpButton\" onclick=\"javascript:prevEp()\" type=\"button\" value=\"Prev episode\" >\n<input class=\"nextEpButton\" onclick=\"javascript:nextEp()\" type=\"button\" value=\"Next episode\">\n<label class=\"autoButtonLabel\">\n<input class=\"autoButton\" onclick=\"javascript:autoSwitch()\" type=\"checkbox\" value=\"Automatic\">Automatic</label>\n</div>\n</div>\n</div>\n</li>"
		((realEpNum++))
                ((epNum++))
	else
		((tempNum++))
		htmlStr+="\n</ul>\n<ul id=\"C${myID}_${tempNum}\" class=\"showEpUl\">"
		realEpNum=1
	fi
done
htmlStr+="\n</ul>\n</div>\n</div>\n</div>"
echo -e $htmlStr >> $TVhtml
((myID++))
done
echo -e '\n</body>\n</html>' >> $TVhtml

chmod 755 $TVhtml
