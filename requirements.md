

### The Comprehensive & Secure Sandbox Prompt

You are an expert in Secure DevOps (DevSecOps) and system architecture. Your task is to design and generate the complete file set for a secure, isolated data analysis sandbox using Docker.

This sandbox is designed for analysts who need to process sensitive data without any possibility of data exfiltration. The environment must be strictly controlled, locked down, and extensible only through secure, authenticated means.

**Core Design Principles:**

1.  **Strict Data Isolation:** Data, once pulled into the sandbox, must be technically prevented from leaving the container via network channels.
2.  **Immutable & Controlled Environment:** The user inside the sandbox should not be able to install new software, edit system files, or create executable scripts. The environment is pre-defined and locked.
3.  **Secure Extensibility:** New analysis tools (scripts) can be added to the sandbox, but only through a dedicated, authenticated script.

**Detailed Component Requirements:**

Based on these principles, please generate the complete source for the following components:

**1. Automated Deployment Script (`deploy.sh`)**

  * This should be a bash script that acts as the main entry point for the administrator.
  * It should accept parameters to configure the sandbox, such as a container name.
  * It will be responsible for building and launching the Docker environment using `docker-compose`.

**2. Docker Compose Configuration (`docker-compose.yml`)**

  * Define the main sandbox service.
  * **Network Isolation (Requirement 3):** Create a custom Docker network with the `internal: true` flag to block all outbound and inbound traffic from the external world. The container should not be able to `ping google.com`.
  * Define the necessary volumes:
      * `./data:/data`: For storing and analyzing the sensitive data.
      * `./command_inbox:/inbox`: A specific, temporary location for receiving new scripts from the outside.

**3. Hardened Dockerfile (`Dockerfile`)**

  * **Multi-Stage Build (Requirement 6):** Use a multi-stage build process to ensure the final image is minimal and secure.
      * **`builder` stage:** Start with a full OS (like `debian`). Install all necessary build tools, development libraries, Python dependencies (`pip install`), and download any required clients (like `openssh-client` for `scp`).
      * **`final` stage:** Start from a minimal base image (e.g., `debian:stable-slim`).
          * Create a non-root user (e.g., `appuser`) and switch to this user.
          * Copy *only* the necessary, pre-compiled binaries and scripts from the `builder` stage into the final image (e.g., copy the Python virtual environment, `scp` binary, and our custom scripts).
          * **Crucially, DO NOT install package managers (`apt`), shells (`bash` can be replaced with `sh` if needed), editors (`vi`, `nano`), or compilers (`gcc`) in the final stage.**

**4. Core Internal Scripts**

```
a. **Data Fetching Script (`fetch_data.sh`) (Requirement 2)**
* A shell script located at `/usr/local/bin/fetch_data`.
* It should use `scp` or `rsync` to pull data from a remote server into the `/data` directory.
* Connection details (user, host, key path) must be provided via environment variables, not hardcoded in the script.

b. **Sensitive Data Scanner (`sensitive_data_scanner.py`) (Requirement 4)**
* A Python script located at `/usr/local/bin/scan_data`.
* It should scan the `/data` directory for PII (Chinese mobile phones, Chinese National IDs, emails).
* **Requirement:** The script's code comments must be in **Chinese**.

c. **Authenticated Command Installer (`install_command.sh`) (Requirement 5)**
* A shell script located at `/usr/local/bin/install_command`.
* **Functionality:** It takes a script file from the `/inbox` volume, makes it executable, and moves it to `/usr/local/bin` to make it a system-wide command for the sandbox user.
* **Authentication:** The script must require an authentication token as its first argument. It should compare this token against a secret value stored in an environment variable (e.g., `INSTALL_TOKEN`). If the token is invalid, it must exit with an error.
```

**5. Documentation (`README.md`)**

  * Provide a clear and concise README file explaining the architecture and usage for both the administrator (how to deploy and add new commands) and the analyst (what commands are available).
  * **Requirement:** This entire `README.md` file must be written in **Chinese**.

**Final Output:**

Please provide the complete, fully commented content for all the following files, structured clearly:

  * `deploy.sh`
  * `docker-compose.yml`
  * `Dockerfile`
  * `fetch_data.sh`
  * `sensitive_data_scanner.py`
  * `install_command.sh`
  * `README.md`