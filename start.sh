#!/bin/bash

# EasyConnect Docker 启动脚本

set -e

echo "🚀 启动 EasyConnect Docker 容器..."

# 检查 Docker 是否运行
if ! docker info &> /dev/null; then
    echo "❌ Docker 未运行，请先启动 Docker Desktop"
    exit 1
fi

# 创建数据目录
mkdir -p data

# 启动容器
docker-compose up -d

echo ""
echo "✅ EasyConnect 已启动！"
echo ""
echo "📱 访问方式："
echo "   Web VNC: http://localhost:6080"
echo "   VNC 客户端: vnc://localhost:5901"
echo ""
echo "🔑 VNC 密码: easyconnect"
echo ""
echo "💡 使用提示："
echo "   1. 打开浏览器访问 http://localhost:6080"
echo "   2. 在 EasyConnect 界面输入服务器地址和账号密码"
echo "   3. 连接成功后，VPN 流量将通过容器路由"
echo ""
echo "📋 常用命令："
echo "   查看日志: docker-compose logs -f"
echo "   停止容器: docker-compose down"
echo "   重启容器: docker-compose restart"
