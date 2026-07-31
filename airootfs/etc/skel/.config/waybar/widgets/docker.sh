#!/usr/bin/env bash
. "$(dirname "$0")/_common.sh"

command -v docker >/dev/null || { out "󰡨 —" "Docker no instalado" "warn"; exit 0; }
docker info >/dev/null 2>&1 || { out "󰡨 off" "Demonio de Docker parado" "warn"; exit 0; }

run=$(docker ps -q | wc -l)
all=$(docker ps -aq | wc -l)
det=$(docker ps --format "{{.Names}}: {{.Status}}" | head -8)
cls="ok"; [ "$run" -eq 0 ] && cls=""
out "󰡨 ${run}" "Docker · ${run}/${all} contenedores activos"$"\n""${det}" "$cls"
