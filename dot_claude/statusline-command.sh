#!/bin/sh

input=$(cat)

# Model name: prefer session context, fall back to env vars
model_name=$(echo "$input" | jq -r '.model.id // empty')
if [ -z "$model_name" ]; then
  model_name="${CLAUDE_MODEL:-${ANTHROPIC_MODEL:-claude}}"
fi

# Token counts: derive used tokens from pre-calculated used_percentage * context_window_size
# current_usage.input_tokens is often 0 when idle; used_percentage is reliable after first message
window_size=$(echo "$input" | jq -r '.context_window.context_window_size // empty')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# Format as Xk/Xk
if [ -n "$used_pct" ] && [ -n "$window_size" ] && [ "$window_size" -gt 0 ] 2>/dev/null; then
  used_k=$(echo "$used_pct $window_size" | awk '{used = int($1 / 100 * $2 + 0.5); printf "%dk/%dk", int((used+500)/1000), int(($2+500)/1000)}')
else
  used_k="--k/--k"
fi

context_part="${model_name} ${used_k}"

# Git info from current working directory
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')

git_part=""
if [ -n "$cwd" ]; then
  branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null)
  if [ -n "$branch" ]; then
    # Uncommitted changes (staged or unstaged)
    if ! git -C "$cwd" --no-optional-locks diff --quiet 2>/dev/null || \
       ! git -C "$cwd" --no-optional-locks diff --cached --quiet 2>/dev/null; then
      dirty=" *"
    else
      dirty=""
    fi

    # Unpushed commits
    upstream=$(git -C "$cwd" --no-optional-locks rev-parse --abbrev-ref '@{u}' 2>/dev/null)
    if [ -n "$upstream" ]; then
      ahead=$(git -C "$cwd" --no-optional-locks rev-list --count "@{u}..HEAD" 2>/dev/null)
      if [ -n "$ahead" ] && [ "$ahead" -gt 0 ] 2>/dev/null; then
        unpushed=" +${ahead}"
      else
        unpushed=""
      fi
    else
      unpushed=""
    fi

    git_part=" | git: ${branch}${dirty}${unpushed}"
  fi
fi

printf "%s%s\n" "$context_part" "$git_part"
