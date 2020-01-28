#!/usr/bin/env bash

for i in {1..31}
do
    curl "http://content.guardianapis.com/tags?api-key=gnm-hackday-20&page-size=1000&type=contributor&page="$i |jq .response.results > contributors/$i.json
done
