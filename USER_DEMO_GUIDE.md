# 🚀 安全数据分析沙箱 - 用户演示指南

## 📋 概述

本指南将引导您在Windows环境下通过WSL完成安全数据分析沙箱的完整演示。演示将展示系统的核心安全特性和功能。

---

## 🔧 环境准备

### 前置要求

- ✅ Windows 10/11 with WSL2
- ✅ Docker Desktop for Windows
- ✅ Python 3.7+ (在WSL中)
- ✅ 现代浏览器 (Chrome/Firefox/Edge)

### 验证环境

在PowerShell中执行以下命令验证环境：

```powershell
# 验证WSL
wsl --version

# 验证Docker
wsl docker --version

# 验证Python
wsl python3 --version
```

---

## 📁 项目结构概览

```
sandbox/
├── deploy.sh                    # 沙箱部署脚本
├── docker-compose.yml          # Docker编排配置
├── Dockerfile                  # 容器构建文件
├── README.md                   # 项目说明
├── SECURITY_ANALYSIS.md        # 安全分析报告
├── data/                       # 数据目录
│   └── sample_data.txt         # 演示数据
├── command_inbox/              # 命令收件箱
│   └── hello_world.sh          # 演示脚本
├── web_interface/              # Web管理界面
│   ├── app.py                  # Flask应用
│   ├── templates/              # HTML模板
│   ├── requirements.txt        # Python依赖
│   └── venv/                   # 虚拟环境
└── scripts/                    # 核心脚本
    ├── fetch_data.sh           # 数据获取
    ├── install_command.sh      # 命令安装
    └── sensitive_data_scanner.py # PII扫描
```

---

## 🎯 演示步骤

### 第一步：部署安全沙箱

#### 1.1 导航到项目目录

```powershell
# 在PowerShell中执行
cd D:\playground\py\sandbox
```

#### 1.2 部署沙箱容器

```powershell
# 部署沙箱（首次部署会构建镜像，需要几分钟）
wsl ./deploy.sh
```

**预期输出**：
```
🚀 Starting deployment of container: secure-sandbox
[+] Building 45.2s (22/22) FINISHED
[+] Running 3/3
 ✔ Network sandbox_sandbox-net  Created
 ✔ Container secure-sandbox     Started
✅ Sandbox container 'secure-sandbox' deployed successfully.
📍 To access the sandbox, run: docker exec -it secure-sandbox /bin/sh
```

#### 1.3 验证容器状态

```powershell
# 检查容器是否正在运行
wsl bash -c "docker ps | grep secure-sandbox"
```

**预期输出**：
```
f488c2cda9f5   sandbox-sandbox   "tail -f /dev/null"   Up 2 minutes   secure-sandbox
```

---

### 第二步：核心安全功能演示

#### 2.1 进入沙箱环境

```powershell
# 进入安全沙箱
wsl docker exec -it secure-sandbox /bin/sh
```

**预期输出**：
```
$ whoami
appuser
$ pwd
/data
```

#### 2.2 验证网络隔离

在沙箱内执行：

```bash
# 尝试访问外部网络（应该失败）
ping google.com
curl baidu.com
nslookup qq.com
```

**预期结果**：
```
ping: bad address 'google.com'
/bin/sh: 1: curl: not found
/bin/sh: 1: nslookup: not found
```

✅ **安全验证**：网络完全隔离，无法访问外部网络

#### 2.3 验证权限控制

```bash
# 检查用户权限
whoami
id

# 尝试权限提升（应该失败）
sudo su
su root

# 尝试安装软件（应该失败）
apt install vim
```

**预期结果**：
```
appuser
uid=999(appuser) gid=999(appgroup) groups=999(appgroup)
/bin/sh: 1: sudo: not found
/bin/sh: 1: su: not found
/bin/sh: 1: apt: not found
```

✅ **安全验证**：权限严格受限，无法提升权限或安装软件

#### 2.4 验证系统工具移除

```bash
# 尝试使用被移除的工具（应该失败）
vi /etc/passwd
nano test.txt
gcc --version
make --version
```

**预期结果**：
```
/bin/sh: 1: vi: not found
/bin/sh: 1: nano: not found
/bin/sh: 1: gcc: not found
/bin/sh: 1: make: not found
```

✅ **安全验证**：危险工具已被移除，环境高度受控

---

### 第三步：PII检测功能演示

#### 3.1 查看演示数据

```bash
# 查看演示数据文件
cat /data/sample_data.txt
```

**预期输出**：
```
# sample_data.txt

这是一些测试记录。
张三的联系方式是 13812345678，他的邮箱是 zhangsan@example.com。
李四的身份证号码是 44010219900307887X，请保密。
王五的手机号是 15987654321，邮箱是 wangwu@test.cn。
无效的身份证号：123456789012345678
```

#### 3.2 执行PII扫描

```bash
# 扫描敏感数据
scan_data
```

**预期输出**：
```
🔍 开始扫描目录: /data
⚠️  发现敏感数据! 文件: /data/sample_data.txt, 行: 4, 类型: CHINESE_MOBILE, 内容: 13812345678
⚠️  发现敏感数据! 文件: /data/sample_data.txt, 行: 4, 类型: EMAIL, 内容: zhangsan@example.com
⚠️  发现敏感数据! 文件: /data/sample_data.txt, 行: 5, 类型: CHINESE_ID, 内容: 44010219900307887X
⚠️  发现敏感数据! 文件: /data/sample_data.txt, 行: 6, 类型: CHINESE_MOBILE, 内容: 15987654321
⚠️  发现敏感数据! 文件: /data/sample_data.txt, 行: 6, 类型: EMAIL, 内容: wangwu@test.cn
✅ 扫描完成。
```

✅ **功能验证**：PII检测功能正常，能准确识别敏感信息

---

### 第四步：安全命令安装演示

#### 4.1 查看待安装的演示脚本

```bash
# 查看收件箱中的脚本
ls -la /inbox/
cat /inbox/hello_world.sh
```

#### 4.2 尝试错误令牌安装

```bash
# 使用错误令牌尝试安装（应该失败）
install_command wrong-token hello_world.sh
```

**预期输出**：
```
❌ Error: Invalid authentication token. Permission denied.
```

✅ **安全验证**：认证机制有效，错误令牌被拒绝

#### 4.3 使用正确令牌安装

```bash
# 使用正确令牌安装脚本
install_command replace-with-your-actual-secure-token hello_world.sh
```

**预期输出**：
```
✅ Authentication successful.
📦 Installing command 'hello_world.sh'...
✅ Success: Command 'hello_world.sh' has been installed to /usr/local/bin/hello_world.sh and is now executable.
```

#### 4.4 测试新安装的命令

```bash
# 执行新安装的命令
hello_world.sh
```

**预期输出**：
```
你好，世界！这是一个通过安全方式安装的新命令。
```

✅ **功能验证**：安全命令安装机制正常工作

#### 4.5 验证反复安装能力

```bash
# 再次安装同一个脚本（演示反复安装能力）
install_command replace-with-your-actual-secure-token hello_world.sh
hello_world.sh
```

✅ **功能验证**：支持反复安装，便于演示和开发

---

### 第五步：数据获取功能演示

#### 5.1 尝试数据获取

```bash
# 尝试从远程获取数据（会失败，因为使用的是演示配置）
fetch_data
```

**预期输出**：
```
❌ Error: SSH private key not found at the specified path: /root/.ssh/id_rsa_remote
```

✅ **安全验证**：数据获取需要正确的SSH密钥配置

---

### 第六步：Web管理界面演示

#### 6.1 退出沙箱环境

```bash
# 退出沙箱容器
exit
```

#### 6.2 启动Web管理界面

```powershell
# 在PowerShell中启动Web应用
wsl bash -c "cd /mnt/d/playground/py/sandbox/web_interface && source venv/bin/activate && python app.py"
```

**预期输出**：
```
启动Docker沙箱Web管理界面...
访问地址: http://localhost:5000
 * Running on all addresses (0.0.0.0)
 * Running on http://127.0.0.1:5000
 * Running on http://172.x.x.x:5000
```

#### 6.3 访问Web界面

1. **打开浏览器**，访问 `http://localhost:5000`
2. **查看容器状态** - 应显示"运行中"
3. **点击"打开终端"** - 测试Web终端功能
4. **在Web终端中执行命令**：
   ```bash
   whoami
   scan_data
   hello_world.sh
   ```

✅ **功能验证**：Web管理界面正常工作

---

## 🔍 高级演示功能

### 自定义数据测试

#### 创建自定义测试数据

```powershell
# 在PowerShell中创建自定义测试文件
wsl bash -c "echo '客户信息：张三，电话：13800138000，邮箱：test@example.com，身份证：110101199001011234' > /mnt/d/playground/py/sandbox/data/custom_test.txt"
```

#### 扫描自定义数据

```powershell
# 进入沙箱并扫描
wsl docker exec -it secure-sandbox scan_data
```

### 批量文件测试

```powershell
# 创建多个测试文件
wsl bash -c "cd /mnt/d/playground/py/sandbox/data && echo '用户A：15912345678' > user_a.txt && echo '用户B：user@test.com' > user_b.txt"

# 扫描所有文件
wsl docker exec -it secure-sandbox scan_data
```

---

## 🛡️ 安全特性验证清单

### ✅ 网络安全验证
- [ ] 无法ping外部地址
- [ ] 无法使用curl/wget
- [ ] 无法进行DNS解析
- [ ] 无法建立外部连接

### ✅ 权限控制验证
- [ ] 以非root用户运行
- [ ] 无sudo权限
- [ ] 无法切换用户
- [ ] 系统目录只读

### ✅ 工具环境验证
- [ ] 无包管理器(apt)
- [ ] 无编辑器(vi/nano)
- [ ] 无编译器(gcc)
- [ ] 无网络工具(curl/wget)

### ✅ 功能特性验证
- [ ] PII检测正常
- [ ] 命令安装需要认证
- [ ] Web界面可访问
- [ ] 终端功能正常

---

## 🚨 故障排除

### 常见问题及解决方案

#### 1. 容器启动失败
```powershell
# 检查Docker服务
wsl docker info

# 重新部署
wsl docker-compose down
wsl ./deploy.sh
```

#### 2. Web界面无法访问
```powershell
# 检查端口占用
wsl bash -c "ss -tlnp | grep :5000"

# 重启Web应用
# Ctrl+C 停止，然后重新启动
wsl bash -c "cd /mnt/d/playground/py/sandbox/web_interface && source venv/bin/activate && python app.py"
```

#### 3. 权限问题
```powershell
# 确保脚本有执行权限
wsl chmod +x deploy.sh
wsl chmod +x web_interface/start_web.sh
```

#### 4. Python依赖问题
```powershell
# 重新安装依赖
wsl bash -c "cd /mnt/d/playground/py/sandbox/web_interface && source venv/bin/activate && pip install -r requirements.txt"
```

---

## 📊 演示效果评估

### 成功标准

1. **✅ 安全隔离**: 所有网络访问尝试失败
2. **✅ 权限控制**: 无法提升权限或安装软件
3. **✅ PII检测**: 准确识别敏感信息
4. **✅ 认证机制**: 错误令牌被拒绝，正确令牌通过
5. **✅ Web管理**: 界面正常访问和操作

### 演示时长

- **完整演示**: 约20-30分钟
- **核心功能**: 约10-15分钟
- **安全验证**: 约5-10分钟

---

## 🎯 演示脚本模板

### 开场介绍 (2分钟)
"今天我将演示一个高度安全的数据分析沙箱系统。该系统通过多层隔离技术，确保敏感数据在分析过程中不会泄露。"

### 安全特性展示 (10分钟)
1. "首先，我们验证网络完全隔离..."
2. "接下来，检查权限控制机制..."
3. "然后，确认危险工具已被移除..."

### 功能演示 (10分钟)
1. "现在演示PII自动检测功能..."
2. "展示安全的命令安装机制..."
3. "最后，体验Web管理界面..."

### 总结 (3分钟)
"通过以上演示，我们可以看到该沙箱系统提供了企业级的安全保护，适用于处理最敏感的数据分析任务。"

---

## 📋 演示检查清单

### 演示前准备
- [ ] 确认WSL和Docker正常运行
- [ ] 验证项目文件完整
- [ ] 测试网络连接
- [ ] 准备演示数据

### 演示过程
- [ ] 成功部署沙箱
- [ ] 验证安全特性
- [ ] 展示核心功能
- [ ] 演示Web界面

### 演示后清理
- [ ] 停止Web应用
- [ ] 清理测试数据
- [ ] 停止容器（可选）

---

**文档版本**: v1.0  
**适用环境**: Windows + WSL2 + Docker Desktop  
**最后更新**: 2025年8月7日