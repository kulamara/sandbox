# 安全数据分析沙箱

本项目提供一个高度安全、隔离的数据分析沙箱环境。它旨在防止数据泄露，同时为数据分析师提供一套受控的、不可变的核心工具集。

---

## 核心设计原则

- **严格的数据隔离**: 数据一旦进入沙箱，将通过技术手段（隔离的Docker网络）被阻止离开容器。
- **不可变与受控的环境**: 沙箱内的用户无法安装新软件、编辑系统文件或创建可执行脚本。环境是预先定义和锁定的。
- **安全的可扩展性**: 新的分析工具（脚本）只能通过一个专用的、经过身份验证的脚本进行添加。

---

## 架构概述

本沙箱系统基于 Docker 和 Docker Compose 构建，其核心组件包括：

- **部署脚本 (`deploy.sh`)**: 用于自动化构建和启动整个环境。
- **Docker Compose 配置 (`docker-compose.yml`)**: 定义了沙箱服务、隔离网络和数据卷。网络被设置为 `internal: true`，以彻底阻断所有外部网络连接。
- **硬化的 Dockerfile**: 采用多阶段构建（Multi-Stage Build）策略。
    - **`builder` 阶段**: 安装所有构建工具和依赖。
    - **`final` 阶段**: 基于一个极简的 `debian:stable-slim` 镜像，仅复制必要的二进制文件（如 `scp`）、Python 虚拟环境和自定义脚本。最终镜像不包含包管理器 (`apt`)、编辑器 (`vi`) 或编译器 (`gcc`)。
- **非 Root 用户**: 在容器内部，所有操作都由一个低权限的 `appuser` 用户执行。

---

## 管理员指南

### 1. 部署沙箱

部署过程非常简单。只需运行 `deploy.sh` 脚本。

```bash
# 赋予脚本执行权限
chmod +x deploy.sh

# 运行部署脚本（使用默认容器名 "secure-sandbox"）
./deploy.sh

# 或者指定一个自定义容器名
./deploy.sh my-analysis-container
```

脚本会自动构建镜像并以分离模式（detached mode）启动容器。

### 2. 环境配置

所有重要的配置都在 `docker-compose.yml` 文件中通过环境变量进行管理。

- `INSTALL_TOKEN`: 用于 `install_command` 脚本的身份验证令牌。**请务必在生产环境中修改此值**。
- `REMOTE_USER`, `REMOTE_HOST`, `REMOTE_DATA_PATH`: `fetch_data` 脚本用于 `scp` 连接的远程服务器信息。
- `REMOTE_KEY_PATH`: `scp` 连接所使用的 SSH 私钥在**容器内部**的路径。

**重要**: 要使 `fetch_data` 脚本正常工作，您需要将一个有效的 SSH 私钥挂载到容器中。例如，修改 `docker-compose.yml` 的 `volumes` 部分：

```yaml
services:
  sandbox:
    volumes:
      - ./data:/data
      - ./command_inbox:/inbox
      # 示例：将主机的私钥挂载到容器中指定的位置
      - ~/.ssh/remote_server_key:${REMOTE_KEY_PATH}
```

### 3. 添加新的分析命令

系统允许安全地添加新的命令（脚本）。

1.  **准备脚本**: 将您想要添加的新脚本（例如 `my_new_tool.py`）放入项目根目录下的 `command_inbox` 文件夹中。
2.  **进入容器**: 使用 `docker exec` 命令进入正在运行的沙箱容器。
    ```bash
    docker exec -it secure-sandbox /bin/sh
    ```
3.  **运行安装脚本**: 在容器内部，使用 `install_command` 并提供正确的令牌来安装新命令。
    ```sh
    # 格式: install_command <令牌> <脚本文件名>
    install_command replace-with-your-actual-secure-token my_new_tool.py
    ```
    该命令会将脚本从 `/inbox` 移动到 `/usr/local/bin` 并赋予其执行权限，使其成为一个系统范围的命令。

---

## 分析师指南

### 1. 访问沙箱

您可以通过 `docker exec` 命令进入沙箱环境。这是一个受限的 `sh` shell。

```bash
docker exec -it secure-sandbox /bin/sh
```

### 2. 可用命令

您的环境是锁定的，但包含以下预装的核心工具：

- **`fetch_data`**:
  从远程服务器拉取数据到 `/data` 目录。该命令无需任何参数，所有配置均由管理员预设。
  ```sh
  # 只需运行命令即可
  fetch_data
  ```

- **`scan_data`**:
  扫描 `/data` 目录中的所有文件，以查找潜在的个人身份信息（PII），包括中国手机号、身份证号和电子邮件。
  ```sh
  # 扫描默认的 /data 目录
  scan_data

  # 也可以指定 /data 的子目录进行扫描
  scan_data /data/project_files
  ```

### 3. 环境限制

请注意，这是一个高度受限的环境：

- **无网络访问**: 您无法 `ping` 任何外部地址或从互联网下载任何内容。
- **无包管理器**: `apt`, `pip`, `npm` 等工具均不可用。
- **无开发工具**: `vi`, `nano`, `gcc`, `make` 等编辑器和编译器均已被移除。
- **文件系统**: 您只能在 `/data` 目录中写入文件。其他系统路径是只读的。
