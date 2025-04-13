#!/bin/bash

# Create directories on Remote Host
mkdir -p "/root/HOSTS"

# Update Repositories
apt update

# Install Dependencies
apt install sshfs -y
