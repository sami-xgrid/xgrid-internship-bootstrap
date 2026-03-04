#!/bin/bash

# 1. Collect System Metrics
cpu=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}')
mem=$(free -m | awk '/Mem:/ {print $4}')
disk=$(df -h / | awk 'NR==2 {print $5}')

# 2. Extract Top 5 Processes
procs=$(ps -eo pid,pcpu,comm --sort=-pcpu | head -n 6 | tail -n 3 | awk '{
    printf "{\"pid\": %s, \"cpu\": \"%s%%\", \"cmd\": \"%s\"}", $1, $2, $3
    if (NR < 3) printf ","
}')

# 3. Output JSON using Heredoc (cat << EOF)
cat << EOF | jq .
{
  "system_summary": {
    "cpu_load": "$cpu%",
    "memory_available_mb": $mem,
    "root_disk_usage": "$disk"
  },
  "top_resource_consumers": [
    $procs
  ],
  "metadata": {
    "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
    "host": "$(hostname)"
  }
}
EOF
