#!/bin/bash

# Exit on any error
set -e

BRANCH_NAME=$1
COMMIT_HASH=$2

echo "Building generic editor for branch: $BRANCH_NAME commit: $COMMIT_HASH"

# Clean install dependencies
echo "Cleaning npm cache and node_modules..."
rm -rf node_modules package-lock.json
npm cache clean --force

# Install specific versions of critical dependencies first
echo "Installing specific webpack versions..."
npm install webpack@4.46.0 webpack-cli@3.3.12 graceful-fs@4.2.0 --save-dev

# Install remaining dependencies
echo "Installing project dependencies..."
npm install --legacy-peer-deps --no-optional

# Apply patch for primordials issue
echo "Applying fixes for Node.js compatibility..."
npm install natives@1.1.6 --save-dev

# Run build command
echo "Running build command..."
if [ -f "webpack.config.js" ]; then
    echo "Using webpack.config.js"
    NODE_ENV=production ./node_modules/.bin/webpack --config webpack.config.js
else
    echo "No webpack config found, falling back to gulp"
    ./node_modules/.bin/gulp
fi

# Create zip file of the build
zip -r generic-editor.zip dist/*

echo "Build completed successfully!"