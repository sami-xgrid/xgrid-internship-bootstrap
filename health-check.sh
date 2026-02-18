#!/bin/bash
# A simple health reporter
echo "{
  \"cpu_usage\": \"$(top -bn1 | grep "Cpu(s)" | awk '{print $2}')%\",
  \"memory_free\": \"$(free -m | awk '/Mem:/ {print $4}')MB\",
  \"disk_usage\": \"$(df -h / | awk 'NR==2 {print $5}')\"
}"
