#!/bin/sh
set -e

PASSWORD=$(cat /run/secrets/couchDbPass)

echo "Waiting for CouchDB..."

until curl -fs http://couchDB:5984/ >/dev/null
do
    sleep 1
done

echo "Creating indexes..."

jq -r 'keys[]' indexes.json | while read name
do
    echo "Indexing:\\t$name"
    fields=$(jq -c --arg n "$name" '.[$n]' indexes.json)
    curl -u admin:$PASSWORD \
        -H "Content-Type: application/json" \
        -X POST http://couchDB:5984/tasktide_database/_index \
        -d "$(jq -n \
            --arg name "$name" \
            --argjson fields "$fields" \
            '{index:{fields:$fields},name:$name,type:"json"}')"
done

echo "Done."