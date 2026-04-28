#!/bin/bash

SYSTEM_PROMPT="Give ONE bash practice problem for moderately advanced user.
Just the problem description. No hints, no expected output, no explanation.
The solution should not use loops.
Plain text, no markdown, be concise."

# Step 1: Generate the problem
PROBLEM=$(claude -p "$SYSTEM_PROMPT" )
echo "$PROBLEM"
echo ""

ATTEMPT=1

# Step 2: Loop until correct
while true; do
  echo "Attempt $ATTEMPT — your command:"
  read -r USER_COMMAND

  [[ "$USER_COMMAND" == "quit" ]] && exit 0

  COMMAND_OUTPUT=$(eval "$USER_COMMAND" 2>&1)
  EXIT_CODE=$?

  VERIFY_PROMPT="Problem: $PROBLEM
Command: $USER_COMMAND
Output (exit code $EXIT_CODE): $COMMAND_OUTPUT
Reply with ONLY the word 'true' or 'false'. Nothing else."

  VERDICT=$(claude -p "$VERIFY_PROMPT" | head -n1 | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')
  echo "DEBUG: '$VERDICT'"  # add this

  if [[ "$VERDICT" == "true" ]]; then
    echo "true — solved in $ATTEMPT attempt(s)."
    exit 0
  else
    echo "false"
    ATTEMPT=$((ATTEMPT + 1))
  fi
done
