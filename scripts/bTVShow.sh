#! /bin/bash

cd "$(dirname "$0")"
dbNameTV="../dbTV.json"
TVhtml="../TV.html"
. config.cfg

myID=${1}
i=${2}
myAlt=$(echo ${i} | sed "s/'//g") #strips single quotes from the Show string
myAlt=$(echo ${myAlt} | sed "s/\"//g") #strips double guotes from the Show string
myImg=$(jq -r "map(select(.Show==\"${i}\") .Poster) | .[]" $dbNameTV)

numSeasons=$(jq -r "map(select(.Show==\"${i}\") .Seasons) | .[]" $dbNameTV) 
myEpisodes=($(jq -r "map(select(.Show==\"${i}\") .Episodes[].File) | .[]" $dbNameTV)) #creates an array with all the filepaths for all the episodes
myExtras=($(jq -r "map(select(.Show==\"${i}\") .Extras[].File) | .[]" $dbNameTV))
numEpisodes=${#myEpisodes[@]} #gets array size
numExtras=${#myExtras[@]} #gets extra's array size
htmlStr+="<!DOCTYPE html><html><head><title>Myflix</title><meta http-equiv=\"Content-type\" content=\"text/html\;charset=UTF-8\"><meta name=\"description\" content=\"Daria Rostirolla\"><meta name=\"keywords\" content=\"HTML, CSS\"><meta name=\"author\" content=\"Daria Rostirolla\"><meta name=\"viewport\" content=\"width=device-width, initial-scale=1\"><link href=\"../css/tv.css\" rel=\"stylesheet\" type=\"text/css\"><link rel=\"icon\" type=\"image/png\" href=\"../img/favicon.png\"></head><body>\n<span onclick=\"javascript:hideModal()\" class=\"close\">&times;</span>\n<select id=\"selector${myID}_\" onchange=\"javascript:changeSeason(this)\" class=\"showSelect\">"
seasonNum=0
while [[ $seasonNum -lt $numSeasons ]]; do #adds a option for every season of the tv show
    ((seasonNum++))
    htmlStr+="\n<option value=\"${seasonNum}\">Season $seasonNum</option>" #Season select options
done
if [[ $numExtras -gt 0 ]]; then
    ((seasonNum++));
    htmlStr+="\n<option value=\"${seasonNum}\">Extras</option>"
fi
seasonNum=1 #number of current season being worked on
htmlStr+="\n</select>\n<ul id=\"C${myID}_${seasonNum}\" class=\"showEpUl\">"
epNum=0 #start of Episodes object array in json database
realEpNum=1 #actual episode number
while [[ $epNum -le $numEpisodes ]] && [[ $seasonNum -le $numSeasons ]]; do
    episode=$(jq -r "map(select(.Show==\"${i}\") .Episodes[${epNum}].File) | .[]" $dbNameTV)
    if [[ $episode == *"Season."$seasonNum* ]] || [[ $episode == *"S0"$seasonNum* ]] || [[ $episode == *"S"$seasonNum* ]]; then #if the episode file path contains the current season
        name=$(jq -r "map(select(.Show==\"${i}\") .Episodes[${epNum}].Title) | .[]" $dbNameTV)
        if [[ -z $name ]]; then #if episode has no episode name sets the name to "S(number of the season)E(number of the episode)"
            name="S${seasonNum}E${realEpNum}";
        fi
        mySub=($(jq -r "map(select(.Show==\"${i}\") .Episodes[${epNum}].Subs[].subFile) | .[]" $dbNameTV)) #creates array with path to all subtitles
        mySubNum=${#mySub[@]} #gets array size
        tempIndex=0;
        tempHtmlStr="";
        subsStr="";
        if [ $mySubNum -ge 1 ]; then #if there are subtitles
            while [ $tempIndex -lt $mySubNum ]; do #loops through the available subtitles
                myLang=($(jq -r "map(select(.Show==\"${i}\") .Episodes[${epNum}].Subs[${tempIndex}].lang) | .[]" $dbNameTV))
                myLabel=($(jq -r "map(select(.Show==\"${i}\") .Episodes[${epNum}].Subs[${tempIndex}].label) | .[]" $dbNameTV))
				if [ $tempIndex -eq 0 ]; then
	               	subsStr+="\n<track src='' kind=\"subtitles\" srclang=\"${myLang}\" label=\"${myLabel}\" default>"
				else
                	subsStr+="\n<track src='' kind=\"subtitles\" srclang=\"${myLang}\" label=\"${myLabel}\">"
				fi
                tempSub=${mySub[${tempIndex}]} #gets subtitle path 
                tempSub=$(sed s/\'/"\\\'"/ <<< $tempSub) 	#escpaes single quotes, so ' becomes \' and doesn't mess up the html
                tempHtmlStr+=${tempSub}"," #path to the sub, to be fed to JS function that loads it in if needed
                ((tempIndex++))
            done
            #different JS function to use when user selects episode
            htmlStr+="\n<li>\n<input id=\"D${myID}_${epNum}\" class=\"epButton\" onclick=\"javascript:showVideoModalsetSubs(this,'../"${tempHtmlStr}"')\" type=\"button\" value=\"${name}\" >\n"
        else #no subtitles, different JS function to use when user selects episode, so different code
            htmlStr+="\n<li>\n<input id=\"D${myID}_${epNum}\" class=\"epButton\" onclick=\"javascript:showVideoModal(this)\" type=\"button\" value=\"${name}\" >\n"
        fi
        htmlStr+="<div id=\"E${myID}_${epNum}\" class=\"modal\">\n<div class=\"modal-content\">"
		htmlStr+="<span onclick=\"javascript:hideVideoModal()\" class=\"close\">&times;</span>\n<p id=\"epTitle\">${name}</p>"
        htmlStr+="\n<video id=\"F${myID}_${epNum}\" class=\"video_player\" controls preload=\"none\" onplaying=\"javascript:rezHandler()\">\n<source src=\"../${episode}\" type=\"video/mp4\">"
        htmlStr+=${subsStr}; #appends subs, is empty if there aren't any
        htmlStr+="\n</video>\n<div class=\"nextEpDiv\">\n<input class=\"nextEpButton\" onclick=\"javascript:resetPlayer()\" type=\"button\" value=\"Reset Player\">\n<input class=\"prevEpButton\" onclick=\"javascript:prevEp()\" type=\"button\" value=\"Prev episode\" >\n<input class=\"nextEpButton\" onclick=\"javascript:nextEp()\" type=\"button\" value=\"Next episode\">\n<label class=\"autoButtonLabel\">\n<input class=\"autoButton\" onclick=\"javascript:autoSwitch()\" type=\"checkbox\" value=\"Automatic\">Automatic</label>\n</div>\n</div>\n</div>\n</li>"
        ((realEpNum++))
        ((epNum++))
    else #the episode file path did not contain the current season, so go to next season
        ((seasonNum++)) 
        htmlStr+="\n</ul>\n";
        if [[ $seasonNum -le $numSeasons ]]; then
            htmlStr+="<ul id=\"C${myID}_${seasonNum}\" class=\"showEpUl\">";
        fi
        realEpNum=1
    fi
done
# "Extras" stuff
extrasNum=0;
if [[ $extrasNum -lt $numExtras ]]; then
    htmlStr+="\n</ul>\n<ul id=\"C${myID}_${seasonNum}\" class=\"showEpUl\">"   
    while [[ $extrasNum -lt $numExtras ]]; do
        episode=$(jq -r "map(select(.Show==\"${i}\") .Extras[${extrasNum}].File) | .[]" $dbNameTV)
        name=$(jq -r "map(select(.Show==\"${i}\") .Extras[${extrasNum}].Title) | .[]" $dbNameTV)
        mySub=($(jq -r "map(select(.Show==\"${i}\") .Extras[${extrasNum}].Subs[].subFile) | .[]" $dbNameTV)) #creates array with path to all subtitles
        mySubNum=${#mySub[@]} #gets array size
        tempIndex=0;
        tempHtmlStr="";
        subsStr="";
        if [ $mySubNum -ge 1 ]; then #if there are subtitles
            while [ $tempIndex -lt $mySubNum ]; do #loops through the available subtitles
                myLang=($(jq -r "map(select(.Show==\"${i}\") .Extras[${extrasNum}].Subs[${tempIndex}].lang) | .[]" $dbNameTV))
                myLabel=($(jq -r "map(select(.Show==\"${i}\") .Extras[${extrasNum}].Subs[${tempIndex}].label) | .[]" $dbNameTV))
                if [ $tempIndex -eq 0 ]; then
                    subsStr+="\n<track src='' kind=\"subtitles\" srclang=\"${myLang}\" label=\"${myLabel}\" default>"
                else
                    subsStr+="\n<track src='' kind=\"subtitles\" srclang=\"${myLang}\" label=\"${myLabel}\">"
                fi
                tempSub=${mySub[${tempIndex}]} #gets subtitle path 
                tempSub=$(sed s/\'/"\\\'"/ <<< $tempSub) 	#escpaes single quotes, so ' becomes \' and doesn't mess up the html
                tempHtmlStr+=${tempSub}"," #path to the sub, to be fed to JS function that loads it in if needed
                ((tempIndex++))
            done
            #different JS function to use when user selects episode
            htmlStr+="\n<li>\n<input id=\"D${myID}_${epNum}\" class=\"epButton\" onclick=\"javascript:showVideoModalsetSubs(this,'../"${tempHtmlStr}"')\" type=\"button\" value=\"${name}\" >\n"
        else #no subtitles, different JS function to use when user selects episode, so different code
            htmlStr+="\n<li>\n<input id=\"D${myID}_${epNum}\" class=\"epButton\" onclick=\"javascript:showVideoModal(this)\" type=\"button\" value=\"${name}\" >\n"
        fi
        htmlStr+="<div id=\"E${myID}_${epNum}\" class=\"modal\">\n<div class=\"modal-content\">"
        htmlStr+="<span onclick=\"javascript:hideVideoModal()\" class=\"close\">&times;</span>\n<p id=\"epTitle\">${name}</p>"
        htmlStr+="\n<video id=\"F${myID}_${epNum}\" class=\"video_player\" controls preload=\"none\" onplaying=\"javascript:rezHandler()\">\n<source src=\"../${episode}\" type=\"video/mp4\">"
        htmlStr+=${subsStr}; #appends subs, is empty if there aren't any
        htmlStr+="\n</video>\n<div class=\"nextEpDiv\">\n<input class=\"nextEpButton\" onclick=\"javascript:resetPlayer()\" type=\"button\" value=\"Reset Player\">\n<input class=\"prevEpButton\" onclick=\"javascript:prevEp()\" type=\"button\" value=\"Prev episode\" >\n<input class=\"nextEpButton\" onclick=\"javascript:nextEp()\" type=\"button\" value=\"Next episode\">\n<label class=\"autoButtonLabel\">\n<input class=\"autoButton\" onclick=\"javascript:autoSwitch()\" type=\"checkbox\" value=\"Automatic\">Automatic</label>\n</div>\n</div>\n</div>\n</li>"
        ((extrasNum++))
        ((epNum++))
    done
fi
htmlStr+="\n</ul>\n</div>\n</div>\n<script async type=\"text/javascript\" src=\"../js/TVScript.js\" onload=\"javascript:showModal('selector${myID}_')\"></script></body></html>"
echo -e $htmlStr
