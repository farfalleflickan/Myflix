#! /bin/bash

cd "$(dirname "$0")"
dbNameTV="../dbTV.json"
TVhtml="../TV.html"
. config.cfg

printf "<!DOCTYPE html>\n<html>\n<head>\n<title>Myflix</title>\n<meta http-equiv=\"Content-type\" content=\"text/html\;charset=UTF-8\">\n<meta name=\"description\" content=\"Daria Rostirolla\">\n<meta name=\"keywords\" content=\"HTML, CSS\">\n<meta name=\"author\" content=\"Daria Rostirolla\">\n<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">\n<link href=\"css/tv.css\" rel=\"stylesheet\" type=\"text/css\">\n<link rel=\"icon\" type=\"image/png\" href=\"img/favicon.png\">\n</head>\n<body>\n<script type=\"text/javascript\" src=\"js/MainTVScript.js\"></script>\n<div id=\"wrapper\">\n" > $TVhtml
#html specific, per show specific, id given to elements 
# A+myID identifies the show's "input button"
# B+myID identifies the show's modal
# selector+myID+_ identifies the show's season selector
# C+myID+_+(number of season) identifies the ul for that season's episodes
# D+myID+_+(number of episode) identifies the episode's li
# E+myID+_+(number of episode) identifies the episode's modal
# F+myID+_+(number of episode) identifies the episode's video player
myID=1
pidArray=() 
IFS=$'\n' 
myHtmlShow_Folder=$(echo "${TVhtml/\.html/ShowHtml}") 
if [[ ! -e $myHtmlShow_Folder ]]; then
    mkdir $myHtmlShow_Folder
fi
for i in $(jq -r '.[].Show' $dbNameTV); do #sets i to to the value of "Show", loops through every show in the database
	myAlt=$(echo ${i} | sed "s/'//g") #strips single quotes from the Show string
	myAlt=$(echo ${myAlt} | sed "s/\"//g") #strips double guotes from the Show string
	myImg=$(jq -r "map(select(.Show==\"${i}\") .Poster) | .[]" $dbNameTV)
	if [[ $myImg != *".jpg"*  ]]; then #if missing poster, generates one
        myImg="";
        UUID="rangen_"$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)".jpg";
        currentShow=$(jq -r "map(select(.Show==\"${i}\") .Episodes[0].File) | .[]" $dbNameTV)
		if [ ! -d "$dTVFolder" ]; then #creates foldser if missing
			mkdir $dTVFolder
		fi
		if [ ${#AutogenImgResizeTV[@]} -gt 0 ]; then
			convert "${AutogenImgResizeTV[@]}" -annotate 0 "${i}" $dTVFolder$UUID;
        fi	
		chmod 755 -R $dTVFolder 
		tempFolder=$(basename $dTVFolder)
		myImg=$tempFolder"/"$UUID;
        $(./fixFile.sh $currentShow $myID $myImg);
	fi
	myTempName=$(echo ${myAlt} | sed 's/ //g')
	myTempName=${myTempName#../}
	myHtmlShow=$myTempName".html"
	myHtmlShow=$(echo "${TVhtml/\.html/$myHtmlShow}")
    myHtmlShow=${myHtmlShow#../}
    myShowPath=$myHtmlShow_Folder"/"$myHtmlShow
    myShowPath=${myShowPath#../}
    
	printf "<div class=\"showDiv\">\n<input id=\"A${myID}\" class=\"myBtn\" value=\"\" onclick=\"javascript:setFrame(this, '${myShowPath}' )\" type=\"image\" src=\"${myImg}\" onload=\"javascript:setAlt(this, '${myAlt}')\">\n<div id=\"B${myID}\" class=\"modal\">\n<div id=\"frameDiv${myID}\" class=\"modal-content\">\n<iframe id=\"IN${myID}\" src=\"\" frameborder=\"0\" onload=\"javascript:resizeFrame(this)\" allowfullscreen></iframe>\n</div>\n</div>\n</div>\n" >> $TVhtml
    ./bTVShow.sh $myID $i > "../"$myShowPath &
    pidArray+=($!)
    ((myID++)) #change of show
done
numThreads=${#pidArray[@]}
tempIndex=0;
while [ $tempIndex -lt $numThreads ]; do
    wait ${pidArray[${tempIndex}]}
    ((tempIndex++))
done
echo -e '\n<div id="paddingDiv">\n</div>\n</div>\n</body>\n</html>' >> $TVhtml
chmod 755 $TVhtml
chmod 755 -R $myHtmlShow_Folder
