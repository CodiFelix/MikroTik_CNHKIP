# MikroTik 中国大陆/香港 IP 地址列表生成工具

> 该脚本设定为每日凌晨 4:00 自动执行更新。

自动从 APNIC 获取最新的中国大陆(CN)和香港(HK)IP 地址数据，生成适用于 MikroTik RouterOS 的防火墙地址列表和路由规则脚本。

## 🚀 快捷导入方式（推荐）

如果您的 MikroTik 路由器可以直接访问 GitHub，可以使用以下命令直接下载并导入脚本，**无需手动生成和上传文件**。

### 📥 导入中国大陆 IPv4 地址列表

```routeros
/tool/fetch url="https://raw.githubusercontent.com/CodiFelix/MikroTik_CNHKIP/main/Result/cn_ipv4_list.rsc" mode=https dst-path=cn_ipv4_list.rsc
/import cn_ipv4_list.rsc
```

### 📦 导入所有列表（一键执行）

```routeros
# 下载所有脚本文件
/tool/fetch url="https://raw.githubusercontent.com/CodiFelix/MikroTik_CNHKIP/main/Result/cn_ipv4_list.rsc" mode=https dst-path=cn_ipv4_list.rsc
/tool/fetch url="https://raw.githubusercontent.com/CodiFelix/MikroTik_CNHKIP/main/Result/cn_ipv6_list.rsc" mode=https dst-path=cn_ipv6_list.rsc
/tool/fetch url="https://raw.githubusercontent.com/CodiFelix/MikroTik_CNHKIP/main/Result/cn_ipv4_hk_list.rsc" mode=https dst-path=cn_ipv4_hk_list.rsc
/tool/fetch url="https://raw.githubusercontent.com/CodiFelix/MikroTik_CNHKIP/main/Result/cn_ipv6_hk_list.rsc" mode=https dst-path=cn_ipv6_hk_list.rsc
/tool/fetch url="https://raw.githubusercontent.com/CodiFelix/MikroTik_CNHKIP/main/Result/cn_ipv4_route.rsc" mode=https dst-path=cn_ipv4_route.rsc
/tool/fetch url="https://raw.githubusercontent.com/CodiFelix/MikroTik_CNHKIP/main/Result/cn_ipv4_hk_route.rsc" mode=https dst-path=cn_ipv4_hk_route.rsc

# 等待下载完成后，导入所有脚本
:delay 15s
/import cn_ipv4_list.rsc
/import cn_ipv6_list.rsc
/import cn_ipv4_hk_list.rsc
/import cn_ipv6_hk_list.rsc
/import cn_ipv4_route.rsc
/import cn_ipv4_hk_route.rsc
```

### 🔄 自动化更新（定时任务）

创建一个 MikroTik 定时任务，每周自动更新地址列表：

```routeros
/system scheduler
add name=update-cn-ip-list interval=7d start-date=2026-02-01 start-time=03:00:00 \
on-event="/tool/fetch url=\"https://raw.githubusercontent.com/CodiFelix/MikroTik_CNHKIP/main/Result/cn_ipv4_list.rsc\" mode=https dst-path=cn_ipv4_list.rsc\r\
\n:delay 15s\r\
\n/import cn_ipv4_list.rsc\r\
\n/log info \"CN IP list updated successfully\""
```

### 📝 使用说明

1. **打开 Terminal**：在 MikroTik 路由器中打开 Terminal 或通过 SSH 连接
2. **复制粘贴命令**：直接复制上述命令到 Terminal 执行
3. **查看导入进度**：使用 `/file print` 查看下载文件，使用 `/log print` 查看导入日志
4. **验证导入结果**：使用 `/ip firewall address-list print count-only where list=CN` 查看地址数量

### ⚠️ 注意事项

- MikroTik 路由器需要能够访问 GitHub（raw.githubusercontent.com）
- 首次使用前请确保 GitHub 仓库中已有最新的 `.rsc` 文件
- 如果 GitHub 访问受限，请使用下方的手动生成方式
- 建议先在测试设备上验证后再应用到生产环境

---

## 📋 项目简介

本工具从 APNIC（亚太互联网络信息中心）自动下载最新的 IP 地址分配数据，提取中国大陆和香港的 IPv4 和 IPv6 地址段，并生成可直接在 MikroTik RouterOS 中导入使用的 `.rsc` 脚本文件。

**主要功能**：
- ✅ 支持中国大陆(CN)和香港(HK)独立列表
- ✅ 支持 IPv4 和 IPv6 双协议栈
- ✅ 生成防火墙地址列表和路由规则
- ✅ 自动错误容错和完成日志

---

## 🛠️ 手动生成方式（高级用户）

如果需要自定义配置或 GitHub 访问受限，可以使用以下方式手动生成脚本。

### 系统要求
- 支持的操作系统：CentOS、Debian、Ubuntu 等 Linux 系统
- 依赖工具：wget、curl、awk、sed（脚本会自动安装）

### 快速开始

```bash
# 1. 克隆项目
git clone https://github.com/CodiFelix/MikroTik_CNHKIP.git
cd MikroTik_CNHKIP

# 2. 创建结果目录
mkdir -p Result

# 3. 执行脚本
chmod +x allcn-ip-list.sh
./allcn-ip-list.sh
```

### 生成的文件

脚本执行完成后，在 `./Result/` 目录下会生成以下文件：

**中国大陆 (CN)**：
- `cn_ipv4_list.rsc` - IPv4 防火墙地址列表
- `cn_ipv4_route.rsc` - IPv4 路由规则
- `cn_ipv6_list.rsc` - IPv6 防火墙地址列表

**香港 (HK)**：
- `cn_ipv4_hk_list.rsc` - IPv4 防火墙地址列表
- `cn_ipv4_hk_route.rsc` - IPv4 路由规则
- `cn_ipv6_hk_list.rsc` - IPv6 防火墙地址列表

### 导入到 MikroTik

生成文件后，通过以下任一方式导入：

**方式1 - Winbox**：Files 菜单上传文件，然后 Terminal 执行 `/import filename.rsc`

**方式2 - SSH**：使用 SCP 上传文件，然后 SSH 登录执行 `/import filename.rsc`

**方式3 - 复制粘贴**：打开 `.rsc` 文件，复制内容直接粘贴到 MikroTik Terminal

---

## 📝 脚本输出示例

### IPv4 防火墙地址列表 (cn_ipv4_list.rsc)

```routeros
/log info "Loading CN ipv4 address list"
/ip firewall address-list remove [find list=CN]
/ip firewall address-list
:do { add address=1.0.1.0/24 list=CN timeout=0 comment=CN } on-error={}
:do { add address=1.0.2.0/23 list=CN timeout=0 comment=CN } on-error={}
:do { add address=1.0.8.0/21 list=CN timeout=0 comment=CN } on-error={}
...
:log info "Complete CN_IPv4_LIST !!"
```

### IPv4 路由规则 (cn_ipv4_route.rsc)

```routeros
/log info "Loading CN ipv4 address routing"
/routing rule remove [find table=CN]
/routing table add name=CN fib disabled=no
/routing rule
:do { add dst-address=1.0.1.0/24 action=lookup disabled=no table=CN comment=CN } on-error={}
:do { add dst-address=1.0.2.0/23 action=lookup disabled=no table=CN comment=CN } on-error={}
...
:log info "Complete CN_IPv4_ROUTE !!"
```

---

## 💡 应用场景示例

### 国内外流量分流
```routeros
# 中国大陆流量走直连，其他流量走代理
/ip firewall mangle
add chain=prerouting dst-address-list=CN action=mark-routing new-routing-mark=direct
add chain=prerouting action=mark-routing new-routing-mark=proxy
```

### 防火墙访问控制
```routeros
# 只允许中国大陆 IP 访问
/ip firewall filter
add chain=input src-address-list=CN action=accept
add chain=input action=drop
```

### 策略路由
```routeros
# 中国 IP 使用电信线路，其他使用国际线路
/ip route
add dst-address=0.0.0.0/0 gateway=电信网关 routing-mark=CN-Route
add dst-address=0.0.0.0/0 gateway=国际网关 routing-mark=Other-Route
```

---

## ⚙️ 配置说明

**列表名称**：CN (中国大陆) / HK (香港)  
**超时时间**：默认 0 (永不过期)  
**添加自定义地址**：在脚本中取消注释相关行，添加额外 IP 地址

---

## 📊 性能参考

| 设备型号 | RAM | 导入时间 | 状态 |
|---------|-----|---------|------|
| RB750Gr3 | 256MB | ~3分钟 | ✅ 正常 |
| RB4011 | 1GB | ~1分钟 | ✅ 优秀 |
| CCR1009 | 2GB | ~30秒 | ✅ 优秀 |
| hEX lite | 64MB | ~10分钟 | ⚠️ 卡顿 |

---

## ⚠️ 注意事项

- **定期更新**：IP 地址分配会变化，建议每月更新一次
- **系统资源**：完整 CN 列表约 8000+ 条目，低配设备可能响应缓慢
- **备份配置**：导入前务必使用 `/export file=backup` 备份配置
- **测试验证**：首次使用建议先在测试环境验证

---

## 🐛 常见问题

**Q: MikroTik 无法访问 GitHub 怎么办？**  
A: 使用手动生成方式，在 Linux 服务器上运行脚本生成文件，然后手动上传到 MikroTik。

**Q: 导入后路由器卡顿？**  
A: 地址列表较大，低配设备可能性能不足，建议只导入必要的列表或升级设备。

**Q: 如何查看导入进度？**  
A: 使用 `/log print` 查看日志，使用 `/ip firewall address-list print count-only where list=CN` 查看数量。

---

## 📚 数据来源

- **APNIC** (Asia-Pacific Network Information Centre)
- 数据源：http://ftp.apnic.net/stats/apnic/delegated-apnic-latest
- 更新频率：APNIC 每日更新

---

## 🤝 贡献与支持

欢迎提交 Issue 和 Pull Request！

**项目维护**：
- 报告问题：提交 Issue 描述遇到的问题
- 改进建议：提交 PR 或在 Discussions 讨论
- 分享经验：Star 项目并分享给需要的人

**联系方式**：
- GitHub Issues: [提交问题](https://github.com/CodiFelix/MikroTik_CNHKIP/issues)
- Email: Codifelix@FelixBlaze.com

---

## ⚖️ 许可证 (License)

本项目采用 [MIT License](LICENSE) 授权。

Copyright (c) 2026 FelixBlaze

> **注意：** 本项目仅供学习和研究使用，请在法律允许的范围内使用。作者不对任何因误用、非法使用或操作不当导致的后果承担法律责任。

---

如果这个项目对您有帮助，请给个 Star ⭐！

**最后更新**: 2026年2月10日  
**脚本版本**: 2.0.0  
**测试环境**: RouterOS v7.13  
**作者**: CodiFelix
**仓库**: https://github.com/CodiFelix/MikroTik_CNHKIP
