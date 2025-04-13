#!/usr/bin/env bash
set -x

if command -v wget >/dev/null 2>&1; then
  echo "wget is installed"
else
  echo "dw bro ill install wget for you smh ts pmo frfr"
  apt install wget -y || yum install wget -y
fi
#This script is used to build the coordinate binary
GOLANG_VERSION=1.24.2

wget https://golang.org/dl/go"$GOLANG_VERSION".linux-amd64.tar.gz

if [ -d "/usr/local/go" ]; then
  echo "Removing Old Go"
  rm -rf /usr/local/go
fi

tar -C /usr/local -xzf go"$GOLANG_VERSION".linux-amd64.tar.gz
echo 'export PATH=$PATH:/usr/local/go/bin' >>~/.bashrc
export PATH=$PATH:/usr/local/go/bin
rm -rf go"$GOLANG_VERSION".linux-amd64.tar.gz

go build -o coordinate
