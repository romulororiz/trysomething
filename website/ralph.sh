#!/bin/bash
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

if [ -z "$1" ]; then
  echo -e "${RED}Usage:${NC} $0 <max_iterations>"
  exit 1
fi

MAX=$1

for file in PROMPT.md prd.md activity.md; do
  if [ ! -f "$file" ]; then
    echo -e "${RED}Missing:${NC} $file"
    exit 1
  fi
done

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}  TrySomething Ralph Loop — max $MAX iterations${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

for ((i=1; i<=$MAX; i++)); do
  echo -e "${YELLOW}━━━ Iteration $i / $MAX ━━━${NC}"

  result=$(claude -p "$(cat PROMPT.md)" --dangerously-skip-permissions --output-format text 2>&1) || true
  echo "$result"

  if [[ "$result" == *"<promise>COMPLETE</promise>"* ]]; then
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}  ✅ All tasks complete after $i iterations!${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    exit 0
  fi

  echo -e "${CYAN}--- end iteration $i ---${NC}"
  echo ""
  sleep 3
done

echo -e "${RED}⚠️  Max iterations ($MAX) reached.${NC}"
exit 1
