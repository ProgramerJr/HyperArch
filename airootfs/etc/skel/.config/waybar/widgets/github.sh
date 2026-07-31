#!/usr/bin/env bash
. "$(dirname "$0")/_common.sh"
need GITHUB_TOKEN "gh"

H=(-sfH "Authorization: Bearer $GITHUB_TOKEN" -H "Accept: application/vnd.github+json")
prs=$(curl "${H[@]}" "https://api.github.com/search/issues?q=is:open+is:pr+author:${GITHUB_USER}" | jq ".total_count // 0")
iss=$(curl "${H[@]}" "https://api.github.com/search/issues?q=is:open+is:issue+assignee:${GITHUB_USER}" | jq ".total_count // 0")
run=$(curl "${H[@]}" "https://api.github.com/users/${GITHUB_USER}/events" \
      | jq -r "[.[] | select(.type==\"WorkflowRunEvent\")][0].payload.workflow_run.conclusion // \"none\"")

cls="ok"; [ "$run" = "failure" ] && cls="err"
out "󰊤 ${prs}/${iss}" "GitHub · ${prs} PR abiertas · ${iss} issues asignadas · último workflow: ${run}" "$cls"
