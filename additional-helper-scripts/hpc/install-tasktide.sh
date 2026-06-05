#!/bin/bash


# Start interactive shell
. ~/interactive.sh
. ~/start.sh


# Back up config
cp $TASK_TIDE_CONF $TASK_TIDE/microprofile-config.properties


# TaskTide
cd $JAVA_MODULES
# mv ~/tasktide-0.9.5.zip ./
# wget https://github.com/BrenKenna/TaskTide/releases/download/v0.9.0/tasktide-0.9.0.zip
rm -fr tasktide-0.9.0/ tasktide-0.9.5/ 
unzip tasktide-0.9.5.zip && rm -f tasktide-0.9.5.zip && cd tasktide-0.9.5
rm -f $SOFT/bin/tasktide
ln -sf $JAVA_MODULES/tasktide-0.9.5/bin/tasktide $SOFT/bin/tasktide


mkdir jnosql-libs
mv lib/jnosql-arangodb-1.1.6.jar jnosql-libs/
mv lib/jnosql-cassandra-1.1.6.jar jnosql-libs/
mv lib/jnosql-couchbase-1.1.6.jar jnosql-libs/
mv lib/jnosql-dynamodb-1.1.6.jar jnosql-libs/
mv lib/jnosql-mongodb-1.1.6.jar jnosql-libs/
mv lib/jnosql-redis-1.1.6.jar jnosql-libs/
mv lib/jnosql-couchdb-1.1.6.jar jnosql-libs/
mv lib/jnosql-mapping-graph-1.1.8.jar jnosql-libs/
mv lib/jnosql-mapping-key-value-1.1.8.jar jnosql-libs/
mv lib/jnosql-mapping-column-1.1.8.jar jnosql-libs/

cp $TASK_TIDE/microprofile-config.properties $TASK_TIDE_CONF
cd $TASK_TIDE

