# ✅ 安全数据分析沙箱 - 演示检查清单

## 🚀 快速演示指南

### 演示前准备 (5分钟)

```powershell
# 1. 导航到项目目录
cd D:\playground\py\sandbox

# 2. 验证环境
wsl --version                    # 确认WSL可用
wsl docker --version            # 确认Docker可用
wsl python3 --version           # 确认Python可用

# 3. 快速演示（可选）
.\quick_demo.bat                 # 运行自动化演示脚本
```

---

## 📋 手动演示步骤

### 第一步：部署沙箱 (3分钟)

```powershell
# 部署命令
wsl ./deploy.sh

# 验证部署
wsl bash -c "docker ps | grep secure-sandbox"
```

**✅ 成功标志**: 看到容器状态为 "Up X minutes"

---

### 第二步：安全特性验证 (8分钟)

```powershell
# 进入沙箱
wsl docker exec -it secure-sandbox /bin/sh
```

在沙箱内依次执行：

```bash
# 2.1 验证用户权限
whoami                          # 应显示: appuser
id                              # 应显示: uid=999(appuser)

# 2.2 验证网络隔离 ❌ 这些都应该失败
ping google.com                 # ❌ 应失败
curl baidu.com                  # ❌ 应失败  
nslookup qq.com                 # ❌ 应失败

# 2.3 验证权限控制 ❌ 这些都应该失败
sudo su                         # ❌ 应失败
su root                         # ❌ 应失败
apt install vim                 # ❌ 应失败

# 2.4 验证工具移除 ❌ 这些都应该失败
vi /etc/passwd                  # ❌ 应失败
nano test.txt                   # ❌ 应失败
gcc --version                   # ❌ 应失败
```

**✅ 安全验证通过**: 所有危险操作都被阻止

---

### 第三步：功能演示 (7分钟)

```bash
# 3.1 PII检测功能 ✅ 应该成功
scan_data                       # ✅ 应检测到敏感信息

# 3.2 命令安装 - 错误令牌 ❌ 应该失败
install_command wrong-token hello_world.sh    # ❌ 认证失败

# 3.3 命令安装 - 正确令牌 ✅ 应该成功
install_command replace-with-your-actual-secure-token hello_world.sh    # ✅ 安装成功

# 3.4 测试新命令 ✅ 应该成功
hello_world.sh                  # ✅ 显示中文消息

# 3.5 退出沙箱
exit
```

**✅ 功能验证通过**: PII检测和安全安装都正常工作

---

### 第四步：Web界面演示 (5分钟)

```powershell
# 启动Web应用
wsl bash -c "cd /mnt/d/playground/py/sandbox/web_interface && source venv/bin/activate && python app.py"
```

**浏览器操作**:
1. 访问 `http://localhost:5000`
2. 查看容器状态（应显示"运行中"）
3. 点击"打开终端"
4. 在Web终端中执行：
   ```bash
   whoami
   scan_data
   hello_world.sh
   ```

**✅ Web界面验证通过**: 界面正常，终端功能正常

---

## 🎯 演示要点总结

### 🔒 安全特性展示
- ✅ **网络完全隔离** - 无法访问外部网络
- ✅ **权限严格控制** - 非root用户，无sudo权限
- ✅ **工具环境锁定** - 危险工具已移除
- ✅ **认证机制有效** - 错误令牌被拒绝

### 🛠️ 功能特性展示
- ✅ **PII自动检测** - 准确识别敏感信息
- ✅ **安全命令安装** - 需要正确认证令牌
- ✅ **Web管理界面** - 远程安全管理
- ✅ **反复演示能力** - 支持多次安装演示

---

## 📊 演示效果评估

### 成功指标
- [ ] 所有网络访问尝试失败 ❌
- [ ] 所有权限提升尝试失败 ❌  
- [ ] PII检测准确识别敏感信息 ✅
- [ ] 错误令牌被正确拒绝 ❌
- [ ] 正确令牌安装成功 ✅
- [ ] Web界面正常访问 ✅

### 时间分配
- **环境准备**: 5分钟
- **安全验证**: 8分钟
- **功能演示**: 7分钟
- **Web界面**: 5分钟
- **总计**: 25分钟

---

## 🚨 常见问题快速解决

### 问题1: 容器启动失败
```powershell
# 解决方案
wsl docker info                 # 检查Docker状态
wsl docker-compose down         # 清理环境
wsl ./deploy.sh                 # 重新部署
```

### 问题2: Web界面无法访问
```powershell
# 解决方案
wsl bash -c "pkill -f python"   # 停止旧进程
# 重新启动Web应用
wsl bash -c "cd /mnt/d/playground/py/sandbox/web_interface && source venv/bin/activate && python app.py"
```

### 问题3: 权限错误
```powershell
# 解决方案
wsl chmod +x deploy.sh          # 确保脚本可执行
wsl chmod +x web_interface/start_web.sh
```

---

## 🎤 演示话术模板

### 开场 (1分钟)
> "今天我将演示一个企业级的安全数据分析沙箱。这个系统通过多层技术手段，确保敏感数据在分析过程中绝对不会泄露。"

### 安全演示 (8分钟)
> "首先，我们验证系统的核心安全特性。您可以看到，容器完全无法访问外部网络..."
> "接下来，我们测试权限控制。即使在容器内部，用户也无法获得管理员权限..."
> "最后，我们确认所有危险工具都已被移除，用户无法安装新软件或编辑系统文件..."

### 功能演示 (7分钟)
> "现在演示系统的核心功能。首先是PII自动检测，可以准确识别中国手机号、身份证号等敏感信息..."
> "然后是安全的命令安装机制，只有提供正确的认证令牌才能安装新工具..."

### 总结 (2分钟)
> "通过刚才的演示，我们可以看到这个沙箱系统提供了银行级的安全保护，完全适用于处理最敏感的数据分析任务。"

---

**演示成功标准**: 所有安全验证失败 ❌，所有功能验证成功 ✅