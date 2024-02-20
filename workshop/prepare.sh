#!/bin/bash

echo "# Checking that all dependnecies are installed"
command -v docker >/dev/null 2>&1 || { echo 'Please install docker'; exit 1; }
command -v kind >/dev/null 2>&1 || { echo 'Please install kind'; exit 1; }
command -v kubectl >/dev/null 2>&1 || { echo 'Please install kubectl'; exit 1; }
command -v go >/dev/null 2>&1 || { echo 'Please install go'; exit 1; }
echo "# All dependencies installed"
# Run kind command
