#! /bin/bash

# uses very rudimental grep to parse the html of the IMDB search page
cd "$(dirname "$0")"
if [ "$#" -ne 1 ]; then
	echo "$0": usage: getMid.sh name.Of.Movie
	exit 1
fi

movie=${1}
movie=${movie//./+}
output=$(curl -s "https://www.imdb.com/find?ref_=nv_sr_fn&q="${movie}"&s=all" | grep '<td class="result_text"> <a href="/title/' | head -n1 )
output=${output#<tr class=\"findResult odd\"> <td class=\"primary_photo\"> <a href=\"/title/tt}
output=${output%%/?ref*}
echo $output #returns empty string if not found

