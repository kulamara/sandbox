@echo off
chcp 65001 >nul
echo 🚀 启动安全数据分析沙箱Web管理界面...

REM 检查Python是否安装
python --version >nul 2>&1
if errorlevel 1 (
    echo ❌ 错误: 未找到Python，请先安装Python3
    pause
    exit /b 1
)

REM 进入web_interface目录
cd /d "%~dp0"

REM 检查虚拟环境是否存在
if not exist "venv" (
    echo 📦 创建Python虚拟环境...
    python -m venv venv
)

REM 激活虚拟环境
echo 🔧 激活虚拟环境...
call venv\Scripts\activate.bat

REM 安装依赖
echo 📥 安装Python依赖包...
pip install -r requirements.txt

REM 检查Docker是否可用
docker --version >nul 2>&1
if errorlevel 1 (
    echo ⚠️  警告: 未找到Docker命令，请确保Docker已安装并可访问
)

REM 启动Web应用
echo 🌐 启动Web服务器...
echo 📍 访问地址: http://localhost:5000
echo 🔄 按Ctrl+C停止服务
echo.

python app.py
pause