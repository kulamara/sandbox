# Dockerfile: A multi-stage build to create a secure and minimal sandbox image.

# ==============================================================================
# Stage 1: The 'builder' stage
#
# This stage installs all build-time dependencies, development tools, and
# Python packages. The final image will only copy the necessary artifacts
# from this stage, leaving behind all the bulky build tools.
# ==============================================================================
FROM debian:stable AS builder

# Prevent debconf from asking interactive questions
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies: Python, venv for isolation, and openssh-client for scp.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    python3-venv \
    openssh-client && \
    rm -rf /var/lib/apt/lists/*

# Create a Python virtual environment to keep dependencies isolated.
RUN python3 -m venv /opt/venv

# Activate the virtual environment and install Python packages.
# The 'regex' library is used for the PII scanner.
ENV PATH="/opt/venv/bin:$PATH"
RUN pip install --no-cache-dir regex

# ==============================================================================
# Stage 2: The 'final' stage
#
# This is the production image. It starts from a minimal base, creates a
# non-root user, and copies only the essential application code and binaries
# from the 'builder' stage. It does NOT include package managers (apt),
# compilers (gcc), or unnecessary shells.
# ==============================================================================
FROM debian:stable-slim

# Create a non-root user and group for security.
RUN groupadd -r appgroup && \
    useradd -r -s /bin/sh -g appgroup appuser

# Copy the Python virtual environment from the builder stage.
COPY --from=builder /opt/venv /opt/venv

# Copy the 'scp' binary from the builder stage.
# Its dependencies are expected to exist in the debian:stable-slim base.
COPY --from=builder /usr/bin/scp /usr/bin/scp

# Copy the custom scripts into the final image.
# These files must be in the same directory as the Dockerfile.
COPY fetch_data.sh /usr/local/bin/fetch_data
COPY install_command.sh /usr/local/bin/install_command
COPY sensitive_data_scanner.py /usr/local/bin/scan_data

# Make the scripts executable system-wide.
RUN chmod +x /usr/local/bin/fetch_data && \
    chmod +x /usr/local/bin/install_command && \
    chmod +x /usr/local/bin/scan_data

# Create the /data and /inbox directories and set ownership.
# The user 'appuser' needs to be able to write to the /data directory.
RUN mkdir -p /data /inbox && \
    chown -R appuser:appgroup /data && \
    chown -R appuser:appgroup /inbox

# Set the PATH to include the Python virtual environment.
ENV PATH="/opt/venv/bin:$PATH"

# Switch to the non-root user.
USER appuser

# Set the working directory for the user.
WORKDIR /data

# Use tail -f /dev/null to keep the container running indefinitely.
# This allows the administrator to exec into it for management, and for
# the analyst to use it as a persistent sandbox. The default sh command
# would otherwise exit immediately as it has no input.
CMD ["tail", "-f", "/dev/null"]
