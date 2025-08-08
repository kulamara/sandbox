# 📁 项目文件清单

## ✅ 应该提交的文件

### 📋 核心配置文件
- `README.md` - 项目主要说明文档
- `requirements.md` - 英文需求文档
- `requirements-cn.md` - 中文需求文档
- `docker-compose.yml` - Docker编排配置
- `Dockerfile` - 容器构建文件
- `deploy.sh` - 部署脚本
- `.gitignore` - Git忽略文件配置

### 🛠️ 核心脚本文件
- `fetch_data.sh` - 数据获取脚本
- `install_command.sh` - 命令安装脚本
- `sensitive_data_scanner.py` - PII检测脚本

### 🌐 Web管理界面
- `web_interface/app.py` - Flask Web应用
- `web_interface/templates/index.html` - Web界面模板
- `web_interface/requirements.txt` - Python依赖列表
- `web_interface/start_web.sh` - Linux启动脚本
- `web_interface/start_web.bat` - Windows启动脚本
- `web_interface/test_terminal.html` - 终端测试页面
- `web_interface/README.md` - Web界面说明

### 📚 文档文件
- `SECURITY_ANALYSIS.md` - 详细安全分析报告
- `SECURITY_FEATURES.md` - 安全特性概览
- `USER_DEMO_GUIDE.md` - 用户演示指南
- `DEMO_CHECKLIST.md` - 演示检查清单
- `PROJECT_OVERVIEW.md` - 项目总览
- `DEMO_INSTRUCTIONS.md` - 演示说明
- `PROJECT_FILES.md` - 本文件清单

### 🚀 便捷脚本
- `quick_demo.bat` - 快速演示脚本
- `start_web_windows.bat` - Windows Web启动脚本
- `git_check.bat` - Git检查脚本

### 📊 演示数据
- `data/sample_data.txt` - 演示数据文件
- `command_inbox/hello_world.sh` - 演示安装脚本
- `command_inbox/demo_script.sh` - 演示脚本

---

## ❌ 不应该提交的文件

### 🐍 Python相关
- `__pycache__/` - Python缓存目录
- `*.pyc` - Python编译文件
- `web_interface/venv/` - **虚拟环境目录**
- `.pytest_cache/` - 测试缓存

### 🔧 IDE和编辑器
- `.vscode/` - **VS Code配置目录**
- `.idea/` - IntelliJ IDEA配置
- `*.swp`, `*.swo` - Vim临时文件
- `*.sublime-*` - Sublime Text配置

### 🖥️ 操作系统
- `.DS_Store` - macOS系统文件
- `Thumbs.db` - Windows缩略图缓存
- `Desktop.ini` - Windows文件夹配置

### 🔐 安全相关
- `dummy_key/` - **SSH密钥目录**
- `*.pem`, `*.key` - 私钥文件
- `.env` - 环境变量文件
- `secrets.*` - 密钥配置文件

### 📝 日志和临时文件
- `*.log` - 日志文件
- `*.tmp`, `*.temp` - 临时文件
- `*.bak`, `*.backup` - 备份文件

### 🗄️ 数据库和缓存
- `*.db`, `*.sqlite` - 数据库文件
- `.cache/` - 缓存目录

---

## 🔍 检查命令

### 查看当前状态
```bash
git status
```

### 查看将要提交的文件
```bash
git diff --cached --name-only
```

### 查看未跟踪的文件
```bash
git ls-files --others --exclude-standard
```

### 从暂存区移除文件
```bash
git rm --cached 文件名
```

### 检查.gitignore是否生效
```bash
git check-ignore -v 文件名
```

---

## 📋 提交建议

### 首次提交
```bash
# 添加所有应该提交的文件
git add .

# 检查状态
git status

# 提交
git commit -m "feat: 初始化安全数据分析沙箱项目

- 添加Docker容器化部署配置
- 实现PII检测和安全命令安装功能
- 提供Web管理界面和演示脚本
- 完善项目文档和使用指南"

# 推送到远程仓库
git push
```

### 后续提交
```bash
# 添加变更
git add .

# 提交变更
git commit -m "docs: 更新项目文档和商务化界面设计"

# 推送
git push
```

---

## ⚠️ 重要提醒

1. **虚拟环境**: `web_interface/venv/` 目录绝对不要提交
2. **IDE配置**: `.vscode/` 等IDE配置目录不要提交
3. **敏感信息**: 任何包含密钥、密码的文件都不要提交
4. **日志文件**: 运行时生成的日志文件不要提交
5. **临时文件**: 各种临时和缓存文件不要提交

使用 `git_check.bat` 脚本可以帮助你在提交前进行检查！