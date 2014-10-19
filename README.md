shadowsocks_auto_install
========================

centos6.5或7版本，自动安装shadowsocks脚本

####说明：
1. 此脚本只适用于Centos6.5或7版本

2. 自动下载安装shadowsocks-libev

3. 自动优化TCP

4. 添加开机启动到/etc/rc.d/rc.local文件中

5. 脚本执行完成后自动创建服务进程ss-server

6. 脚本执行完成后自动删除临时文件

7. 以0.0.0.0作为服务器IP地址，适用于没有独立公网IP（搬瓦工）的VPS
