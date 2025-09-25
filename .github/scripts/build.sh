#!/bin/bash

# Exit on any error
set -e

BRANCH_NAME=$1
COMMIT_HASH=$2

echo "Building generic editor for branch: $BRANCH_NAME commit: $COMMIT_HASH"

# Create .npmrc to use legacy OpenSSL provider
echo "legacy-peer-deps=true" > .npmrc
echo "node-options=--openssl-legacy-provider" >> .npmrc

# Clean install dependencies
echo "Cleaning npm cache and node_modules..."
rm -rf node_modules package-lock.json
npm cache clean --force

# Create patch for graceful-fs
mkdir -p patches
cat > patches/graceful-fs+4.2.0.patch << 'EOL'
diff --git a/polyfills.js b/polyfills.js
index 091056f..e436626 100644
--- a/polyfills.js
+++ b/polyfills.js
@@ -1,3 +1,10 @@
+var fs = require('fs')
+if (!fs.chmod || !fs.fchmod) {
+  fs.chmod = fs.fchmod = function (a, b, c) {
+    if (typeof c === 'function') c()
+  }
+}
+
 var constants = require('constants')
 
 var origCwd = process.cwd
EOL

# Install dependencies with patches
echo "Installing dependencies..."
npm install --save-dev patch-package
npm install --legacy-peer-deps
npx patch-package graceful-fs

# Install specific webpack version
echo "Installing webpack..."
npm install webpack@4.46.0 webpack-cli@3.3.12 --save-dev

# Run build command
echo "Running build command..."
if [ -f "webpack.config.js" ]; then
    echo "Using webpack.config.js"
    # Use npx to ensure we use the local webpack installation
    npx --no-install webpack --config webpack.config.js --mode=production
else
    echo "No webpack config found, falling back to gulp"
    npx --no-install gulp
fi

# Create zip file of the build
zip -r generic-editor.zip dist/*

echo "Build completed successfully!"