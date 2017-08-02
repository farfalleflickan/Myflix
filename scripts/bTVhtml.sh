#! /bin/bash

cd "$(dirname "$0")"
dbNameTV="../dbTV.json"
TVhtml=../TV.html
. config.cfg

printf "<!DOCTYPE html>\n<html>\n<head>\n<title>Myflix</title>\n<meta charset=\"UTF-8\">\n<meta name=\"description\" content=\"Dario Rostirolla\">\n<meta name=\"keywords\" content=\"HTML, CSS\">\n<meta name=\"author\" content=\"Dario Rostirolla\">\n<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">\n<link href=\"css/tv.css\" rel=\"stylesheet\" type=\"text/css\">\n<link rel=\"icon\" type=\"image/png\" href=\"img/favicon.png\">\n</head>\n<body>\n<script async type=\"text/javascript\" src=\"js/TVcript.js\"></script><div id=\"wrapper\">" > $TVhtml
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
tmpFileArray=()
IFS=$'\n' 
for i in $(jq -r '.[].Show' $dbNameTV); do #sets i to to the value of "Show", loops through every show in the database
    tmpfile=$(mktemp)
    ./bTVShow.sh $myID $i > $tmpfile &
    pidArray+=($!)
    tmpFileArray+=($tmpfile)
    ((myID++)) #change of show
done
numThreads=${#pidArray[@]}
tempIndex=0;
while [ $tempIndex -lt $numThreads ]; do
    wait ${pidArray[${tempIndex}]}
    cat "${tmpFileArray[${tempIndex}]}" >> $TVhtml
    rm "${tmpFileArray[${tempIndex}]}"
    ((tempIndex++))
done
echo -e '\n</div>\n</body>\n</html>' >> $TVhtml
chmod 755 $TVhtml
