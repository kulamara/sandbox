@echo off
chcp 65001 >nul
echo.
echo ========================================
echo 🚀 准备Git提交 - 安全数据分析沙箱
echo ========================================
echo.

echo 🔍 第一步：检查当前Git状态...
git status

echo.
echo ========================================
echo 📁 第二步：添加所有应该提交的文件...
echo ========================================

REM 添加所有文件（.gitignore会自动排除不需要的文件）
git add .

echo ✅ 文件添加完成

echo.
echo ========================================
echo 🔍 第三步：检查暂存区文件...
echo ========================================
echo 📋 将要提交的文件：
git diff --cached --name-only

echo.
echo ========================================
echo ⚠️  第四步：安全检查
echo ========================================
echo 🔍 检查是否有不应该提交的文件...

REM 检查虚拟环境是否被意外添加
git diff --cached --name-only | findstr "venv" >nul
if not errorlevel 1 (
    echo ❌ 警告：检测到虚拟环境文件，正在移除...
    git reset HEAD web_interface/venv/
    git reset HEAD venv/
)

REM 检查IDE配置是否被意外添加
git diff --cached --name-only | findstr ".vscode" >nul
if not errorlevel 1 (
    echo ❌ 警告：检测到IDE配置文件，正在移除...
    git reset HEAD .vscode/
)

REM 检查日志文件是否被意外添加
git diff --cached --name-only | findstr ".log" >nul
if not errorlevel 1 (
    echo ❌ 警告：检测到日志文件，正在移除...
    git reset HEAD *.log
)

echo ✅ 安全检查完成

echo.
echo ========================================
echo 📝 第五步：建议的提交信息
echo ========================================
echo.
echo 选择一个合适的提交信息：
echo.
echo 1. feat: 初始化安全数据分析沙箱项目
echo    - 添加Docker容器化部署配置
echo    - 实现PII检测和安全命令安装功能  
echo    - 提供Web管理界面和演示脚本
echo    - 完善项目文档和使用指南
echo.
echo 2. docs: 更新项目文档和商务化界面设计
echo    - 翻译需求文档为中文版本
echo    - 优化Web界面为专业商务风格
echo    - 添加详细的演示指南和检查清单
echo.
echo 3. refactor: 重构安全机制和代码结构
echo    - 优化Docker安全配置
echo    - 完善权限控制和网络隔离
echo    - 改进PII检测算法
echo.

echo ========================================
echo 🎯 第六步：执行提交
echo ========================================
echo.
echo 请手动执行以下命令之一：
echo.
echo git commit -m "feat: 初始化安全数据分析沙箱项目"
echo git commit -m "docs: 更新项目文档和商务化界面设计"  
echo git commit -m "refactor: 重构安全机制和代码结构"
echo.
echo 然后推送到远程仓库：
echo git push
echo.

echo ========================================
echo 📋 提交后检查
echo ========================================
echo.
echo 提交后建议执行：
echo 1. git log --oneline -5    # 查看最近5次提交
echo 2. git remote -v           # 确认远程仓库地址
echo 3. git branch -a           # 查看所有分支
echo.

pause