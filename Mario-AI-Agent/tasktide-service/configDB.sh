#!/bin/bash

set -x

apt-get update -y > /dev/null
apt-get install -y curl jq > /dev/null

# PASSWORD=$(cat /run/secrets/couchdbPass)


# Wait to couchdb to be provisioned
echo "Waiting for couchdb..."
until curl -u "admin:password" -fs http://couchdb:5984/ > /dev/null
do
    sleep 1
done


# Create database
echo "Creating database..."
curl -u "admin:password" -X PUT http://couchdb:5984/tasktide_database  | jq '.'


# Create indexes
echo "Creating indexes..."
sleep 1
jq -r 'keys[]' /opt/indexes.json | while read name
do
    echo "Indexing:\\t$name"
    fields=$(jq -c --arg n "$name" '.[$n]' /opt/indexes.json | jq .fields)
    curl -u "admin:password" -v -H "Content-Type: application/json" \
        -X POST http://couchdb:5984/tasktide_database/_index \
        -d "$(jq -n \
            --arg name "$name" \
            --argjson fields "$(jq -c --arg n "$name" '.[$n].fields' /opt/indexes.json)" \
            '{
                index: { fields: $fields },
                name: $name,
                type: "json"
            }')" | jq '.'
    sleep 1
done
echo "Done."