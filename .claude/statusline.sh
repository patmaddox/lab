#!/bin/sh
input=$(cat)
model=$(echo "${input}" | jq -r '.model.display_name // "unknown"')
pct=$(echo "${input}" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
#cost=$(echo "${input}" | jq -r '.cost.total_cost_usd // 0')
printf '[%s] %s%% context\n' "${model}" "${pct}"
