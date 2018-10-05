### hadoop

    原本是打算用docker配置hadoop的，但是遇到了docker下centos/7 systemctl异常，以及没有ssh的问题，遂，该用vagrant方式在virtual box虚拟机上运行

- 环境
    - virtual box
    - centos box 文件
    - [jdk](https://www.oracle.com/technetwork/java/javase/downloads/index.html)
    - [hadoop](https://hadoop.apache.org/releases.html)
    - 网络
       - gw:192.168.33.1
       - netmask:255.255.255.0
       - node ip:
  
         hdp-node-01 | hdp-node-02 | hdp-node-03
           --- |---|---
         192.168.33.101|192.168.33.102 |192.168.33.103


- 步骤
    - 启动三个centos
    - 配置文件（在hdp-node-01上，其他直接复制过去） 
        - core-site.xml
        - hadoop-env.sh
        - hdfs-site.xml
        - mapred-site.xml
        - slaves
        - yarn-env.sh
        - yarn-site.xml
    - 修改.bashrc换件变量
    - ssh连接其他节点
        - ssh-keygen生成公私钥
        - ssh-copy-id 上传公钥到hdp-node-01、02、03上
    - 测试hadoop
        - 需要root或者sudo
        - wordcount example
        - ./start.sh
 
       
- 使用方法见README


- vagrant
    - file tree
    
    ```bash
    liudeMacBook-Pro:hadoop liu$ tree
    .
    ├── README.md
    ├── Vagrantfile
    ├── centos_7_virtualbox.box
    ├── debug
    ├── env
    │   ├── core-site.xml
    │   ├── hadoop-env.sh
    │   ├── hdfs-site.xml
    │   ├── mapred-site.xml
    │   ├── slaves
    │   ├── yarn-env.sh
    │   └── yarn-site.xml
    ├── hadoop-2.8.5.tar.gz
    ├── jdk-11_linux-x64_bin.tar.gz
    ├── sshd_config
    └── test
        ├── somewords.txt
        └── start.sh
    ```

    - vagrant file
    
    ```bash
    
    # -*- mode: ruby -*-
    # vi: set ft=ruby :

    #   
    #this is for building master
    #   
    #author:lhy
    #time:2018.8.25
    #   
    $clusters_script = <<-SCRIPT
    #!/bin/bash

    # at /home/vagrant
    #---hosts---
    cat >> /etc/hosts <<EOF

    192.168.33.101  hdp-node-01
    192.168.33.102  hdp-node-02
    192.168.33.103  hdp-node-03

    EOF 
    #---env---
    cat >> /root/.bashrc <<EOF
    export HADOOP_HOME=/home/vagrant/hadoop
    export JAVA_HOME=/home/vagrant/jdk
    export PATH=$PATH:home/hadoop/bin/
    EOF 
    source /root/.bashrc

    cat >> .bashrc <<EOF
    export HADOOP_HOME=/home/hadoop
    export JAVA_HOME=/home/vagrant/jdk
    export PATH=$PATH:home/vagrant/hadoop/bin/
    EOF 
    
    source .bashrc
        #---hadoop---
    tar -zxf hadoop-2.8.5.tar.gz
    mv hadoop-2.8.5 hadoop
    mv env/*  hadoop/etc/hadoop/
    rm  hadoop-2.8.5.tar.gz

    #---jdk---
    tar -zxf jdk-11_linux-x64_bin.tar.gz
    mv jdk-11 jdk
    rm jdk-11_linux-x64_bin.tar.gz


    #---ssh---
    mv /home/vagrant/sshd_config /etc/ssh/sshd_config
    systemctl restart sshd.service

    SCRIPT

    
    Vagrant.configure("2") do |config|

            (1..3).each do |i|
            config.vm.define "hdp#{i}" do |node|

            # 设置虚拟机的Box
            node.vm.box = "centos/7"
            # 设置虚拟机的主机名
            node.vm.hostname="hdp-node-0#{i}"
            # 设置虚拟机的IP
            node.vm.network "private_network", ip: "192.168.33.#{100+i}"

            # 设置主机与虚拟机的共享目录
            #node.vm.synced_folder "~/Desktop/share", "/home/vagrant/share"
            # 复制相应的依赖文件
            config.vm.provision "file", source: "./jdk-11_linux-x64_bin.tar.gz", destination: "/home/vagrant/jdk-11_linux-x64_bin.tar.gz"
            config.vm.provision "file", source: "./hadoop-2.8.5.tar.gz", destination: "/home/vagrant/hadoop-2.8.5.tar.gz"
            config.vm.provision "file", source: "./sshd_config", destination: "/home/vagrant/sshd_config"
            config.vm.provision "file", source: "./env", destination: "/home/vagrant/env"
            config.vm.provision "file", source: "./test", destination: "/home/vagrant/test"

            # VirtaulBox相关配置
            node.vm.provider "virtualbox" do |v|
                # 设置虚拟机的名称
                v.name = "hdp#{i}"
                # 设置虚拟机的内存大小  
                v.memory = 1024
                # 设置虚拟机的CPU个数
                v.cpus = 1
            end
            node.vm.provision "shell", inline: $clusters_script # 使用shell脚本进行软件安装和配置
            end
        end
    end

    ```

- start.sh

```bash
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

```

- output

```bash
18/10/05 06:06:10 INFO mapreduce.Job: Counters: 49
	File System Counters
		FILE: Number of bytes read=186
		FILE: Number of bytes written=316073
		FILE: Number of read operations=0
		FILE: Number of large read operations=0
		FILE: Number of write operations=0
		HDFS: Number of bytes read=178
		HDFS: Number of bytes written=100
		HDFS: Number of read operations=6
		HDFS: Number of large read operations=0
		HDFS: Number of write operations=2
	Job Counters 
		Launched map tasks=1
		Launched reduce tasks=1
		Data-local map tasks=1
		Total time spent by all maps in occupied slots (ms)=10769
		Total time spent by all reduces in occupied slots (ms)=7307
		Total time spent by all map tasks (ms)=10769
		Total time spent by all reduce tasks (ms)=7307
		Total vcore-milliseconds taken by all map tasks=10769
		Total vcore-milliseconds taken by all reduce tasks=7307
		Total megabyte-milliseconds taken by all map tasks=11027456
		Total megabyte-milliseconds taken by all reduce tasks=7482368
	Map-Reduce Framework
		Map input records=10
		Map output records=20
		Map output bytes=140
		Map output materialized bytes=186
		Input split bytes=118
		Combine input records=20
		Combine output records=20
		Reduce input groups=20
		Reduce shuffle bytes=186
		Reduce input records=20
		Reduce output records=20
		Spilled Records=40
		Shuffled Maps =1
		Failed Shuffles=0
		Merged Map outputs=1
		GC time elapsed (ms)=183
		CPU time spent (ms)=1950
		Physical memory (bytes) snapshot=369668096
		Virtual memory (bytes) snapshot=4044595200
		Total committed heap usage (bytes)=176128000
	Shuffle Errors
		BAD_ID=0
		CONNECTION=0
		IO_ERROR=0
		WRONG_LENGTH=0
		WRONG_MAP=0
		WRONG_REDUCE=0
	File Input Format Counters 
		Bytes Read=60
	File Output Format Counters 
		Bytes Written=100
```
---------
#### 几个关键问题
---------

- centos/7 mini ssh 设置

    - 在/etc/ssh/sshd_config中，修改或加入如下内容
     ```bash
     PubkeyAuthentication yes
     RSAAuthentication yes
     AuthorizedKeysCommandUser nobody
     ```
    - 重启ssh服务
    ```bash
    sudo systemctl restart sshd.service
    ```
- hadoop需要root权限