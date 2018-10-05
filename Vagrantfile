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
