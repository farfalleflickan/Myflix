#! /bin/bash

cd "$(dirname "$0")"
if [ "$#" -ne 1 ]; then
	echo "$0": usage: getMid.sh name.Of.Movie
	exit 1
fi

dMoImg=false
dMoFolder=../MoImg/
imgResizeMo="-resize 500x"
tinyPNGapi=""
TMDBapi=""
compressImgMo=false
. config.cfg
if [[ ! -z "$TMDBapi" ]]; then
	movie=${1}
    movie=${movie//./%20}
    myUrl="https://api.themoviedb.org/3/search/movie?api_key="$TMDBapi"&language=en-US&query="$movie"&page=1&include_adult=false"
    tmdbID=$(curl -s --request GET --url $myUrl | jq -r 'if ."total_results">0 then .results[0].id else "null" end')

	if [[ $tmdbID != "null" ]]; then
		myUrl="https://api.themoviedb.org/3/movie/"$tmdbID"/external_ids?api_key="$TMDBapi
	    output=$(curl -s --request GET --url $myUrl | jq -r 'if has("imdb_id") then .imdb_id else "null" end')
		if [[ $output != "null" ]]; then
			output=$(echo $output | sed 's/^.\{2\}//')
		else
			myUrl="https://api.themoviedb.org/3/search/movie?api_key="$TMDBapi"&language=en-US&query="$movie"&page=1&include_adult=false"
			tmdbID=$(curl -s --request GET --url $myUrl | jq -r 'if ."total_results">1 then .results[1].id else "null" end')
			myUrl="https://api.themoviedb.org/3/movie/"$tmdbID"/external_ids?api_key="$TMDBapi
			if [[ $tmdbID != "null" ]]; then
				output=$(curl -s --request GET --url $myUrl --data '{}' | jq -r 'if has("imdb_id") then .imdb_id else "null" end')
				if [[ $output != "null" ]]; then
		            output=$(echo $output | sed 's/^.\{2\}//')
				fi
			fi
		fi
		echo $output
		exit;
    else # uses very rudimental grep to parse the html of the IMDB search page
	    output=""
    	movie=${1}
	    movie=${movie//./+}
    	output=$(curl -s "https://www.imdb.com/find?ref_=nv_sr_fn&q="${movie}"&s=all" | grep '<td class="result_text"> <a href="/title/' | head -n1 )
	    output=${output#<tr class=\"findResult odd\"> <td class=\"primary_photo\"> <a href=\"/title/tt}
    	output=${output%%/?ref*}
    	echo $output #returns empty string if not found
		exit;
	fi
else # uses very rudimental grep to parse the html of the IMDB search page
	output=""
	movie=${1}
	movie=${movie//./+}
	output=$(curl -s "https://www.imdb.com/find?ref_=nv_sr_fn&q="${movie}"&s=all" | grep '<td class="result_text"> <a href="/title/' | head -n1 )
	output=${output#<tr class=\"findResult odd\"> <td class=\"primary_photo\"> <a href=\"/title/tt}
	output=${output%%/?ref*}
	output=${output:0:7} #trims to the id 
	echo $output #returns empty string if not found
	exit;
fi

