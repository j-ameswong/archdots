#!/bin/bash

output=$(nvidia-smi --query-gpu=temperature.gpu,utilization.gpu --format=csv,noheader,nounits)
output2=$(nvidia-smi dmon -s=c -c=1 --format=csv,nounit,noheader)

temperature=$(echo "$output" | awk -F', ' '{print $1}')
busypercent=$(echo "$output" | awk -F', ' '{print $2}')
memclock=$(echo "$output2" | awk -F', ' '{print $2}')
mclk_ghz=$(echo "$memclock 1000" | awk '{printf "%.2f", $1 / $2}')
pcsclock=$(echo "$output2" | awk -F', ' '{print $3}')
pclk_ghz=$(echo "$pcsclock 1000" | awk '{printf "%.2f", $1 / $2}')

echo '{"text": "   '$pclk_ghz'GHz <span color=\"darkgray\">| '$busypercent'%</span>", "class": "custom-gpu", "tooltip": " '$temperature'°C | '$mclk_ghz'GHz"}'

