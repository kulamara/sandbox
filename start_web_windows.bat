@echo off
chcp 65001 >nul
title 安全数据分析沙箱 - Web管理界面

echo.
echo ========================================
echo 🌐 安全数据分析沙箱 - Web管理界面
echo ========================================
echo.

echo 📋 启动步骤：
echo 1. 检查环境依赖
echo 2. 验证容器状态  
echo 3. 启动Web应用
echo 4. 打开浏览器访问
echo.

echo 🔍 第一步：检查环境...
echo.

REM 检查WSL
wsl --version >nul 2>&1
if errorlevel 1 (
    echo ❌ WSL未安装或未启用
    echo 请先安装WSL2: https://docs.microsoft.com/zh-cn/windows/wsl/install
    pause
    exit /b 1
)
echo ✅ WSL环境正常

REM 检查Docker
wsl docker --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Docker未安装或未启动
    echo 请先安装Docker Desktop: https://www.docker.com/products/docker-desktop
    pause
    exit /b 1
)
echo ✅ Docker环境正常

echo.
echo 🔍 第二步：验证容器状态...
echo.

wsl bash -c "docker ps | grep secure-sandbox" >nul 2>&1
if errorlevel 1 (
    echo ⚠️  容器未运行，正在启动...
    echo.
    wsl ./deploy.sh
    if errorlevel 1 (
        echo ❌ 容器启动失败
        pause
        exit /b 1
    )
) else (
    echo ✅ 容器正在运行
)

echo.
echo 🔍 第三步：检查Python环境...
echo.

wsl bash -c "cd /mnt/d/playground/py/sandbox/web_interface && test -d venv" >nul 2>&1
if errorlevel 1 (
    echo 📦 创建Python虚拟环境...
    wsl bash -c "cd /mnt/d/playground/py/sandbox/web_interface && python3 -m venv venv"
    if errorlevel 1 (
        echo ❌ 虚拟环境创建失败
        pause
        exit /b 1
    )
)

echo 📥 安装Python依赖...
wsl bash -c "cd /mnt/d/playground/py/sandbox/web_interface && source venv/bin/activate && pip install -r requirements.txt" >nul 2>&1
if errorlevel 1 (
    echo ❌ 依赖安装失败
    pause
    exit /b 1
)

echo ✅ Python环境准备完成

echo.
echo 🌐 第四步：启动Web应用...
echo.
echo 📍 访问地址: http://localhost:5000
echo 🔄 按Ctrl+C可停止服务
echo 📱 建议使用Chrome或Firefox浏览器
echo.

REM 延迟3秒后自动打开浏览器
start "" cmd /c "timeout /t 3 >nul && start http://localhost:5000"

echo 🚀 正在启动Web服务器...
echo ========================================
echo.

REM 启动Web应用
wsl bash -c "cd /mnt/d/playground/py/sandbox/web_interface && source venv/bin/activate && python app.py"

echo.
echo 🛑 Web服务已停止
pause