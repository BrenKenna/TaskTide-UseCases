#!/bin/bash


# Rollback to a specific commit
git reset --hard d97a07a
git add .
git commit -m "Rolled back for alternate workflow"


# Run image
docker container run  -p 27017:27017 mongo:latest


# Run image
docker container run -e COUCHDB_USER=admin -e COUCHDB_PASSWORD=password -p 5984:5984 couchdb:latest

curl -X PUT http://admin:password@localhost:5984/tasktide_database

curl -X GET http://admin:password@localhost:5984/_all_dbs

curl -X GET http://admin:password@localhost:5984/tasktide_database/_all_docs



curl -v \
  -X GET \
  http://localhost:8080/services/step/get?id=Step-940d4f81-9636-439b-86ea-eed198bee09b


curl -v \
  -X DELETE \
  http://localhost:8080/services/step/drop/Step-4de8b16d-6fcf-44b0-a8e2-7e8aaad05f6b


curl -v \
  -X POST \
  http://localhost:8080/services/step/create-step?stepName="doggie"
