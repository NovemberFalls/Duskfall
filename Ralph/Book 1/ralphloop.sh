#!/bin/bash
set -euo pipefail

ITERATIONS="$1"
MODEL="gpt-5.2-codex"

PRD_FILE="prd.md"
PROGRESS_FILE="progress.txt"

WORLD_FILES=(
    "World/00 - Premise.md"
    "World/01 - POV Characters.md"
    "World/02 - Themes and Emotional Beats.md"
    "World/03 - November Falls - Character Bible.md"
    "World/04 - Writing Rules.md"
    "World/05 - November Falls - Personality Profile.md"
)

for ((i=1; i<=ITERATIONS; i++)); do

    TASK=$(grep -m1 "\[ \] C" "$PRD_FILE" || true)

    if [ -z "$TASK" ]; then
        echo "All tasks complete."
        exit 0
    fi

    CHAPTER=$(echo "$TASK" | grep -o "C[0-9][0-9]")

    CHAPTER_DIR="Book 1/Chapters/$CHAPTER"
    DECISION_DIR="Book 1/Chapters/Decisions"
    mkdir -p "$CHAPTER_DIR"
    mkdir -p "$DECISION_DIR"

    OUTPUT_FILE="$CHAPTER_DIR/draft.md"

    CONTEXT=""
    for FILE in "${WORLD_FILES[@]}"; do
        CONTEXT+="$(cat "$FILE")"$'\n\n'
    done

    PROMPT="$CONTEXT

TASK: $TASK

Write full draft (3,000–5,000 words).

Follow Writing Rules strictly.
Do not revise previous chapters.
If moral crossroads appears, output:

DECISION REQUIRED:
Chapter:
Context:
Options:
"

    PROMPT_FILE="$(mktemp)"
    printf "%s" "$PROMPT" > "$PROMPT_FILE"
    RESPONSE=$(codex exec -m "$MODEL" < "$PROMPT_FILE")
    rm -f "$PROMPT_FILE"

    if echo "$RESPONSE" | grep -q "DECISION REQUIRED"; then
        DECISION_FILE="$DECISION_DIR/$CHAPTER - Decision.md"
        echo "$RESPONSE" > "$DECISION_FILE"
        echo "Decision required. Halting."
        exit 0
    fi
    if echo "$RESPONSE" | grep -qiE "before i draft|need a couple specifics|which pov|must-hit beats"; then
        CLARIFY_FILE="$DECISION_DIR/$CHAPTER - Clarify.md"
        echo "$RESPONSE" > "$CLARIFY_FILE"
        echo "Clarification required. Halting."
        exit 0
    fi

    echo "$RESPONSE" > "$OUTPUT_FILE"

    sed -i '0,/\[ \] C/ s/\[ \] C/\[x\] C/' "$PRD_FILE"

    echo "[$(date '+%Y-%m-%d %H:%M')] $MODEL | $CHAPTER | Draft Complete" >> "$PROGRESS_FILE"

    git add .
    git commit -m "Layer 1 Draft $CHAPTER"

done
