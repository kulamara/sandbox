#!/bin/bash

# start_web.sh: 启动Web管理界面的脚本

echo "🚀 启动安全数据分析沙箱Web管理界面..."

# 检查Python是否安装
if ! command -v python3 &> /dev/null; then
    echo "❌ 错误: 未找到Python3，请先安装Python3"
    echo "   Ubuntu/Debian: sudo apt update && sudo apt install python3 python3-pip python3-venv"
    echo "   CentOS/RHEL: sudo yum install python3 python3-pip"
    exit 1
fi

# 检查pip是否安装
if ! command -v pip3 &> /dev/null; then
    echo "❌ 错误: 未找到pip3，请先安装pip3"
    echo "   Ubuntu/Debian: sudo apt install python3-pip"
    echo "   CentOS/RHEL: sudo yum install python3-pip"
    exit 1
fi

# 进入web_interface目录
cd "$(dirname "$0")"

# 检查虚拟环境是否存在
if [ ! -d "venv" ]; then
    echo "📦 创建Python虚拟环境..."
    python3 -m venv venv
    if [ $? -ne 0 ]; then
        echo "❌ 虚拟环境创建失败，请安装python3-venv"
        echo "   Ubuntu/Debian: sudo apt install python3-venv"
        exit 1
    fi
fi

# 激活虚拟环境
echo "🔧 激活虚拟环境..."
source venv/bin/activate

# 升级pip
echo "⬆️  升级pip..."
pip install --upgrade pip

# 安装依赖
echo "📥 安装Python依赖包..."
pip install -r requirements.txt
if [ $? -ne 0 ]; then
    echo "❌ 依赖安装失败，尝试使用国内镜像..."
    pip install -i https://pypi.tuna.tsinghua.edu.cn/simple -r requirements.txt
fi

# 检查Docker是否可用
if ! command -v docker &> /dev/null; then
    echo "⚠️  警告: 未找到Docker命令，请确保Docker已安装并可访问"
    echo "   安装Docker: https://docs.docker.com/engine/install/"
else
    # 检查Docker服务是否运行
    if ! docker info &> /dev/null; then
        echo "⚠️  警告: Docker服务未运行，请启动Docker服务"
        echo "   启动Docker: sudo systemctl start docker"
        echo "   开机自启: sudo systemctl enable docker"
    else
        echo "✅ Docker服务正常运行"
    fi
fi

# 检查端口是否被占用
if netstat -tuln 2>/dev/null | grep -q ":5000 "; then
    echo "⚠️  警告: 端口5000已被占用，Web服务可能无法启动"
    echo "   请检查其他应用或修改app.py中的端口号"
fi

# 启动Web应用
echo ""
echo "🌐 启动Web服务器..."
echo "📍 本地访问: http://localhost:5000"
echo "📍 网络访问: http://$(hostname -I | awk '{print $1}'):5000"
echo "🔄 按Ctrl+C停止服务"
echo "📋 日志输出:"
echo "----------------------------------------"

python app.py