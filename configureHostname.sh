#!/bin/sh
hostnameValue=$(ifconfig eth0| grep -i "inet addr"| grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}'| awk NR==1)

#Configuring IP in Hadoop Configuration Files
cd /usr/local/hadoop/hadoop-2.5.0-cdh5.3.0/etc/hadoop
sed -i "s/hostnameValue/$hostnameValue/g" core-site.xml hdfs-site.xml yarn-site.xml
echo "Check the IP of hdfs in core-site.xml"
cat core-site.xml | grep -i $hostnameValue core-site.xml
echo "Check the IP of namenode.dns.nameserver in hdfs-site.xml"
cat hdfs-site.xml | grep -i $hostnameValue hdfs-site.xml
echo "Check the IP of resourcemanager.hostname in yarn-site.xml"
cat yarn-site.xml | grep -i $hostnameValue yarn-site.xml

#Configuring IP in Hbase Configuration File
cd /usr/local/hbase/hbase-0.98.6-cdh5.3.0/conf
sed -i "s/hostnameValue/$hostnameValue/g" hbase-site.xml
echo "Check the IP of hbase.rootdir in hbase-site.xml"
cat hbase-site.xml | grep -i $hostnameValue hbase-site.xml

#Configuring IP in Hive Configuration File
cd /usr/local/hive/hive-0.13.1-cdh5.3.0/conf
sed -i "s/hostnameValue/$hostnameValue/g" hive-site.xml
echo "check the IP of listener host in hive-site.xml"
cat hive-site.xml | grep -i $hostnameValue hive-site.xml



