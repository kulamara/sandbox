#!/bin/bash

# deploy.sh: Main deployment script for the secure sandbox.
# This script builds and launches the Docker container.
# It accepts an optional container name as the first argument.

# Set default container name if not provided.
CONTAINER_NAME=${1:-"secure-sandbox"}

# Export the variable so it can be accessed in docker-compose.yml
export CONTAINER_NAME

echo "🚀 Starting deployment of container: $CONTAINER_NAME"

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
  echo "❌ Docker does not seem to be running. Please start Docker and try again."
  exit 1
fi

# Build and launch the container using Docker Compose.
# The --build flag ensures the image is always rebuilt with the latest changes.
# The -d flag runs the container in detached mode.
docker-compose up --build -d

# Check the exit code of the docker-compose command
if [ $? -eq 0 ]; then
  echo "✅ Sandbox container '$CONTAINER_NAME' deployed successfully."
  echo "👉 To access the sandbox, run: docker exec -it $CONTAINER_NAME /bin/sh"
else
  echo "❌ Deployment failed. Check the output from Docker Compose for errors."
  exit 1
fi
