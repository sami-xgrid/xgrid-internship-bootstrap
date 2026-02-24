#!/bin/bash

# Title: System Audit Script
# Purpose: Quick health check for Disk, Ports, and Docker

echo "--- 1. DISK USAGE ---"
# -h: Human readable (GB/MB)
df -h | grep '^/dev/'

echo -e "\n--- 2. OPEN PORTS ---"
# -l: Listening ports, -t: TCP, -n: Numeric (shows 80 instead of 'http')
ss -ltn

echo -e "\n--- 3. DOCKER STATUS ---"
# Check if docker command exists, then list running containers
if command -v docker &> /dev/null; then
    docker ps --format "ID: {{.ID}} | Name: {{.Names}} | Status: {{.Status}}"
else
    echo "Docker not installed."
fi