#!/bin/bash

# the default node number is 3
N=${1:-3}


# start hadoop master container
sudo docker rm -f hadoop-master &> /dev/null
echo "start hadoop-master container..."
sudo docker run -itd \
                --net=hadoop \
                -p 50070:50070 \
                -p 8088:8088 \
                -p 16010:16010 \
                --name hadoop-master \
                --hostname hadoop-master \
                -e MYID=1 \
                -v /data/hadoop-cluster/master/hdfs:/root/hdfs \
                -v /data/hadoop-cluster/master/zookeeper/data:/usr/local/zookeeper/data \
                hadoop-hbase:1 &> /dev/null


# start hadoop slave container
i=1
while [ $i -lt $N ]
do
	sudo docker rm -f hadoop-slave$i &> /dev/null
	echo "start hadoop-slave$i container..."
        myid=`expr $i + 1`
	sudo docker run -itd \
	                --net=hadoop \
	                --name hadoop-slave$i \
	                --hostname hadoop-slave$i \
                        -e MYID=$myid \
                        -v /data/hadoop-cluster/slave$i/hdfs:/root/hdfs \
                        -v /data/hadoop-cluster/slave$i/zookeeper/data:/usr/local/zookeeper/data \
	                hadoop-hbase:1 &> /dev/null
	i=$(( $i + 1 ))
done 

# get into hadoop master container
sudo docker exec -it hadoop-master bash

