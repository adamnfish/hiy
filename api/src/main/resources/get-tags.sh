#!/usr/bin/env bash

for i in {1..38}
do
    curl "http://content.guardianapis.com/tags?api-key=gnm-hackday-20&page-size=1000&page="$i |jq .response.results > tags/$i.json
done
