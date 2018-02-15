# Start with latest CentOS image
FROM centos:6

MAINTAINER Ayisha Tabbassum ayisha.tabbassum@ugamsolutions.com

# Switch to root user
USER root

# Update yum
RUN yum update -y

# Install required packages
RUN yum install -y tar git wget vim ssh

# Install java
RUN yum install -y java-1.7.0-openjdk-devel

## Install hadoop from cloudera Version
ENV HADOOP_VERSION=2.5.0-cdh5.3.0

# JAVA
ENV JAVA_HOME=/usr/lib/jvm/jre-1.7.0-openjdk.x86_64 
ENV PATH=$PATH:$JAVA_HOME/bin

# Hadoop home and user
ENV HADOOP_HOME=/usr/local/hadoop/hadoop-$HADOOP_VERSION
ENV HADOOP_USER=hadoop

# Paths
ENV HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
ENV HADOOP_LIBEXEC_DIR=$HADOOP_HOME/libexec
ENV PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin

# Hbase home 
ENV HBASE_HOME /usr/local/hbase/hbase-0.98.6-cdh5.3.0

#Hive home
ENV HIVE_VERSION 0.13.1-cdh5.3.0
ENV HIVE_HOME /usr/local/hive/hive-0.13.1-cdh5.3.0
ENV HIVE_CONF_DIR $HIVE_HOME/conf
ENV HCAT_LOG_DIR /usr/local/hive/logs
ENV HCAT_PID_DIR /usr/local/hive/logs
ENV WEBHCAT_LOG_DIR /usr/local/hive/logs
ENV WEBHCAT_PID_DIR /usr/local/hive/logs

# Add hbase to path
ENV PATH $HBASE_HOME/bin:$PATH

# Add hive to path
ENV PATH=$HIVE_HOME/bin:$PATH

#Installing hadoop
WORKDIR /usr/local/hadoop
RUN curl -SsfLO "http://archive-primary.cloudera.com/cdh5/cdh/5/hadoop-2.5.0-cdh5.3.0.tar.gz"
RUN tar -xvzf /usr/local/hadoop/hadoop-2.5.0-cdh5.3.0.tar.gz

#Getting the IPV4 address
#CMD hostnameValue $(ifconfig eth0| grep -i "inet addr"| grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}'| awk NR==1) 

# Copy configuration
RUN mkdir /data
COPY /conf/*.xml /data/
#RUN sed -i "s/hostnameValue/$hostnameValue/g" /data/*.xml
RUN mv /data/* $HADOOP_CONF_DIR 

# fix configuration file
RUN sed  -i.bak "s/hadoop-daemons.sh/hadoop-daemon.sh/g" \
        $HADOOP_HOME/sbin/start-dfs.sh \
    && rm -f $HADOOP_HOME/sbin/start-dfs.sh.bak \
    && sed -i.bak "s/hadoop-daemons.sh/hadoop-daemon.sh/g" \
        $HADOOP_HOME/sbin/stop-dfs.sh \
    && rm -f $HADOOP_HOME/sbin/stop-dfs.sh.bak

## Install hbase from cloudera
WORKDIR /usr/local/hbase
RUN chmod -R 755 /usr/local/hbase
RUN curl -SsfLO "http://archive-primary.cloudera.com/cdh5/cdh/5/hbase-0.98.6-cdh5.3.0.tar.gz"
RUN tar -xvzf /usr/local/hbase/hbase-0.98.6-cdh5.3.0.tar.gz

# Insert config file from local
#RUN mkdir /data/hbasedata
#ADD hbase-site.xml /data/hbasedata/
#RUN sed -i "s/hostnameValue/$hostnameValue/g" /data/hbasedata/hbase-site.xml
#RUN cp /data/hbasedata/* $HBASE_HOME/conf/

## Install hive from cloudera
WORKDIR /usr/local/hive
RUN chmod -R 755 /usr/local/hive
RUN curl -SsfLO "http://archive-primary.cloudera.com/cdh5/cdh/5/hive-0.13.1-cdh5.3.0.tar.gz"
RUN tar -xvzf /usr/local/hive/hive-0.13.1-cdh5.3.0.tar.gz
#RUN curl -SsfLO https://jdbc.postgresql.org/download/postgresql-9.4.1209.jre7.jar -O $HIVE_HOME/lib/postgresql-9.4.1209.jre7.jar
COPY postgresql-9.4.1209.jre7.jar  $HIVE_HOME/lib/ 

# Insert config file from local
RUN mkdir /data/hivedata
ADD hive-site.xml /data/hivedata/
#RUN sed -i "s/hostnameValue/$hostnameValue/g" /data/hivedata/hive-site.xml
RUN cp /data/hivedata/* $HIVE_CONF_DIR


#Copy script to configure IP\hostname in confifuration files
RUN mkdir /usr/local/scripts
ADD configureHostname.sh  /usr/local/scripts/

# Changing the permissions of the directory
RUN chown -R root:root /usr/local/*
RUN chmod -R 755 /usr/local/*

# add user
RUN useradd -s /bin/bash $HADOOP_USER

# HDFS
#EXPOSE 9000 8020 14000 50070 50470 
EXPOSE 5000

# EXPOSE Hbase PORTS
#EXPOSE 2181 16000 16010 16020 16030 8080 
#EXPOSE 2181 50070 60010 60020 60030

#HIVE
#EXPOSE 9083 10000 10002 50111 

# HDFS Volume
VOLUME /opt/hdfs

# HIVE Volume
VOLUME ["/opt/hive/conf", "/opt/hive/logs"]

