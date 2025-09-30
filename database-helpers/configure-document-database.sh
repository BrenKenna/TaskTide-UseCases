#!/bin/bash

###############################################################################
###############################################################################
## 
## 1). Setup Backend for Testing
## 
###############################################################################
###############################################################################

##############################################################
##############################################################
## 
## a). Document Databases
##
##  => Mongo storates
##  => Other two have their prop as a null
## 
##############################################################
##############################################################


##################################
##################################
##
## i). couchDB
##
##################################
##################################

# Run image
docker container run -e COUCHDB_USER=admin -e COUCHDB_PASSWORD=password -p 5984:5984 couchdb:latest

curl -X PUT http://admin:password@localhost:5984/tasktide_database

curl -X GET http://admin:password@localhost:5984/_all_dbs

curl -X GET http://admin:password@localhost:5984/tasktide_database/_all_docs


#########################
#########################
##
## WorkItem Indexes
##
#########################
#########################

# Create index
curl --silent \
    -X POST http://admin:password@localhost:5984/tasktide_database/_index \
    -H "Content-Type: application/json" \
    -d '{
        "index": {
            "fields": [
                "@entity"
            ]
        },
        "name": "entity_index",
        "type": "json"
    }'


curl --silent \
    -X POST http://admin:password@localhost:5984/tasktide_database/_index \
    -H "Content-Type: application/json" \
    -d '{
        "index": {
            "fields": [
                "@entity",
                "StepName"
            ]
        },
        "name": "workItemStepIndex",
        "type": "json"
    }'


curl --silent \
    -X POST http://admin:password@localhost:5984/tasktide_database/_index \
    -H "Content-Type: application/json" \
    -d '{
        "index": {
            "fields": [
                "@entity",
                "StepId"
            ]
        },
        "name": "workItemStepIdIndex",
        "type": "json"
    }'


curl --silent \
    -X POST http://admin:password@localhost:5984/tasktide_database/_index \
    -H "Content-Type: application/json" \
    -d '{
        "index": {
            "fields": [
                "@entity",
                "ItemState"
            ]
        },
        "name": "workItemStateIndex",
        "type": "json"
    }'


curl --silent \
    -X POST http://admin:password@localhost:5984/tasktide_database/_index \
    -H "Content-Type: application/json" \
    -d '{
        "index": {
            "fields": [
                "@entity",
                "StepName",
                "ItemState"
            ]
        },
        "name": "workItemStepNameStateIndex",
        "type": "json"
    }'


curl --silent \
    -X POST http://admin:password@localhost:5984/tasktide_database/_index \
    -H "Content-Type: application/json" \
    -d '{
        "index": {
            "fields": [
                "@entity",
                "StepId",
                "ItemState"
            ]
        },
        "name": "workItemStepIdStateIndex",
        "type": "json"
    }'


curl --silent \
    -X POST http://admin:password@localhost:5984/tasktide_database/_index \
    -H "Content-Type: application/json" \
    -d '{
        "index": {
            "fields": [
                "@entity",
                "JobEnvironmentId"
            ]
        },
        "name": "entityJobEnvIndex",
        "type": "json"
    }'


curl --silent \
    -X POST http://admin:password@localhost:5984/tasktide_database/_index \
    -H "Content-Type: application/json" \
    -d '{
        "index": {
            "fields": [
                "@entity",
                "StepName",
                "JobEnvironmentId"
            ]
        },
        "name": "workItemStepNameJobEnvIdIndex",
        "type": "json"
    }'

curl --silent \
    -X POST http://admin:password@localhost:5984/tasktide_database/_index \
    -H "Content-Type: application/json" \
    -d '{
        "index": {
            "fields": [
                "@entity",
                "StepId",
                "JobEnvironmentId"
            ]
        },
        "name": "workItemStepIdJobEnvIdIndex",
        "type": "json"
    }'



#########################
#########################
##
## Workflow Indexes
##
#########################
#########################


curl --silent \
    -X POST http://admin:password@localhost:5984/tasktide_database/_index \
    -H "Content-Type: application/json" \
    -d '{
        "index": {
            "fields": [
                "@entity",
                "WorkflowName"
            ]
        },
        "name": "workflowNameIndex",
        "type": "json"
    }'



#########################
#########################
##
## Step Indexes
##
#########################
#########################


curl --silent \
    -X POST http://admin:password@localhost:5984/tasktide_database/_index \
    -H "Content-Type: application/json" \
    -d '{
        "index": {
            "fields": [
                "@entity",
                "StepName"
            ]
        },
        "name": "stepNameIndex",
        "type": "json"
    }'


curl --silent \
    -X POST http://admin:password@localhost:5984/tasktide_database/_index \
    -H "Content-Type: application/json" \
    -d '{
        "index": {
            "fields": [
                "@entity",
                "StepState"
            ]
        },
        "name": "stepStateIndex",
        "type": "json"
    }'


curl --silent \
    -X POST http://admin:password@localhost:5984/tasktide_database/_index \
    -H "Content-Type: application/json" \
    -d '{
        "index": {
            "fields": [
                "@entity",
                "StepName",
                "StepState"
            ]
        },
        "name": "stepNameStateIndex",
        "type": "json"
    }'


curl --silent \
    -X POST http://admin:password@localhost:5984/tasktide_database/_index \
    -H "Content-Type: application/json" \
    -d '{
        "index": {
            "fields": [
                "@entity",
                "WorkflowId"
            ]
        },
        "name": "workflowIdIndex",
        "type": "json"
    }'




##################################
##################################
##
## ii). mongoDB
##
##################################
##################################


# Run image
docker container run  -p 27017:27017 mongo:latest


```{mongosh}
use tasktide_database

// WorkItem Step indexes
db.WorkItem.createIndex({ StepName: 1 }, { name: "workItemStepIndex" })
db.WorkItem.createIndex({ StepId: 1 }, { name: "workItemStepIdIndex" })
db.WorkItem.createIndex({ ItemState: 1 }, { name: "workItemStateIndex" })
db.WorkItem.createIndex({ StepName: 1, ItemState: 1 }, { name: "workItemStepNameStateIndex" })
db.WorkItem.createIndex({ StepId: 1, ItemState: 1 }, { name: "workItemStepIdStateIndex" })
db.WorkItem.createIndex({ JobEnvironmentId: 1 }, { name: "entityJobEnvIndex" })
db.WorkItem.createIndex({ StepName: 1, JobEnvironmentId: 1 }, { name: "workItemStepNameJobEnvIdIndex" })
db.WorkItem.createIndex({ StepId: 1, JobEnvironmentId: 1 }, { name: "workItemStepIdJobEnvIdIndex" })

// Workflow indexes
db.Workflow.createIndex({ WorkflowName: 1 }, { name: "workflowNameIndex" })

// Step indexes
db.Step.createIndex({ StepName: 1 }, { name: "stepNameIndex" })
db.Step.createIndex({ StepState: 1 }, { name: "stepStateIndex" })
db.Step.createIndex({ StepName: 1, StepState: 1 }, { name: "stepNameStateIndex" })
db.Step.createIndex({ WorkflowId: 1 }, { name: "workflowIdIndex" })

```