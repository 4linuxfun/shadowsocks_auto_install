#!/bin/bash 
#auto script ss-server for cento

END_INSTALL(){
echo "END BY USER"
sleep 3
exit 0;
}
trap "END_INSTALL" SIGINT SIGTERM

	
echo "==================="
echo "Testing the network"
echo "==================="
sleep 3
ping -c 3 www.baidu.com 
if [ $? -ne 0 ];then
echo "Network is not connected"
echo "Exiting the script"
exit
else
echo "Network is connetcted,starting install normal tools"
fi

	cat /etc/centos-release|grep 6.5
if [ $? -eq 0 ];then
	service iptables stop
	chkconfig iptables off
elif cat /etc/centos-release|grep 7.0;then 	
	systemctl stop firewalld
	systemctl disable firewalld
	yum install iptables-services -y
	#systemctl start iptables
	#systemctl start ip6tables
	systemctl disable iptables
	systemctl disable ip6tables
	chmod +x /etc/rc.d/rc.local
else
	echo -e "\033[40;31m ==========================================================\033[0m"
	echo -e "\033[40;31m This script is only use for centos 6.5 and centos 7\033[0m"
	echo 				"If you have any question,send email:yinyinxiaozi@gmail.com"
	echo -e "\033[40;31m ==========================================================\033[0m"
	exit 1
fi

DIR_NAME=$(cd "$(dirname "$0")"; pwd)
#upgrade 服务器
yum upgrade -y
#bind-utils nslookup，dig工具包
yum install bind-utilsyum \
sysstat \
lsof  \
wget  vim\
gcc gcc-c++ make \
vim lrzsz \
zip unzip \
ntp cmake bison-devel  ncurses-devel automake  build-essential autoconf libtool \
curl curl-devel zlib-devel openssl-devel \
perl perl-devel \
cpio expat-devel gettext-devel net-tools -y

wget https://github.com/madeye/shadowsocks-libev/archive/master.zip
unzip master.zip
cd shadowsocks-libev-master
./configure -prefix=/usr/local/shadowsocks &&make&&make install

cat>>/etc/sysctl.conf<<-EOF
	fs.file-max = 51200
	net.core.rmem_max = 67108864
	net.core.wmem_max = 67108864
	net.core.rmem_default = 65536
	net.core.wmem_default = 65536
	net.core.netdev_max_backlog = 250000
	net.core.somaxconn = 4096
	net.ipv4.tcp_syncookies = 1
	net.ipv4.tcp_tw_reuse = 1
	net.ipv4.tcp_tw_recycle = 0
	net.ipv4.tcp_fin_timeout = 30
	net.ipv4.tcp_keepalive_time = 1200
	net.ipv4.ip_local_port_range = 10000 65000
	net.ipv4.tcp_max_syn_backlog = 8192
	net.ipv4.tcp_max_tw_buckets = 5000
	net.ipv4.tcp_fastopen = 3
	net.ipv4.tcp_rmem = 4096 87380 67108864
	net.ipv4.tcp_wmem = 4096 65536 67108864
	net.ipv4.tcp_mtu_probing = 1
	net.ipv4.tcp_congestion_control = hybla
	EOF
sysctl -p
	
cd ${DIR_NAME}
rm -rf shadowsocks-libev-master
rm -rf master.zip

IP_ADDR=$(curl ifconfig.me)
SS_SERVER=$(find / -name ss-server)

read -p "Enter server port:" SS_PORT
read -p "Enter password:" SS_PASSWD
read -p "Enter method:" SS_METHOD
touch /root/shadowsocks.json
cat<<EOF>/root/shadowsocks.json
{
"server":"0.0.0.0",
"server_port":${SS_PORT},
"password":"${SS_PASSWD}",
"method": "${SS_METHOD}",
"timeout":600
}
EOF

nohup ${SS_SERVER} -u -c /root/shadowsocks.json >/dev/null 2>&1 &
ps aux|grep [s]hadowsocks>/dev/null
if [ $? -ne 0 ];then
	echo -e "\033[40;31m ==========================================================\033[0m"
	echo -e "\033[40;31m Shadowsocks start error!"
	echo 				"If you have any question,send email:yinyinxiaozi@gmail.com"
	echo -e "\033[40;31m ==========================================================\033[0m"
	exit 1
else
	cat<<-EOF|cat
	+++++++++++++++++++++++++++++
	Your shadowsocks server info:
	Server_IP:${IP_ADDR}
	SERVER_PORT:${SS_PORT}
	PASSWORD:${SS_PASSWD}
	METHOD:${SS_METHOD}
	+++++++++++++++++++++++++++++
	EOF
	echo "${SS_SERVER} -u -c /root/shadowsocks.json >/dev/null 2>&1 &">>/etc/rc.d/rc.local
	echo "=========================================================="
	echo "Now ,you can use shadowsocks."
	echo "If you have any question,send email:yinyinxiaozi@gmail.com"
	echo "=========================================================="
fi
