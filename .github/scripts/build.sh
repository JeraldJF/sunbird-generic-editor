#!/bin/bash

# Exit on any error
set -e

BRANCH_NAME=$1
COMMIT_HASH=$2

echo "Building generic editor for branch: $BRANCH_NAME commit: $COMMIT_HASH"

# Set NODE_OPTIONS to handle the primordials issue
export NODE_OPTIONS="--no-global-search-paths --require graceful-fs"

# Clean install dependencies
rm -rf node_modules package-lock.json
npm cache clean --force

# Install dependencies with legacy peer deps and no optional
npm install --legacy-peer-deps --no-optional

# Run build commands with specific webpack version
echo "Installing webpack and webpack-cli"
npm install webpack@4.46.0 webpack-cli@3.3.12 --save-dev

# Run build with node options
echo "Running build command..."
if [ -f "webpack.config.js" ]; then
    echo "Using webpack.config.js"
    ./node_modules/.bin/webpack --config webpack.config.js --mode=production
else
    echo "No webpack config found, using default build command"
    npm run build
fi

# Create zip file of the build
zip -r generic-editor.zip dist/*

echo "Build completed successfully!"