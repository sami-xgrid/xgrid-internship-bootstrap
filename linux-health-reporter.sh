#!/bin/bash
# Description: Linux Health Reporter for Sprint 1

set -e # Exit immediately if a command fails

# Check for dependencies
for cmd in jq; do
    if ! command -v $cmd &> /dev/null; then
        echo "{\"error\": \"$cmd is not installed.\"}"
        exit 1
    fi
done

# Metric Collection
uptime=$(uptime -p)
cpu_load=$(cat /proc/loadavg | awk '{print $1}')
mem_used_pct=$(free | grep Mem | awk '{print $3/$2 * 100.0}')
disk_used_pct=$(df -h / | awk 'NR==2 {print $5}')

# Top 3 processes by Memory
top_procs=$(ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head -n 4 | tail -n 3 | \
awk '{printf "{\"pid\":%s,\"cmd\":\"%s\",\"mem_pct\":\"%s\"},", $1, $3, $4}' | sed 's/,$//')

# JSON Output
echo "{
  \"system\": {
    \"uptime\": \"$uptime\",
    \"cpu_load_1m\": $cpu_load,
    \"memory_usage_pct\": \"${mem_used_pct%.*}%\",
    \"disk_usage_pct\": \"$disk_used_pct\"
  },
  \"top_memory_processes\": [$top_procs]
}" | jq .
