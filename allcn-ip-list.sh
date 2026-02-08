#!/bin/bash
# 添加执行权限
chmod +x allcn-ip-list.sh

if [[ $(/usr/bin/id -u) -ne 0 ]]; then
  sudoCmd="sudo"
else
  sudoCmd=""
fi

# www.github.com/itsanni，MikroTik cn address list scripts
if [[ -f /etc/redhat-release ]]; then
  release="centos"
  systemPackage="yum"
elif cat /etc/issue | grep -Eqi "debian"; then
  release="debian"
  systemPackage="apt-get"
elif cat /etc/issue | grep -Eqi "ubuntu"; then
  release="ubuntu"
  systemPackage="apt-get"
elif cat /etc/issue | grep -Eqi "centos|red hat|redhat"; then
  release="centos"
  systemPackage="yum"
elif cat /proc/version | grep -Eqi "debian"; then
  release="debian"
  systemPackage="apt-get"
elif cat /proc/version | grep -Eqi "ubuntu"; then
  release="ubuntu"
  systemPackage="apt-get"
elif cat /proc/version | grep -Eqi "centos|red hat|redhat"; then
  release="centos"
  systemPackage="yum"
fi

if [ ${systemPackage} == "yum" ]; then
    ${sudoCmd} ${systemPackage} install wget curl -y -q
else
    ${sudoCmd} ${systemPackage} install wget curl -y -qq
fi

if [ ${release} == "centos" ]; then
    nginx_root="/usr/share/nginx/html"
else
    nginx_root="/var/www/html"
fi


# 执行脚本时可以增加-t -l -c参数（注意：-t参数只对list表生效）
timeout="0"
listcn="cn"
listhk="hk"
commentcn="cn"
commenthk="hk"
# 从apnic下载全球地址分配表
wget -c http://ftp.apnic.net/stats/apnic/delegated-apnic-latest > /dev/null 2>&1

# wait for 1s
sleep 1

# 分类 CN和HK，ipv4和ipv6 地址
cat delegated-apnic-latest | awk -F '|' '/CN/&&/ipv4/ {print $4 "/" 32-log($5)/log(2)}' | cat > ./Result/ipv4-cn.txt
cat delegated-apnic-latest | awk -F '|' '/CN/&&/ipv6/ {print $4 "/" $5}' | cat > ./Result/ipv6-cn.txt
cat delegated-apnic-latest | awk -F '|' '/HK/&&/ipv4/ {print $4 "/" 32-log($5)/log(2)}' | cat > ./Result/ipv4-hk.txt
cat delegated-apnic-latest | awk -F '|' '/HK/&&/ipv6/ {print $4 "/" $5}' | cat > ./Result/ipv6-hk.txt

#cat delegated-apnic-latest | awk -F '|' '/CN/&&/ipv6/ {print $4 "/" $5}' | cat > ipv6666.txt
# wait for 1s
sleep 1


# 环境变量
cn_ipv4_list_filename="./Result/cn_ipv4_list.rsc"
cn_ipv4_route_filename="./Result/cn_ipv4_route.rsc"
cn_ipv6_list_filename="./Result/cn_ipv6_list.rsc"

cn_ipv4_hk_list_filename="./Result/cn_ipv4_hk_list.rsc"
cn_ipv4_hk_route_filename="./Result/cn_ipv4_hk_route.rsc"
cn_ipv6_hk_list_filename="./Result/cn_ipv6_hk_list.rsc"

# 中国大陆IP地址
cp ./Result/ipv4-cn.txt ${cn_ipv4_list_filename}
cp ./Result/ipv4-cn.txt ${cn_ipv4_route_filename}
cp ./Result/ipv6-cn.txt ${cn_ipv6_list_filename}

# 中国香港IP地址
cp ./Result/ipv4-hk.txt ${cn_ipv4_hk_list_filename}
cp ./Result/ipv4-hk.txt ${cn_ipv4_hk_route_filename}
cp ./Result/ipv6-hk.txt ${cn_ipv6_hk_list_filename}


# 手动添加额外需要加入的ipv4地址
#echo "8.8.4.4/32" >> ${cn_ipv4_source_filename}
#echo "8.8.8.8/32" >> ${cn_ipv4_source_filename}






# IPv4-CN Firewall Address-list 地址表
# 每行行首插入":do { add address="  list
sed -i 's/^/:do { add address=&/g' ${cn_ipv4_list_filename}

# 每行行尾插入" list=test } on-error={}"  list
sed -i 's/$/&\ list=$list timeout=$timeout comment=$comment } on-error={}/g' ${cn_ipv4_list_filename}

# 在文件第1行前插入新行“/log info "Loading CN ipv4 address list" ”  list
sed -i '1 i/log info "Loading CN ipv4 address list"' ${cn_ipv4_list_filename}

# 在文件第2行前插入新行":local timeout $timeout"  list
sed -i '2 i:local timeout '$timeout ${cn_ipv4_list_filename}

# 在文件第3行前插入新行":local comment cn"  list
sed -i '3 i:local comment '$commentcn ${cn_ipv4_list_filename}

# 在文件第4行前插入新行":local list cn"  list
sed -i '4 i:local list '$listcn ${cn_ipv4_list_filename}

# 在文件第5行前插入新行"/ip firewall address-list remove [/ip firewall address-list find list=cn]"  list
sed -i '5 i/ip firewall address-list remove [/ip firewall address-list find list=$list]' ${cn_ipv4_list_filename}

# 在文件第6行前插入新行"/ip firewall address-list"  list
sed -i '6 i/ip firewall address-list' ${cn_ipv4_list_filename}


# IPv4-CN Routing Rule 地址表
# 每行行首插入“ add dst-address=”  route
sed -i 's/^/:do { add dst-address=&/g' ${cn_ipv4_route_filename}

# 每行行尾插入“ action=lookup disabled=no table=$list comment=$comment”  route
sed -i 's/$/&\ action=lookup disabled=no table=$list comment=$comment } on-error={}/g' ${cn_ipv4_route_filename}

# 在文件第1行前插入新行“/log info "Loading CN ipv4 address routing" ”  route
sed -i '1 i/log info "Loading CN ipv4 address routing"' ${cn_ipv4_route_filename}

# 在文件第2行前插入新行":local comment cn"  route
sed -i '2 i:local comment '$commentcn ${cn_ipv4_route_filename}

# 在文件第3行前插入新行":local list cn"  route
sed -i '3 i:local list '$listcn ${cn_ipv4_route_filename}

# 在文件第4行前插入新行"/routing rule remove [/routing rule find table=$list]"  route
sed -i '4 i/routing rule remove [/routing rule find table=$list]' ${cn_ipv4_route_filename}

# 在文件第5行前插入新行"/routing table remove [/routing table find name=$list]]"  route
sed -i '5 i/routing table remove [/routing table find name=$list]' ${cn_ipv4_route_filename}

# 在文件第6行前插入新行"/routing table add name=$list fib disabled=no"  route
sed -i '6 i/routing table add name=$list fib disabled=no' ${cn_ipv4_route_filename}

# 在文件第7行前插入新行"/routing rule"  route
sed -i '7 i/routing rule' ${cn_ipv4_route_filename}


# IPv6-CN Firewall Address-list 地址表
# 每行行首插入":do { add address="  list
sed -i 's/^/:do { add address=&/g' ${cn_ipv6_list_filename}

# 每行行尾插入" list=test } on-error={}"  list
sed -i 's/$/&\ list=$list timeout=$timeout comment=$comment } on-error={}/g' ${cn_ipv6_list_filename}

# 在文件第1行前插入新行“/log info "Loading CN ipv6 address list" ”  list
sed -i '1 i/log info "Loading CN ipv6 address list"' ${cn_ipv6_list_filename}

# 在文件第2行前插入新行":local timeout $timeout"  list
sed -i '2 i:local timeout '$timeout ${cn_ipv6_list_filename}

# 在文件第3行前插入新行":local comment cn"  list
sed -i '3 i:local comment '$commentcn ${cn_ipv6_list_filename}

# 在文件第4行前插入新行":local list cn"  list
sed -i '4 i:local list '$listcn ${cn_ipv6_list_filename}

# 在文件第5行前插入新行"/ipv6 firewall address-list remove [/ipv6 firewall address-list find list=cn]"  list
sed -i '5 i/ipv6 firewall address-list remove [/ipv6 firewall address-list find list=$list]' ${cn_ipv6_list_filename}

# 在文件第6行前插入新行"/ipv6 firewall address-list"  list
sed -i '6 i/ipv6 firewall address-list' ${cn_ipv6_list_filename}



# IPv4-HK Firewall Address-list 地址表
# 每行行首插入":do { add address="  list
sed -i 's/^/:do { add address=&/g' ${cn_ipv4_hk_list_filename}

# 每行行尾插入" list=test } on-error={}"  list
sed -i 's/$/&\ list=$list timeout=$timeout comment=$comment } on-error={}/g' ${cn_ipv4_hk_list_filename}

# 在文件第1行前插入新行“/log info "Loading CN-HK ipv4 address list" ”  list
sed -i '1 i/log info "Loading CN-HK ipv4 address list"' ${cn_ipv4_hk_list_filename}

# 在文件第2行前插入新行":local timeout $timeout"  list
sed -i '2 i:local timeout '$timeout ${cn_ipv4_hk_list_filename}

# 在文件第3行前插入新行":local comment cn"  list
sed -i '3 i:local comment '$commenthk ${cn_ipv4_hk_list_filename}

# 在文件第4行前插入新行":local list cn"  list
sed -i '4 i:local list '$listhk ${cn_ipv4_hk_list_filename}

# 在文件第5行前插入新行"/ip firewall address-list remove [/ip firewall address-list find list=cn]"  list
sed -i '5 i/ip firewall address-list remove [/ip firewall address-list find list=$list]' ${cn_ipv4_hk_list_filename}

# 在文件第6行前插入新行"/ip firewall address-list"  list
sed -i '6 i/ip firewall address-list' ${cn_ipv4_hk_list_filename}


# IPv4-HK Routing Rule 地址表
# 每行行首插入“ add dst-address=”  route
sed -i 's/^/:do { add dst-address=&/g' ${cn_ipv4_hk_route_filename}

# 每行行尾插入“ action=lookup disabled=no table=$list comment=$comment”  route
sed -i 's/$/&\ action=lookup disabled=no table=$list comment=$comment } on-error={}/g' ${cn_ipv4_hk_route_filename}

# 在文件第1行前插入新行“/log info "Loading CN-HK ipv4 address routing" ”  route
sed -i '1 i/log info "Loading CN-HK ipv4 address routing"' ${cn_ipv4_hk_route_filename}

# 在文件第2行前插入新行":local comment cn"  route
sed -i '2 i:local comment '$commenthk ${cn_ipv4_hk_route_filename}

# 在文件第3行前插入新行":local list cn"  route
sed -i '3 i:local list '$listhk ${cn_ipv4_hk_route_filename}

# 在文件第4行前插入新行"/routing rule remove [/routing rule find table=$list]"  route
sed -i '4 i/routing rule remove [/routing rule find table=$list]' ${cn_ipv4_hk_route_filename}

# 在文件第5行前插入新行"/routing table remove [/routing table find name=$list]]"  route
sed -i '5 i/routing table remove [/routing table find name=$list]' ${cn_ipv4_hk_route_filename}

# 在文件第6行前插入新行"/routing table add name=$list fib disabled=no"  route
sed -i '6 i/routing table add name=$list fib disabled=no' ${cn_ipv4_hk_route_filename}

# 在文件第7行前插入新行"/routing rule"  route
sed -i '7 i/routing rule' ${cn_ipv4_hk_route_filename}


# IPv6-HK Firewall Address-list 地址表
# 每行行首插入":do { add address="  list
sed -i 's/^/:do { add address=&/g' ${cn_ipv6_hk_list_filename}

# 每行行尾插入" list=test } on-error={}"  list
sed -i 's/$/&\ list=$list timeout=$timeout comment=$comment } on-error={}/g' ${cn_ipv6_hk_list_filename}

# 在文件第1行前插入新行“/log info "Loading CN-HK ipv6 address list" ”  list
sed -i '1 i/log info "Loading CN-HK ipv6 address list"' ${cn_ipv6_hk_list_filename}

# 在文件第2行前插入新行":local timeout $timeout"  list
sed -i '2 i:local timeout '$timeout ${cn_ipv6_hk_list_filename}

# 在文件第3行前插入新行":local comment cn"  list
sed -i '3 i:local comment '$commenthk ${cn_ipv6_hk_list_filename}

# 在文件第4行前插入新行":local list cn"  list
sed -i '4 i:local list '$listhk ${cn_ipv6_hk_list_filename}

# 在文件第5行前插入新行"/ipv6 firewall address-list remove [/ipv6 firewall address-list find list=cn]"  list
sed -i '5 i/ipv6 firewall address-list remove [/ipv6 firewall address-list find list=$list]' ${cn_ipv6_hk_list_filename}

# 在文件第6行前插入新行"/ipv6 firewall address-list"  list
sed -i '6 i/ipv6 firewall address-list' ${cn_ipv6_hk_list_filename}



# 删除list文件尾的换行（可选）
#tail -n 1 ${cn_ipv4_list_filename} | tr -d '\n' >> gfwlist_lastline_tmp
#sed -i '$d' ${cn_ipv4_list_filename}
#sed -i '$r gfwlist_lastline_tmp' ${cn_ipv4_list_filename}
#rm -f gfwlist_lastline_tmp

# 删除route文件尾的换行（可选）
#tail -n 1 ${cn_ipv4_route_filename} | tr -d '\n' >> gfwlist_lastline_tmp
#sed -i '$d' ${cn_ipv4_route_filename}
#sed -i '$r gfwlist_lastline_tmp' ${cn_ipv4_route_filename}
#rm -f gfwlist_lastline_tmp

# 删除list文件尾的换行（可选）
#tail -n 1 ${cn_ipv6_list_filename} | tr -d '\n' >> gfwlist_lastline_tmp
#sed -i '$d' ${cn_ipv6_list_filename}
#sed -i '$r gfwlist_lastline_tmp' ${cn_ipv6_list_filename}
#rm -f gfwlist_lastline_tmp


# 删除list文件尾的换行（可选）
#tail -n 1 ${cn_ipv4_hk_list_filename} | tr -d '\n' >> gfwlist_lastline_tmp
#sed -i '$d' ${cn_ipv4_hk_list_filename}
#sed -i '$r gfwlist_lastline_tmp' ${cn_ipv4_hk_list_filename}
#rm -f gfwlist_lastline_tmp

# 删除route文件尾的换行（可选）
#tail -n 1 ${cn_ipv4_hk_route_filename} | tr -d '\n' >> gfwlist_lastline_tmp
#sed -i '$d' ${cn_ipv4_hk_route_filename}
#sed -i '$r gfwlist_lastline_tmp' ${cn_ipv4_hk_route_filename}
#rm -f gfwlist_lastline_tmp

# 删除list文件尾的换行（可选）
#tail -n 1 ${cn_ipv6_hk_list_filename} | tr -d '\n' >> gfwlist_lastline_tmp
#sed -i '$d' ${cn_ipv6_hk_list_filename}
#sed -i '$r gfwlist_lastline_tmp' ${cn_ipv6_hk_list_filename}
#rm -f 
