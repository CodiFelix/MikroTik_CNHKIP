#!/bin/bash
chmod +x allcn-ip-list.sh

if [[ $(/usr/bin/id -u) -ne 0 ]]; then
  sudoCmd="sudo"
else
  sudoCmd=""
fi

# www.github.com/ITinflect-Ctrl，MikroTik CN_HK address list scripts
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

# 从apnic下载全球地址分配表
wget -c http://ftp.apnic.net/stats/apnic/delegated-apnic-latest > /dev/null 2>&1

# wait for 1s
sleep 1

# 分类 CN和HK，ipv4和ipv6 地址
cat delegated-apnic-latest | awk -F '|' '/CN/&&/ipv4/ {print $4 "/" 32-log($5)/log(2)}' | cat > ./Result/ipv4-cn.txt
cat delegated-apnic-latest | awk -F '|' '/CN/&&/ipv6/ {print $4 "/" $5}' | cat > ./Result/ipv6-cn.txt
cat delegated-apnic-latest | awk -F '|' '/HK/&&/ipv4/ {print $4 "/" 32-log($5)/log(2)}' | cat > ./Result/ipv4-hk.txt
cat delegated-apnic-latest | awk -F '|' '/HK/&&/ipv6/ {print $4 "/" $5}' | cat > ./Result/ipv6-hk.txt

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
sed -i 's/^/:do { add address=&/g' ${cn_ipv4_list_filename}
sed -i 's/$/&\ list=CN timeout=0 comment=CN } on-error={}/g' ${cn_ipv4_list_filename}
sed -i '1 i/log info "Loading CN ipv4 address list"' ${cn_ipv4_list_filename}
sed -i '2 i/ip firewall address-list remove [find list=CN]' ${cn_ipv4_list_filename}
sed -i '3 i/ip firewall address-list' ${cn_ipv4_list_filename}
sed -i '$a\:log info "Complete CN_IPv4_LIST !!"' ${cn_ipv4_list_filename}

# IPv4-CN Routing Rule 地址表
sed -i 's/^/:do { add dst-address=&/g' ${cn_ipv4_route_filename}
sed -i 's/$/&\ action=lookup disabled=no table=CN comment=CN } on-error={}/g' ${cn_ipv4_route_filename}
sed -i '1 i/log info "Loading CN ipv4 address routing"' ${cn_ipv4_route_filename}
sed -i '2 i/routing rule remove [find table=CN]' ${cn_ipv4_route_filename}
sed -i '3 i/routing table add name=CN fib disabled=no' ${cn_ipv4_route_filename}
sed -i '4 i/routing rule' ${cn_ipv4_route_filename}
sed -i '$a\:log info "Complete CN_IPv4_ROUTE !!"' ${cn_ipv4_route_filename}

# IPv6-CN Firewall Address-list 地址表
sed -i 's/^/:do { add address=&/g' ${cn_ipv6_list_filename}
sed -i 's/$/&\ list=CN timeout=0 comment=CN } on-error={}/g' ${cn_ipv6_list_filename}
sed -i '1 i/log info "Loading CN ipv6 address list"' ${cn_ipv6_list_filename}
sed -i '2 i/ipv6 firewall address-list remove [find list=CN]' ${cn_ipv6_list_filename}
sed -i '3 i/ipv6 firewall address-list' ${cn_ipv6_list_filename}
sed -i '$a\:log info "Complete CN_IPv6_LIST !!"' ${cn_ipv6_list_filename}

# IPv4-HK Firewall Address-list 地址表
sed -i 's/^/:do { add address=&/g' ${cn_ipv4_hk_list_filename}
sed -i 's/$/&\ list=HK timeout=0 comment=HK } on-error={}/g' ${cn_ipv4_hk_list_filename}
sed -i '1 i/log info "Loading HK ipv4 address list"' ${cn_ipv4_hk_list_filename}
sed -i '2 i/ip firewall address-list remove [find list=HK]' ${cn_ipv4_hk_list_filename}
sed -i '3 i/ip firewall address-list' ${cn_ipv4_hk_list_filename}
sed -i '$a\:log info "Complete HK_IPv4_LIST !!"' ${cn_ipv4_hk_list_filename}

# IPv4-HK Routing Rule 地址表
sed -i 's/^/:do { add dst-address=&/g' ${cn_ipv4_hk_route_filename}
sed -i 's/$/&\ action=lookup disabled=no table=HK comment=HK } on-error={}/g' ${cn_ipv4_hk_route_filename}
sed -i '1 i/log info "Loading HK ipv4 address routing"' ${cn_ipv4_hk_route_filename}
sed -i '2 i/routing rule remove [find table=HK]' ${cn_ipv4_hk_route_filename}
sed -i '3 i/routing table add name=HK fib disabled=no' ${cn_ipv4_hk_route_filename}
sed -i '4 i/routing rule' ${cn_ipv4_hk_route_filename}
sed -i '$a\:log info "Complete HK_IPv4_ROUTE !!"' ${cn_ipv4_hk_route_filename}

# IPv6-HK Firewall Address-list 地址表
sed -i 's/^/:do { add address=&/g' ${cn_ipv6_hk_list_filename}
sed -i 's/$/&\ list=HK timeout=0 comment=HK } on-error={}/g' ${cn_ipv6_hk_list_filename}
sed -i '1 i/log info "Loading HK ipv6 address list"' ${cn_ipv6_hk_list_filename}
sed -i '2 i/ipv6 firewall address-list remove [find list=HK]' ${cn_ipv6_hk_list_filename}
sed -i '3 i/ipv6 firewall address-list' ${cn_ipv6_hk_list_filename}
sed -i '$a\:log info "Complete HK_IPv6_LIST !!"' ${cn_ipv6_hk_list_filename}