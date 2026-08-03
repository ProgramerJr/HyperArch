#!/usr/bin/env bash
. "$(dirname "$0")/_common.sh"

# checkupdates no toca la base de datos del sistema (pacman-contrib)
n=$(checkupdates 2>/dev/null | wc -l)
a=0
command -v yay >/dev/null && a=$(yay -Qua 2>/dev/null | wc -l)
total=$((n + a))

if [ "$total" -eq 0 ]; then
    out "󰄬" "Sistema al día" "ok"
elif [ "$total" -lt 25 ]; then
    out "󰚰 $total" "$n del repo · $a del AUR — clic para actualizar" "ok"
else
    out "󰚰 $total" "$n del repo · $a del AUR — conviene actualizar" "warn"
fi
