#!/bin/bash
STARTTIME=$(date +%s)
NODE_VERSION=12.22.12
branch_name=$1
commit_hash=$2
runTest=$3
echo "runTest: " $runTest
echo "Starting editor build from build.sh"
set -euo pipefail	
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
nvm install $NODE_VERSION
nvm use $NODE_VERSION
export version_number=$branch_name
export build_number=$commit_hash
rm -rf generic-editor

# Install global dependencies if not present
which bower || npm install -g bower
which gulp || npm install -g gulp

node -v
npm -v 
npm install
cd app
bower cache clean
bower install --force
cd ..
gulp packageCorePlugins
npm run plugin-build
npm run build

if [ "$runTest" = "true" ]; then
    npm run test
fi
