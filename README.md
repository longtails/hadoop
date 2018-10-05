# hadoop

## hadoop cluster

- install virtual box

- init box

```bash
cd hadoop
vagrant box add centos/7 centos_7_virtualbox.box
vagrant up
```
- download hadoop、jdk

```bash
wget https://www.oracle.com/technetwork/java/javase/downloads/jdk11-downloads-5066655.html
wget http://mirrors.shu.edu.cn/apache/hadoop/common/hadoop-2.8.5/hadoop-2.8.5.tar.gz
```

- connect to hdp1  and test

```bash
vagrant ssh hdp1
cd test
./start.sh
```
- start hadoop

```bash
cd test
./start.sh
```




