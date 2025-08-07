#!/bin/sh

# fetch_data.sh: Securely pulls data from a remote server into the /data directory.
# This script is designed to be run inside the secure sandbox container.
# All connection parameters are configured via environment variables.

# --- Configuration Validation ---
# Check that all required environment variables are set.
if [ -z "$REMOTE_USER" ] || [ -z "$REMOTE_HOST" ] || [ -z "$REMOTE_DATA_PATH" ] || [ -z "$REMOTE_KEY_PATH" ]; then
  echo "❌ Error: Missing one or more required environment variables." >&2
  echo "   Please ensure the following are set: REMOTE_USER, REMOTE_HOST, REMOTE_DATA_PATH, REMOTE_KEY_PATH" >&2
  exit 1
fi

# Check if the specified private key file actually exists inside the container.
# The administrator is responsible for mounting this key securely.
if [ ! -f "$REMOTE_KEY_PATH" ]; then
  echo "❌ Error: SSH private key not found at the specified path: $REMOTE_KEY_PATH" >&2
  exit 1
fi

echo "🔒 Preparing to fetch data..."
echo "   - Remote User: $REMOTE_USER"
echo "   - Remote Host: $REMOTE_HOST"
echo "   - Remote Path: $REMOTE_DATA_PATH"
echo "   - Target Directory: /data"

# --- Data Transfer ---
# Execute the secure copy (scp) command.
# -i: Specifies the identity file (private key) for authentication.
# -r: Recursively copies entire directories.
# -o StrictHostKeyChecking=no: Automatically accept new host keys. This is suitable for
#   an automated, isolated environment. In higher security contexts, the host key
#   should be pre-filled in a known_hosts file.
# -o UserKnownHostsFile=/dev/null: Prevents writing to a known_hosts file.
scp -r -i "$REMOTE_KEY_PATH" \
    -o "StrictHostKeyChecking=no" \
    -o "UserKnownHostsFile=/dev/null" \
    "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DATA_PATH}" /data/

# --- Verification ---
# Check the exit code of the scp command to determine success or failure.
if [ $? -eq 0 ]; then
  echo "✅ Success: Data has been securely fetched and is now available in the /data directory."
  echo "   Contents of /data:"
  ls -l /data
else
  echo "❌ Error: Data fetch failed. Please check your connection details, network access from the host, and remote server permissions." >&2
  exit 1
fi
