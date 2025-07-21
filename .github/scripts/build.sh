#!/bin/bash

# Exit on any error
set -e

BRANCH_NAME=$1
COMMIT_HASH=$2

echo "Building generic editor for branch: $BRANCH_NAME commit: $COMMIT_HASH"

# Install dependencies if needed
if [ ! -d "node_modules" ]; then
    npm install --no-optional
fi

# Run build commands
npm run build

# Create zip file of the build
zip -r generic-editor.zip dist/*

echo "Build completed successfully!"