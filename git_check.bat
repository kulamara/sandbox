@echo off
chcp 65001 >nul
echo.
echo ========================================
echo 🔍 Git 提交前检查脚本
echo ========================================
echo.

echo 📋 检查当前Git状态...
git status

echo.
echo ========================================
echo 📁 将要提交的文件列表：
echo ========================================
git diff --cached --name-only
git ls-files --others --exclude-standard

echo.
echo ========================================
echo ⚠️  请确认以下文件不会被提交：
echo ========================================
echo ❌ web_interface/venv/ (虚拟环境)
echo ❌ .vscode/ (IDE配置)
echo ❌ *.log (日志文件)
echo ❌ .env (环境变量文件)
echo ❌ dummy_key/ (SSH密钥)
echo ❌ __pycache__/ (Python缓存)

echo.
echo ========================================
echo 🔧 常用Git命令：
echo ========================================
echo git add .                    # 添加所有文件
echo git add -A                   # 添加所有变更
echo git commit -m "提交信息"      # 提交变更
echo git push                     # 推送到远程仓库
echo git rm --cached 文件名       # 从暂存区移除文件
echo git reset HEAD 文件名        # 取消暂存文件

echo.
echo ========================================
echo 📝 建议的提交信息模板：
echo ========================================
echo "feat: 添加安全数据分析沙箱核心功能"
echo "docs: 更新项目文档和使用指南"
echo "style: 优化Web界面商务化设计"
echo "fix: 修复容器部署和终端连接问题"
echo "refactor: 重构代码结构和安全机制"

echo.
pause