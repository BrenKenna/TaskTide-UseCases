#!/bin/bash


docker container run \
    -e MARIADB_USER=admin \
    -e MARIADB_PASSWORD=password \
    -e MARIADB_ROOT_PASSWORD=rootpass \
    -e MARIADB_DATABASE=tasktide_database \
    -p 3306:3306 \
    mariadb:latest


# Create indexes
