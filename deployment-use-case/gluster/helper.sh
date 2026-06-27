#!/bin/bash


########################################################################
########################################################################
## 
## 1). Deploy Gluster
##
## NLB wont work because dynamic ports used for brick traffic
## 
########################################################################
########################################################################


# Start and inspect
docker compose --file gluster.yml up -d
docker container ls               


'''

+] up 7/7
 ✔ Network gluster_gluster_nlb Created                                                                                                                                                                               0.1s
 ✔ Network gluster_gluster_net Created                                                                                                                                                                               0.1s
 ✔ Container gluster-node3     Created                                                                                                                                                                               0.2s
 ✔ Container gluster-node2     Created                                                                                                                                                                               0.2s
 ✔ Container gluster-node1     Created                                                                                                                                                                               0.2s
 ✔ Container gluster-nlb       Created                                                                                                                                                                               0.2s
 ✔ Container gluster-bootstrap Created

'''



# Inspect
docker exec -it gluster-nlb sh ```   
~ $ nc -zv 192.168.1.3 24007
192.168.1.3 (192.168.1.3:24007) open
~ $ 
~ $ nc -zv 192.168.1.3 24007
192.168.1.3 (192.168.1.3:24007) open
~ $ 
~ $ nc -zv 192.168.1.5 24007
192.168.1.5 (192.168.1.5:24007) open
```



# Inspect cluster and try test file
docker exec -it gluster-node1 bash ```

gluster peer status
gluster volume status gv0

'''
Number of Peers: 2

Hostname: gluster-node2
Uuid: fa971e9e-ce8b-43e3-a858-bb42e2e2b55b
State: Peer in Cluster (Connected)

Hostname: gluster-node3
Uuid: 43adbeb4-d3f0-44dc-8a2f-4999958785f2
State: Peer in Cluster (Connected)

Status of volume: gv0
Gluster process                             TCP Port  RDMA Port  Online  Pid
------------------------------------------------------------------------------
Brick gluster-node1:/data/glusterfs/brick1/
gv0                                         49152     0          Y       101  
Brick gluster-node2:/data/glusterfs/brick2/
gv0                                         49152     0          Y       70   
Brick gluster-node3:/data/glusterfs/brick3/
gv0                                         49152     0          Y       70   
Self-heal Daemon on localhost               N/A       N/A        Y       122  
Self-heal Daemon on gluster-node2           N/A       N/A        Y       91   
Self-heal Daemon on gluster-node3           N/A       N/A        Y       91   
 
Task Status of Volume gv0
------------------------------------------------------------------------------
There are no active volume tasks

'''


# Test mounting through NLB reference
mkdir -p /mnt/gluster
mount -t glusterfs gluster-nlb:/gv0 /mnt/gluster
seq 3 > /mnt/gluster/test-file.txt
cat /mnt/gluster/test-file.txt
1
2
3

```



# Verify test file separate host: NLB wont work because dynamic ports used for brick traffic
docker run -it --rm --name gluster-client --network gluster_gluster_nlb --privileged gluster/gluster-centos:latest bash ```

mkdir -p /mnt/gluster
mount -t glusterfs gluster-nlb:/gv0 /mnt/gluster
Mount failed. Check the log file  for more details.
 ^C
 exit
``` 


docker run -it --rm --name gluster-client --network gluster_gluster_net --privileged gluster/gluster-centos:latest bash ```
 mkdir -p /mnt/gluster
 mount -t glusterfs gluster-nlb:/gv0 /mnt/gluster
 ls /mnt/gluster/
node1-test.txt  test-file.txt
 cat /mnt/gluster/test-file.txt 
1
2
3



```


docker container logs gluster-nlb
Connect from 172.23.0.3:49151 to 172.23.0.2:24007 (gluster_front/TCP)
Connect from 192.168.1.3:49147 to 192.168.1.2:24007 (gluster_front/TCP)
Connect from 192.168.1.6:49151 to 192.168.1.2:24007 (gluster_front/TCP)
Connect from 192.168.1.3:49147 to 192.168.1.2:24007 (gluster_front/TCP)
Connect from 192.168.1.6:49151 to 192.168.1.2:24007 (gluster_front/TCP)
Connect from 192.168.1.3:49147 to 192.168.1.2:24007 (gluster_front/TCP)
Connect from 192.168.1.6:49151 to 192.168.1.2:24007 (gluster_front/TCP)
Connect from 192.168.1.3:49147 to 192.168.1.2:24007 (gluster_front/TCP)