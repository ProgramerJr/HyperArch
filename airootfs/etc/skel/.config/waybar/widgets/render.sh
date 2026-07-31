#!/usr/bin/env bash
. "$(dirname "$0")/_common.sh"
need RENDER_TOKEN "render"

r=$(curl -sfH "Authorization: Bearer $RENDER_TOKEN" "https://api.render.com/v1/services?limit=20")
n=$(echo "$r" | jq "[.[] | select(.service.suspended==\"not_suspended\")] | length")
names=$(echo "$r" | jq -r "[.[].service.name] | join(\", \")")
out "󰡄 ${n}" "Render · ${n} servicios activos: ${names}" "ok"
