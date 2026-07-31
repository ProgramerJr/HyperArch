#!/usr/bin/env bash
. "$(dirname "$0")/_common.sh"

command -v rocm-smi >/dev/null || { out "󰢮 —" "rocm-smi no disponible" "warn"; exit 0; }
j=$(rocm-smi --showuse --showmemuse --showtemp --json 2>/dev/null) || { out "󰢮 —" "GPU no legible" "warn"; exit 0; }
k=$(echo "$j" | jq -r "keys[0]")
use=$(echo "$j" | jq -r ".[\"$k\"][\"GPU use (%)\"] // \"0\"" | tr -dc "0-9")
used=$(echo "$j" | jq -r ".[\"$k\"][\"VRAM Total Used Memory (B)\"] // 0")
tot=$(echo "$j"  | jq -r ".[\"$k\"][\"VRAM Total Memory (B)\"] // 1")
tmp=$(echo "$j"  | jq -r ".[\"$k\"][\"Temperature (Sensor edge) (C)\"] // \"0\"" | tr -dc "0-9.")
gb() { awk -v b="$1" "BEGIN{printf \"%.1f\", b/1073741824}"; }

cls="ok"; [ "${use:-0}" -gt 90 ] 2>/dev/null && cls="warn"
out "󰢮 ${use:-0}%" "RX 7900 XTX · uso ${use:-0}% · VRAM $(gb "$used")/$(gb "$tot") GB · ${tmp}°C" "$cls"
