#!/usr/bin/env bash
CONTEXT="At session start: if SPEC.md and PLAN.md exist in this project, run the spec-sync-checker subagent before starting any new work, and report its findings before proceeding."

cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "$CONTEXT"
  }
}
EOF
