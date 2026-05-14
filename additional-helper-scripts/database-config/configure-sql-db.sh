#!/bin/bash


docker container run \
    -e MARIADB_USER=admin \
    -e MARIADB_PASSWORD=password \
    -e MARIADB_ROOT_PASSWORD=rootpass \
    -e MARIADB_DATABASE=tasktide_database \
    -p 3306:3306 \
    mariadb:latest


# Create indexes




#############################################
#############################################
# 
# c). MySQL
#  could use 'org.mariadb.jdbc:mariadb-java-client:3.3.2'
# 
#############################################
#############################################

docker run -e MARIADB_USER=admin -e MARIADB_PASSWORD=password -e MARIADB_ROOT_PASSWORD=rootpass -e MARIADB_DATABASE=tasktide_database -p 3306:3306 mariadb:latest

``` {SQL}

select ItemState, COUNT(DISTINCT id) AS 'Total', SUM(TaskCount), SUM(TaskDone) FROM WorkItem GROUP BY ItemState ORDER BY 'Total' DESC;

'''
+-----------+-------+----------------+---------------+
| ItemState | Total | SUM(TaskCount) | SUM(TaskDone) |
+-----------+-------+----------------+---------------+
| TODO      |     5 |             13 |             0 |
+-----------+-------+----------------+---------------+
'''

select ItemState, COUNT(DISTINCT id) AS 'Total', SUM(TaskCount), SUM(TaskDone) FROM WorkItem GROUP BY ItemState ORDER BY 'Total' DESC;
+-----------+-------+----------------+---------------+
| ItemState | Total | SUM(TaskCount) | SUM(TaskDone) |
+-----------+-------+----------------+---------------+
| TODO      |     3 |              7 |             0 |
| LOCKED    |     2 |              6 |             0 |
+-----------+-------+----------------+---------------+


select ItemState, COUNT(DISTINCT id) AS 'Total', SUM(TaskCount), SUM(TaskDone) FROM WorkItem GROUP BY ItemState ORDER BY 'Total' DESC;
+-----------+-------+----------------+---------------+
| ItemState | Total | SUM(TaskCount) | SUM(TaskDone) |
+-----------+-------+----------------+---------------+
| LOCKED    |     2 |              6 |             0 |
| DONE      |     2 |              3 |             3 |
| ERROR     |     1 |              4 |             3 |
+-----------+-------+----------------+---------------+

select ItemState, COUNT(DISTINCT id) AS 'Total', SUM(TaskCount), SUM(TaskDone) FROM WorkItem GROUP BY ItemState ORDER BY 'Total' DESC;
+-----------+-------+----------------+---------------+
| ItemState | Total | SUM(TaskCount) | SUM(TaskDone) |
+-----------+-------+----------------+---------------+
| DONE      |     3 |              4 |             4 |
| ERROR     |     2 |              9 |             7 |
+-----------+-------+----------------+---------------+


select ItemName, ItemState, TaskCount, TaskDone FROM WorkItem;
+-------------+-----------+-----------+----------+
| ItemName    | ItemState | TaskCount | TaskDone |
+-------------+-----------+-----------+----------+
| Ping_Test_3 | ERROR     |         4 |        3 |
| Ping_Test_2 | DONE      |         2 |        2 |
| Ping_Test_5 | DONE      |         1 |        1 |
| Ping_Test_4 | ERROR     |         5 |        4 |
| Ping_Test_1 | DONE      |         1 |        1 |
+-------------+-----------+-----------+----------+

```
