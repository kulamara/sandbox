#!/bin/sh

# install_command.sh: Securely installs a new command from the /inbox
# directory into /usr/local/bin, making it available to the user.
# This action requires authentication via a token.

# --- Argument and Environment Validation ---

# Check if the required number of arguments (token and script name) are provided.
if [ "$#" -ne 2 ]; then
  echo "? Error: Invalid number of arguments." >&2
  echo "   Usage: install_command <auth_token> <script_filename>" >&2
  exit 1
fi

# Assign arguments to variables for clarity.
AUTH_TOKEN="$1"
SCRIPT_FILENAME="$2"

# The source path where new scripts are placed by the administrator.
SOURCE_PATH="/inbox/${SCRIPT_FILENAME}"
# The destination path for executable commands.
DEST_PATH="/usr/local/bin/${SCRIPT_FILENAME}"

# Check if the secret token is configured in the container's environment.
if [ -z "$INSTALL_TOKEN" ]; then
  echo "? Security Alert: The INSTALL_TOKEN is not set in the environment." >&2
  echo "   Installation is disabled until the administrator configures it." >&2
  exit 1
fi

# --- Authentication ---

# Compare the provided token with the secret token from the environment variable.
if [ "$AUTH_TOKEN" != "$INSTALL_TOKEN" ]; then
  echo "? Error: Invalid authentication token. Permission denied." >&2
  exit 1
fi

echo "? Authentication successful."

# --- File and Installation Logic ---

# Check if the script to be installed actually exists in the inbox.
if [ ! -f "$SOURCE_PATH" ]; then
  echo "? Error: The script '$SCRIPT_FILENAME' was not found in /inbox." >&2
  exit 1
fi

echo "? Installing command '$SCRIPT_FILENAME'..."

# Copy the script to the system's binary path.
# Using `cp` keeps the original script in the inbox for repeated demonstrations.
cp "$SOURCE_PATH" "$DEST_PATH"

if [ $? -ne 0 ]; then
    echo "? Error: Failed to copy the script to the destination." >&2
    exit 1
fi

# Make the newly installed script executable for the user.
chmod +x "$DEST_PATH"

if [ $? -eq 0 ]; then
  echo "? Success: Command '$SCRIPT_FILENAME' has been installed to $DEST_PATH and is now executable."
else
    echo "? Error: Failed to make the script executable. Check permissions." >&2
    # Attempt to clean up by removing the moved file if chmod fails.
    rm "$DEST_PATH" 2>/dev/null
    exit 1
fi
