#! /bin/bash

cd "$(dirname "$0")"
dbNameTV="../dbTV.json"
TVhtml=../TV.html
. config.cfg

myID=${1}
i=${2}
myAlt=$(echo ${i} | sed "s/'//g") #strips single quotes from the Show string
myAlt=$(echo ${myAlt} | sed "s/\"//g") #strips double guotes from the Show string
myImg=$(jq -r "map(select(.Show | contains(\"${i}\")) .Poster) | .[]" $dbNameTV)
htmlStr+="<div class=\"showDiv\">\n<input id=\"A${myID}\" class=\"myBtn\" onclick=\"javascript:showModal(this)\" type=\"image\" src=\"${myImg}\" onload=\"javascript:setAlt(this, '${myAlt}')\">"
htmlStr+="\n<div id=\"B${myID}\" class=\"modal\">\n<div class=\"modal-content\">"
numSeasons=$(jq -r "map(select(.Show | contains(\"${i}\")) .Seasons) | .[]" $dbNameTV) 
myEpisodes=($(jq -r "map(select(.Show | contains(\"${i}\")) .Episodes[].File) | .[]" $dbNameTV)) #creates an array with all the filepaths for all the episodes
numEpisodes=${#myEpisodes[@]} #gets array size
htmlStr+="\n<span onclick=\"javascript:hideModal()\" class=\"close\">&times;</span>\n<select id=\"selector${myID}_\" onchange=\"javascript:changeSeason(this)\" class=\"showSelect\">"
seasonNum=0   
while [[ $seasonNum -lt $numSeasons ]]; do #adds a option for every season of the tv show
    ((seasonNum++))
    htmlStr+="\n<option value=\"${seasonNum}\">Season $seasonNum</option>" #Season select options
done
seasonNum=1 #number of current season being worked on
htmlStr+="\n</select>\n<ul id=\"C${myID}_${seasonNum}\" class=\"showEpUl\">"
epNum=0 #start of Episodes object array in json database
realEpNum=1 #actual episode number, 
while [[ $epNum -le $numEpisodes ]] && [[ $seasonNum -le $numSeasons ]]; do
    episode=$(jq -r "map(select(.Show | contains(\"${i}\")) .Episodes[${epNum}].File) | .[]" $dbNameTV)
    if [[ $episode == *"Season."$seasonNum* ]] || [[ $episode == *"S0"$seasonNum* ]] || [[ $episode == *"S"$seasonNum* ]]; then #if the episode file path contains the current season
        name=$(jq -r "map(select(.Show | contains(\"${i}\")) .Episodes[${epNum}].Title) | .[]" $dbNameTV)
        if [[ -z $name ]]; then #if episode has no episode name sets the name to "S(number of the season)E(number of the episode)"
            name="S${seasonNum}E${realEpNum}";
        fi
        mySub=($(jq -r "map(select(.Show | contains(\"${i}\")) .Episodes[${epNum}].Subs[].subFile) | .[]" $dbNameTV)) #creates array with path to all subtitles
        mySubNum=${#mySub[@]} #gets array size
        tempIndex=0;
        tempHtmlStr="";
        subsStr="";
        if [ $mySubNum -ge 1 ]; then #if there are subtitles
            while [ $tempIndex -lt $mySubNum ]; do #loops through the available subtitles
                myLang=($(jq -r "map(select(.Show | contains(\"${i}\")) .Episodes[${epNum}].Subs[${tempIndex}].lang) | .[]" $dbNameTV))
                myLabel=($(jq -r "map(select(.Show | contains(\"${i}\")) .Episodes[${epNum}].Subs[${tempIndex}].label) | .[]" $dbNameTV))
                subsStr+="\n<track src='' kind=\"subtitles\" srclang=\"${myLang}\" label=\"${myLabel}\">"
                tempSub=${mySub[${tempIndex}]} #gets subtitle path 
                tempSub=$(sed s/\'/"\\\'"/ <<< $tempSub) #escpaes single quotes, so ' becomes \' and doesn't mess up the html
                tempHtmlStr+=${tempSub}"," #path to the sub, to be fed to JS function that loads it in if needed
                ((tempIndex++))
            done
            #different JS function to use when user selects episode
            htmlStr+="\n<li>\n<input id=\"D${myID}_${epNum}\" class=\"epButton\" onclick=\"javascript:showVideoModalsetSubs(this,'"${tempHtmlStr}"')\" type=\"button\" value=\"${name}\" >\n"
        else #no subtitles, different JS function to use when user selects episode, so different code
            htmlStr+="\n<li>\n<input id=\"D${myID}_${epNum}\" class=\"epButton\" onclick=\"javascript:showVideoModal(this)\" type=\"button\" value=\"${name}\" >\n"
        fi
        htmlStr+="<div id=\"E${myID}_${epNum}\" class=\"modal\">\n<div class=\"modal-content\">"
        htmlStr+="\n<video id=\"F${myID}_${epNum}\" class=\"video_player\" controls preload=\"none\">\n<source src=\"${episode}\" type=\"video/mp4\">"
        htmlStr+=${subsStr}; #appends subs, is empty if there aren't any
        htmlStr+="\n</video>\n<span onclick=\"javascript:hideVideoModal()\" class=\"close\">&times;</span>\n<div class=\"nextEpDiv\">\n<input class=\"nextEpButton\" onclick=\"javascript:resetPlayer()\" type=\"button\" value=\"Reset Player\">\n<input class=\"prevEpButton\" onclick=\"javascript:prevEp()\" type=\"button\" value=\"Prev episode\" >\n<input class=\"nextEpButton\" onclick=\"javascript:nextEp()\" type=\"button\" value=\"Next episode\">\n<label class=\"autoButtonLabel\">\n<input class=\"autoButton\" onclick=\"javascript:autoSwitch()\" type=\"checkbox\" value=\"Automatic\">Automatic</label>\n</div>\n</div>\n</div>\n</li>"
        ((realEpNum++))
        ((epNum++))
    else #the episode file path did not contain the current season, so go to next season
        ((seasonNum++)) 
        htmlStr+="\n</ul>\n<ul id=\"C${myID}_${seasonNum}\" class=\"showEpUl\">"
        realEpNum=1
    fi
    #echo -e $htmlStr >> $TVhtml # appends the html created in the loop to the total html
    #htmlStr=""
done
htmlStr+="\n</ul>\n</div>\n</div>\n</div>"
echo -e $htmlStr