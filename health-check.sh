#!/bin/bash

# Extract system metrics
cpu=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}')
mem=$(free -m | awk '/Mem:/ {print $4}')
disk=$(df -h / | awk 'NR==2 {print $5}')

# Extract Top 5 Processes (PID, CPU%, Command)
procs=$(ps -eo pid,pcpu,comm --sort=-pcpu | head -n 6 | tail -n 5 | awk '{printf "{\"pid\":\"%s\",\"cpu\":\"%s\",\"cmd\":\"%s\"},", $1, $2, $3}' | sed 's/,$//')

# Combine into JSON and pipe through jq for pretty-printing
echo "{
  \"cpu_usage\": \"$cpu%\",
  \"memory_free\": \"${mem}MB\",
  \"disk_usage\": \"$disk\",
  \"top_processes\": [$procs]
}" | jq .