#! /bin/bash

cd "$(dirname "$0")"
if [ "$#" -eq 0 ]; then
	echo "$0": usage: getMid.cgi nameOfMovie
	exit 1
fi

movie=${1}
movie=${movie//./+}
output=$(curl -s "http://www.imdb.com/find?ref_=nv_sr_fn&q="${movie}"&s=all" | grep '<tr class="findResult odd"> <td class="primary_photo"> <a href="/title/' | head -n1 )
output=${output#<tr class=\"findResult odd\">\ <td class=\"primary_photo\">\ <a href=\"/title/tt}
output=${output%%/?ref*}
echo $output

