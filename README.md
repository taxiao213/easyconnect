# EasyConnect Docker 使用指南

在 macOS 上使用 Docker 隔离运行 EasyConnect VPN，避免其后台监控和系统侵入问题。

---

## 目录

- [环境要求](#环境要求)
- [快速开始](#快速开始)
- [访问方式](#访问方式)
- [终端代理配置](#终端代理配置)
- [浏览器代理配置](#浏览器代理配置)
- [SSH 连接内网](#ssh-连接内网)
- [常用命令](#常用命令)
- [故障排除](#故障排除)

---

## 环境要求

- macOS 10.15+
- Docker Desktop 已安装并运行
- 端口未被占用：5901、6080、1080、8888

---

## 快速开始

### 1. 启动 EasyConnect

```bash
cd /Users/secneo/Documents/bangcle/easyconnect
./start.sh
```

或手动启动：

```bash
docker-compose up -d
```

### 2. 登录 VPN

1. 浏览器打开 http://localhost:6080
2. 输入 VNC 密码：`easyconnect`
3. 在 EasyConnect 界面输入服务器地址和账号密码登录

### 3. 开启终端代理

```bash
# EasyConnect VPN 代理
alias vpn-on='export http_proxy=http://127.0.0.1:8888 https_proxy=http://127.0.0.1:8888 all_proxy=socks5://127.0.0.1:1080 && echo "VPN 代理已开启"'
alias vpn-off='unset http_proxy https_proxy all_proxy && echo "VPN 代理已关闭"'

source ~/.zshrc
vpn-on
```

### 4. 测试连接

```bash
# 测试 HTTP 访问
curl http://172.16.x.x

# 测试 SSH 连接
ssh user@172.16.x.x
```

---

## 访问方式

| 服务 | 地址 | 密码/说明 |
|------|------|-----------|
| Web VNC | http://localhost:6080 | VNC 密码：`easyconnect` |
| VNC 客户端 | vnc://localhost:5901 | VNC 密码：`easyconnect` |
| SOCKS5 代理 | 127.0.0.1:1080 | 用于 TCP/SSH |
| HTTP 代理 | 127.0.0.1:8888 | 用于 HTTP/HTTPS |

---

## 终端代理配置

### 开启/关闭代理

已在 `~/.zshrc` 配置别名：

```bash
vpn-on   # 开启代理
vpn-off  # 关闭代理
```

### 手动设置

```bash
# 开启代理
export http_proxy=http://127.0.0.1:8888
export https_proxy=http://127.0.0.1:8888
export all_proxy=socks5://127.0.0.1:1080

# 关闭代理
unset http_proxy https_proxy all_proxy
```

### 测试代理

```bash
# 通过 SOCKS5 测试
curl --socks5 127.0.0.1:1080 http://172.16.x.x

# 开启代理后直接访问
vpn-on
curl http://172.16.x.x
```

---

## 浏览器代理配置

### 方式一：ClashX（推荐）

编辑 Clash 配置文件，添加：

```yaml
proxies:
  - name: "EasyConnect"
    type: socks5
    server: 127.0.0.1
    port: 1080

rules:
  # 公司内网 172.16.*.* 走 EasyConnect
  - IP-CIDR,172.16.0.0/16,EasyConnect
```

重载配置后生效。

### 方式二：SwitchyOmega 插件

1. 安装 [SwitchyOmega](https://chrome.google.com/webstore/detail/proxy-switchyomega/padekgcemlokbadohgkifijomclgjgif) 浏览器插件
2. 新建情景模式 → 代理服务器
3. 配置：
   - 代理协议：SOCKS5
   - 代理服务器：`127.0.0.1`
   - 端口：`1080`
4. 设置自动切换规则：目标 IP `172.16.0.0/16` 走代理

### 方式三：Chrome 命令行

```bash
# 使用代理启动 Chrome
open -a "Google Chrome" --args --proxy-server="socks5://127.0.0.1:1080"
```

---

## SSH 连接内网

### 已配置自动代理

`~/.ssh/config` 已配置 `172.16.*.*` 网段自动走代理：

```bash
# 直接连接即可
ssh user@172.16.9.66
```

### 手动指定代理

```bash
ssh -o ProxyCommand="nc -X 5 -x 127.0.0.1:1080 %h %p" user@172.16.9.66
```

### 指定端口

```bash
ssh -p 22 user@172.16.9.66
```

### 调试连接

```bash
ssh -v user@172.16.9.66
```

---

## 常用命令

### Docker 管理

```bash
# 启动
./start.sh
# 或
docker-compose up -d

# 停止
./stop.sh
# 或
docker-compose down

# 重启
docker-compose restart

# 查看状态
docker-compose ps

# 查看日志
docker-compose logs -f

# 进入容器
docker exec -it easyconnect bash
```

### 代理管理

```bash
# 开启终端代理
vpn-on

# 关闭终端代理
vpn-off

# 查看当前代理设置
env | grep -i proxy
```

### 端口检查

```bash
# 检查代理端口
nc -zv localhost 1080
nc -zv localhost 8888
nc -zv localhost 6080

# 检查端口占用
lsof -i :1080
lsof -i :8888
```

---

## 故障排除

### 1. 无法打开 Web VNC (localhost:6080)

**检查容器状态：**
```bash
docker-compose ps
docker-compose logs
```

**检查端口：**
```bash
nc -zv localhost 6080
```

**重启容器：**
```bash
docker-compose restart
```

### 2. VNC 连接被拒绝

确认密码正确：`easyconnect`

重启容器重新生成密码：
```bash
docker-compose down && docker-compose up -d
```

### 3. 终端代理不生效

**确认已加载配置：**
```bash
source ~/.zshrc
vpn-on
```

**检查环境变量：**
```bash
echo $http_proxy
echo $all_proxy
```

**测试代理：**
```bash
curl --socks5 127.0.0.1:1080 http://www.baidu.com
```

### 4. 无法访问内网

**确认已登录 EasyConnect：**
- 打开 http://localhost:6080
- 检查 EasyConnect 是否显示已连接

**检查代理端口：**
```bash
nc -zv localhost 1080
nc -zv localhost 8888
```

### 5. SSH 连接失败

**手动测试代理：**
```bash
ssh -v -o ProxyCommand="nc -X 5 -x 127.0.0.1:1080 %h %p" user@172.16.x.x
```

**检查 SSH 配置：**
```bash
cat ~/.ssh/config
```

**确认 nc 命令可用：**
```bash
which nc
```

### 6. 端口被占用

```bash
# 查找占用进程
lsof -i :端口号

# 杀死进程
kill -9 PID
```

---

## 文件结构

```
easyconnect/
├── docker-compose.yml  # Docker 配置
├── start.sh            # 启动脚本
├── stop.sh             # 停止脚本
├── README.md           # 使用说明
└── data/               # 持久化数据
```

---

## 安全说明

使用 Docker 隔离 EasyConnect 的优势：

- ✅ 防止后台进程常驻系统
- ✅ 阻止监控软件安装
- ✅ 限制文件系统访问
- ✅ 隔离网络活动
- ✅ 可随时销毁容器清理痕迹

---

## 相关链接

- [docker-easyconnect 项目](https://github.com/Hagb/docker-easyconnect)
- [Docker Desktop 下载](https://www.docker.com/products/docker-desktop)
