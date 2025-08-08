# 安全数据分析沙箱 - Web管理界面

这是一个基于Web的Docker容器管理界面，允许用户通过浏览器操作安全数据分析沙箱。

## 🌟 功能特性

- **📊 容器状态监控**: 实时显示Docker容器的运行状态
- **🎛️ 容器控制**: 部署、启动、停止容器操作
- **💻 Web终端**: 直接在浏览器中访问容器终端
- **🔒 安全管理**: 安全的容器操作和权限控制
- **📱 响应式设计**: 支持桌面和移动设备访问

## 🚀 快速开始

### 前置要求

- Python 3.7+
- Docker
- 现代浏览器（Chrome、Firefox、Safari、Edge）

### 安装和启动

#### Windows用户

1. 双击运行 `start_web.bat`
2. 等待依赖安装完成
3. 浏览器访问 `http://localhost:5000`

#### Linux/macOS用户

```bash
# 进入web_interface目录
cd web_interface

# 运行启动脚本
./start_web.sh
```

或者手动启动：

```bash
# 创建虚拟环境
python3 -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# 安装依赖
pip install -r requirements.txt

# 启动应用
python app.py
```

## 🎯 使用指南

### 1. 访问Web界面

启动后在浏览器中访问：`http://localhost:5000`

### 2. 容器管理操作

- **部署沙箱**: 首次使用时点击"部署沙箱"按钮创建容器
- **启动容器**: 启动已停止的容器
- **停止容器**: 停止正在运行的容器
- **打开终端**: 在Web界面中打开容器终端

### 3. 终端操作

在Web终端中可以执行以下命令：

```bash
# 扫描敏感数据
scan_data

# 获取远程数据（需要配置SSH密钥）
fetch_data

# 安装新命令（需要认证令牌）
install_command <token> <script_name>

# 查看当前用户和目录
whoami
pwd
ls -la
```

### 4. 状态监控

- **绿色指示器**: 容器正在运行
- **红色指示器**: 容器已停止
- **黄色指示器**: 状态未知或错误

## 🔧 技术架构

### 后端技术栈

- **Flask**: Web框架
- **Flask-SocketIO**: WebSocket支持
- **Docker Python SDK**: Docker容器管理
- **PTY**: 伪终端支持

### 前端技术栈

- **HTML5/CSS3**: 现代Web标准
- **JavaScript ES6+**: 客户端逻辑
- **Socket.IO**: 实时通信
- **Xterm.js**: Web终端模拟器

### 安全特性

- **网络隔离**: 容器网络完全隔离
- **权限控制**: 非root用户执行
- **认证机制**: 命令安装需要令牌认证
- **会话管理**: 安全的WebSocket会话

## 📁 文件结构

```
web_interface/
├── app.py              # Flask应用主文件
├── templates/
│   └── index.html      # Web界面模板
├── requirements.txt    # Python依赖
├── start_web.sh       # Linux/macOS启动脚本
├── start_web.bat      # Windows启动脚本
└── README.md          # 说明文档
```

## 🐛 故障排除

### 常见问题

1. **端口占用错误**
   - 检查5000端口是否被占用
   - 修改app.py中的端口号

2. **Docker连接失败**
   - 确保Docker服务正在运行
   - 检查Docker权限设置

3. **终端连接失败**
   - 确保容器正在运行
   - 检查容器名称是否正确

4. **依赖安装失败**
   - 更新pip: `pip install --upgrade pip`
   - 使用国内镜像: `pip install -i https://pypi.tuna.tsinghua.edu.cn/simple -r requirements.txt`

### 日志查看

应用运行时会在控制台输出详细日志，包括：
- WebSocket连接状态
- Docker操作结果
- 终端会话信息

## 🔒 安全注意事项

1. **网络访问**: 默认绑定到所有网络接口，生产环境建议限制访问
2. **认证机制**: 当前版本未包含用户认证，建议在受信任环境中使用
3. **HTTPS**: 生产环境建议启用HTTPS加密
4. **防火墙**: 适当配置防火墙规则限制访问

## 📞 支持和反馈

如果遇到问题或有改进建议，请：
1. 检查日志输出
2. 查看故障排除部分
3. 提交问题报告

---

**注意**: 这是一个用于演示和开发的Web管理界面，在生产环境中使用前请进行适当的安全加固。