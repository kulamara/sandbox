@echo off
chcp 65001 >nul
echo.
echo ========================================
echo 🚀 安全数据分析沙箱 - 快速演示脚本
echo ========================================
echo.

echo 📋 演示步骤：
echo 1. 部署安全沙箱
echo 2. 验证安全特性
echo 3. 测试PII检测
echo 4. 演示命令安装
echo 5. 启动Web界面
echo.

pause

echo.
echo 🔧 第一步：部署安全沙箱...
echo.
wsl ./deploy.sh
if errorlevel 1 (
    echo ❌ 部署失败，请检查Docker服务是否运行
    pause
    exit /b 1
)

echo.
echo ✅ 沙箱部署成功！
echo.
echo 🔍 第二步：验证容器状态...
wsl bash -c "docker ps | grep secure-sandbox"

echo.
echo 📝 第三步：进入沙箱进行安全验证...
echo.
echo 即将进入沙箱环境，请依次执行以下命令验证安全特性：
echo.
echo   whoami                    # 查看当前用户
echo   ping google.com           # 验证网络隔离（应该失败）
echo   sudo su                   # 验证权限控制（应该失败）
echo   apt install vim           # 验证工具移除（应该失败）
echo   scan_data                 # 测试PII检测功能
echo   install_command wrong-token hello_world.sh  # 测试错误令牌（应该失败）
echo   install_command replace-with-your-actual-secure-token hello_world.sh  # 正确令牌
echo   hello_world.sh            # 测试新安装的命令
echo   exit                      # 退出沙箱
echo.

pause

wsl docker exec -it secure-sandbox /bin/sh

echo.
echo 🌐 第四步：启动Web管理界面...
echo.
echo 正在启动Web应用，请在浏览器中访问: http://localhost:5000
echo 按 Ctrl+C 可停止Web服务
echo.

wsl bash -c "cd /mnt/d/playground/py/sandbox/web_interface && source venv/bin/activate && python app.py"

echo.
echo 🎉 演示完成！
pause