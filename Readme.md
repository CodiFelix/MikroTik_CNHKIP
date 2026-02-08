## 使用方法
- 本脚本只能在Diban，Ubuntu，CentOS系统使用。

- 直接通过命令bash cn-ip-list.cn执行本脚本（可添加参数），会根据系统情况自动安装所需软件包。

  或

- 安装wget工具
  - Debian和Ubuntu命令apt-get install wget curl
  - CentOS命令yum install wget curl

- bash命令
  - export PATH=/bin:/usr/bin:$PATH


## 有时还可能需要先安装开发工具包
sudo apt update
sudo apt-get base64
sudo apt install build-essential
sudo apt-get install manpages-dev

#验证安装是否成功
gcc --version
g++ --version


- apnic ip address下载地址
wget -c http://ftp.apnic.net/stats/apnic/delegated-apnic-latest

- 到 [apnic.net](http://ftp.apnic.net/stats/apnic) 项目中下载最新的 delegated-apnic-latest 文件, 且放置在当前目录下。
    

- 执行 sh allcn-ip-list.sh 或者 ./allcn-ip-list.sh 为默认使用方式。  cn表和hk表同时生成
- 执行 sh cn-ip-list.sh 或者 ./cn-ip-list.sh 为默认使用方式。  生成cn表
- 执行 sh hk-ip-list.sh 或者 ./hk-ip-list.sh 为默认使用方式。  生成hk表


- 参数说明：

  - -t [timeout=] 默认为 timeout=0, 使用 -t 参数可以指定 timeout 的值
    ```shell
    > sh cn-ip-list.sh -t 1d    #1d表示一天，13:00:00表示13个小时
    ```    #此参数只针对防火墙里的list表生效，对routing rule表则无效。


  - -l [list=] 默认为 list=cn, 使用 -t 参数可以指定 list 的值
    ```shell
    > sh cn-ip-list.sh -l chinaip
    ```    #此参数全局生效


  - -c [comment=] 默认为 comment=cn, 使用 -c 参数可以指定 comment 的值
    ```shell
    > sh cn-ip-list.sh -c chinaip
    ```    #此参数全局生效


  - 组合使用
    > sh cn-ip-list.sh -t 7d -l china -c chinaip
  


- 脚本执行后会生成十一个文件在当前目录:
  - delegated-apnic-latest - 最新apnic地址分配表

  - ipv4.txt - CNipv4地址纯净表
  - ipv4-hk.txt - CN香港ipv4地址纯净表
  - ipv6.txt - CNipv6地址纯净表
  - ipv6-hk.txt - CNipv6香港地址纯净表

  - cn_ipv4_list.rsc - 适合MikroTik RouterOS使用的IPv4防火墙address-list项的import可执行脚本
  - cn_ipv4_route.rsc - 适合MikroTik RouterOS使用的IPv4 Routing Rule项的import可执行脚本
  - cn_ipv6_list.rsc - 适合MikroTik RouterOS使用的防火墙IPv6 address-list项的import可执行脚本

  - hk_ipv4_list.rsc - 适合MikroTik RouterOS使用的IPv4防火墙address-list项的import可执行脚本
  - hk_ipv4_route.rsc - 适合MikroTik RouterOS使用的IPv4 Routing Rule项的import可执行脚本
  - hk_ipv6_list.rsc - 适合MikroTik RouterOS使用的防火墙IPv6 address-list项的import可执行脚本
 
