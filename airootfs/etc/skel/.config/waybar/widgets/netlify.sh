#!/usr/bin/env bash
. "$(dirname "$0")/_common.sh"
need NETLIFY_TOKEN "netlify"

r=$(curl -sfH "Authorization: Bearer $NETLIFY_TOKEN" "https://api.netlify.com/api/v1/sites?per_page=5")
st=$(echo "$r" | jq -r "[.[].published_deploy.state][0] // \"n/a\"")
nm=$(echo "$r" | jq -r ".[0].name // \"n/a\"")

case "$st" in
  ready)              cls="ok" ;;
  building|enqueued)  cls="warn" ;;
  error|failed)       cls="err" ;;
  *)                  cls="" ;;
esac
out "󰖟 ${st}" "Netlify · ${nm}: ${st}" "$cls"
