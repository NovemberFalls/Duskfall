#!/bin/bash
set -euo pipefail

ITERATIONS="$1"
MODEL="gpt-5.2-codex"
OUTPUT_SUFFIX="${OUTPUT_SUFFIX:-}"

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

    CHAPTER_DIR="Chapters/$CHAPTER"
    DECISION_DIR="Chapters/Decisions"
    mkdir -p "$CHAPTER_DIR"
    mkdir -p "$DECISION_DIR"

    CLARIFY_FILE="$DECISION_DIR/$CHAPTER - Clarify.md"

    TITLE=""
    if [ -f "$CLARIFY_FILE" ]; then
        TITLE=$(grep -m1 '^Title:' "$CLARIFY_FILE" | sed 's/^Title:[[:space:]]*//')
        TITLE=$(printf "%s" "$TITLE" | tr '/\\:' '-' | tr -d '\r' | tr -d '<>"|?*')
    fi
    if [ -n "$TITLE" ]; then
        OUTPUT_FILE="$CHAPTER_DIR/$CHAPTER - $TITLE${OUTPUT_SUFFIX}.md"
    else
        OUTPUT_FILE="$CHAPTER_DIR/$CHAPTER - Draft${OUTPUT_SUFFIX}.md"
    fi

    CONTEXT=""
    for FILE in "${WORLD_FILES[@]}"; do
        CONTEXT+="$(cat "$FILE")"$'\n\n'
    done

    CLARIFY_TEXT=""
    if [ -f "$CLARIFY_FILE" ]; then
        CLARIFY_TEXT=$'\n\nCLARIFICATIONS:\n'"$(cat "$CLARIFY_FILE")"
    fi

    PROMPT="$CONTEXT

TASK: $TASK
$CLARIFY_TEXT

Write full draft (3,000-5,000 words).

Follow Writing Rules strictly.
Do not revise previous chapters.
Do not write files or run tools. Output only the draft text.
Avoid repetition. Vary sentence structure and imagery; no echoing phrases within a scene.

LANGUAGE & VOICE BY RACE:
- Orcs: rough, clipped, low-grammar. Short clauses, hard consonants. No polished English.
- Goblins: quick, fractured, sly. Choppy rhythm, slangy, implied cunning. No polished English.
- Trolls/others: simple, blunt, reduced syntax. Keep them distinct from orcs/goblins.
- Humans/Elves/etc: normal prose, but in-scene dialogue should match their background.
If unsure about a race's voice, stop and ask for clarification.

STONEVEIL MORALITY (from Humans.md):
- Alignment: Lawful Neutral. Duty over personal gain.
- Stoic, uncompromising, deeply pragmatic.
- Not heartless: he feels cost but suppresses it; morality expressed as restraint and burden, not speeches.

TONE UPGRADE:
- Grimdark, dreadful, almost horrific, but with a thin line of light in the darkness.
- Bitter-sweet: small human warmth amid ruin, never undercutting stakes.
- Prose should be sharp and tactile; no purple flourishes, no generic fantasy phrasing.
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
