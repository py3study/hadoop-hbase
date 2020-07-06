FROM ubuntu:14.04

ADD sources.list /etc/apt/sources.list
ADD hadoop-2.9.2.tar.gz /
ADD hbase-1.3.6-bin.tar.gz /
ADD zookeeper-3.4.14.tar.gz /
ADD run.sh /root/run.sh
COPY config/* /tmp/

WORKDIR /root

# install openssh-server,openjdk,hadoop,hbase,zookeeper
RUN apt-get update && \
    apt-get install -y --reinstall software-properties-common && \
    add-apt-repository -y ppa:openjdk-r/ppa && \
    apt-get update && \
    apt-get install -y openssh-server openjdk-8-jdk && \
    apt-get -y --purge remove software-properties-common && \
    apt-get clean all && \
    mv /hadoop-2.9.2 /usr/local/hadoop && \
    mv /hbase-1.3.6 /usr/local/hbase && \
    mv /zookeeper-3.4.14 /usr/local/zookeeper

# set environment variable
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV HADOOP_HOME=/usr/local/hadoop
ENV HBASE_HOME=/usr/local/hbase
ENV PATH=$PATH:/usr/local/hadoop/bin:/usr/local/hadoop/sbin 

# ssh without key and hadoop config
RUN ssh-keygen -t rsa -f ~/.ssh/id_rsa -P '' && \
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && \
    mkdir -p ~/hdfs/namenode && \ 
    mkdir -p ~/hdfs/datanode && \
    mkdir $HADOOP_HOME/logs && \
    mv /tmp/ssh_config ~/.ssh/config && \
    mv /tmp/hadoop-env.sh /usr/local/hadoop/etc/hadoop/hadoop-env.sh && \
    mv /tmp/hdfs-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml && \ 
    mv /tmp/core-site.xml $HADOOP_HOME/etc/hadoop/core-site.xml && \
    mv /tmp/mapred-site.xml $HADOOP_HOME/etc/hadoop/mapred-site.xml && \
    mv /tmp/yarn-site.xml $HADOOP_HOME/etc/hadoop/yarn-site.xml && \
    mv /tmp/slaves $HADOOP_HOME/etc/hadoop/slaves && \
    mv /tmp/start-hadoop.sh ~/start-hadoop.sh && \
    mv /tmp/run-wordcount.sh ~/run-wordcount.sh && \
    mv /tmp/zoo.cfg /usr/local/zookeeper/conf/ && \
    mv /tmp/hbase-site.xml $HBASE_HOME/conf/ && \
    mv /tmp/regionservers $HBASE_HOME/conf/ && \
    mv /tmp/hbase-env.sh $HBASE_HOME/conf/ && \
    chmod +x ~/start-hadoop.sh && \
    chmod +x ~/run-wordcount.sh && \
    chmod +x $HADOOP_HOME/sbin/start-dfs.sh && \
    chmod +x $HADOOP_HOME/sbin/start-yarn.sh && \
    chmod +x ~/run.sh && \
    /usr/local/hadoop/bin/hdfs namenode -format

CMD ["/root/run.sh"]
