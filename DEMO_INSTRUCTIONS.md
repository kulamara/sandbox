# 安全沙箱功能分步演示指南

本指南将引导您完成对安全沙箱各项核心功能的验证。我们将创建演示数据和脚本来模拟真实使用场景。

---

### 准备工作：创建演示文件和目录

在运行部署脚本之前，请先在您的项目根目录下创建以下文件和目录：

1.  **创建数据目录和演示数据文件**:
    *   创建一个名为 `data` 的目录。
    *   在 `data` 目录中，创建一个名为 `sample_data.txt` 的文件，并填入以下内容。这个文件包含了用于测试的敏感数据。

    ```
    # sample_data.txt

    这是一些测试记录。
    张三的联系方式是 13812345678，他的邮箱是 zhangsan@example.com。
    李四的身份证号码是 44010219900307887X，请保密。
    王五的手机号是 15987654321，邮箱是 wangwu@test.cn。
    无效的身份证号：123456789012345678
    ```

2.  **创建指令收件箱和演示脚本**:
    *   创建一个名为 `command_inbox` 的目录。
    *   在 `command_inbox` 目录中，创建一个名为 `hello_world.sh` 的文件，并填入以下内容。这个脚本将用于测试安全的命令安装功能。

    ```bash
    #!/bin/sh
    # hello_world.sh
    echo "你好，世界！这是一个通过安全方式安装的新命令。"
    ```

3.  **（可选）为 `fetch_data` 创建模拟的远程密钥**:
    *   `fetch_data` 脚本需要一个SSH私钥。为了完成演示，您可以创建一个假的密钥文件。
    *   在您的项目根目录（或您喜欢的位置）创建一个文件，例如 `dummy_key`。
        ```bash
        touch dummy_key
        chmod 600 dummy_key
        ```
    *   然后，修改 `docker-compose.yml` 文件，将此密钥挂载到容器中。找到 `volumes` 部分并添加一行：
        ```yaml
        volumes:
          - ./data:/data
          - ./command_inbox:/inbox
          # 添加下面这行来挂载你的密钥
          - ./dummy_key:/root/.ssh/id_rsa_remote
        ```

完成以上步骤后，您的项目目录结构应如下所示：

```
.
├── command_inbox/
│   └── hello_world.sh
├── data/
│   └── sample_data.txt
├── deploy.sh
├── docker-compose.yml
├── Dockerfile
├── README.md
├── dummy_key
└── ... (其他脚本)
```

---

### 演示步骤

#### 1. 部署沙箱

首先，按照 `README.md` 中的说明部署沙箱。

```bash
# 确保 deploy.sh 有执行权限
chmod +x deploy.sh
# 部署
./deploy.sh
```

#### 2. 验证 PII 扫描功能 (`scan_data`)

1.  进入容器：
    ```bash
    docker exec -it secure-sandbox /bin/sh
    ```

2.  在容器内，运行 `scan_data` 命令：
    ```sh
    # /data 目录是我们通过 volume 挂载的
    scan_data
    ```

3.  **预期输出**:
    您应该能看到脚本找到了 `sample_data.txt` 文件中的所有敏感信息，并逐行打印出来。
    ```
    ⚠️  发现敏感数据! 文件: /data/sample_data.txt, 行: 4, 类型: CHINESE_MOBILE, 内容: 13812345678
    ⚠️  发现敏感数据! 文件: /data/sample_data.txt, 行: 4, 类型: EMAIL, 内容: zhangsan@example.com
    ⚠️  发现敏感数据! 文件: /data/sample_data.txt, 行: 5, 类型: CHINESE_ID, 内容: 44010219900307887X
    ⚠️  发现敏感数据! 文件: /data/sample_data.txt, 行: 6, 类型: CHINESE_MOBILE, 内容: 15987654321
    ⚠️  发现敏感数据! 文件: /data/sample_data.txt, 行: 6, 类型: EMAIL, 内容: wangwu@test.cn
    ```

#### 3. 验证安全命令安装 (`install_command`)

1.  确保您仍在容器内。运行 `install_command`，使用 `docker-compose.yml` 中配置的令牌 `replace-with-your-actual-secure-token`。

    ```sh
    # 首先，尝试使用一个错误的令牌
    install_command wrong-token hello_world.sh
    # 预期输出：错误信息，权限被拒绝

    # 现在，使用正确的令牌
    install_command replace-with-your-actual-secure-token hello_world.sh
    ```

2.  **预期输出**:
    脚本会提示您认证成功，并已成功安装 `hello_world.sh`。

3.  **验证新命令**:
    现在，您可以直接运行新安装的命令：
    ```sh
    hello_world.sh
    ```
    **预期输出**: `你好，世界！这是一个通过安全方式安装的新命令。`

#### 4. 验证网络隔离

1.  仍在容器内，尝试 `ping` 一个外部地址。
    ```sh
    ping google.com
    ```

2.  **预期输出**:
    命令会失败，通常会显示 `ping: bad address 'google.com'` 或类似的错误，因为容器无法访问外部DNS或网络。这证明了网络隔离是有效的。

#### 5. 验证 `fetch_data` (模拟)

由于我们没有真实的远程服务器，`fetch_data` 命令会失败，但我们可以验证它是否正确地读取了环境变量并尝试连接。

1.  仍在容器内，运行 `fetch_data`：
    ```sh
    fetch_data
    ```

2.  **预期输出**:
    脚本会打印出它正在尝试连接的服务器信息，然后 `scp` 命令会因为无法连接到 `dataserver.example.com` 而失败。这证明了脚本正在按预期工作。

---

完成以上所有步骤后，您就成功验证了沙箱的所有核心安全特性和功能。
