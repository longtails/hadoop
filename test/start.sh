#!/bin/bash

echo "-------------------"
echo "ssh key gen"
echo "-------------------"

sudo ssh-keygen
sudo ssh-copy-id -i /root/.ssh/id_rsa.pub root@hdp-node-01
sudo ssh-copy-id -i /root/.ssh/id_rsa.pub root@hdp-node-02
sudo ssh-copy-id -i /root/.ssh/id_rsa.pub root@hdp-node-03

echo "-------------------"
echo "hadoop start"
echo "-------------------"

sudo $HADOOP_HOME/bin/hadoop namenode -format

sudo $HADOOP_HOME/sbin/start-dfs.sh
sudo $HADOOP_HOME/sbin/start-yarn.sh


echo "-------------------"
echo "hadoop example wordcount"
echo "-------------------"

sudo $HADOOP_HOME/bin/hadoop fs -mkdir -p /wordcount/input
sudo $HADOOP_HOME/bin/hadoop fs -put /home/vagrant/test/somewords.txt /wordcount/input
sudo $HADOOP_HOME/bin/hadoop fs -ls /wordcount/input

cd /home/vagrant/hadoop/share/hadoop/mapreduce
sudo $HADOOP_HOME/bin/hadoop jar hadoop-mapreduce-examples-2.8.5.jar wordcount /wordcount/input /wordcount/output




