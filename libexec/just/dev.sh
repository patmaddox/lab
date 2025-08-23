#!/bin/sh

main() {
  project=$(ls -d src/* oss/* 2>/dev/null | fzf --prompt="Select project: ")
  if [ -z "$project" ]; then
    echo "No project selected"
    exit 1
  fi

  project_name=$(basename "$project")

  printf "Enter branch name: "
  read -r branch_name
  if [ -z "$branch_name" ]; then
    echo "No branch name entered"
    exit 1
  fi

  session_name="${project_name}-${branch_name}"
  project_dir="$(pwd)/$project"

  tmux new-session -d -s "$session_name" -c "$project_dir" nvim .
  tmux select-pane -t "$session_name:0.0" -T "editor"

  tmux split-window -t "$session_name:0" -h -c "$project_dir"
  tmux select-pane -t "$session_name:0.1" -T "shell"

  tmux split-window -t "$session_name:0.1" -v -c "$project_dir"
  tmux select-pane -t "$session_name:0.2" -T "claude"

  tmux send-keys -t "$session_name:0.2" "doas jexec -l -u $(whoami) -d $project_dir claude ~/.npm-global/bin/claude" C-m

  tmux select-pane -t "$session_name:0.0"

  if [ -n "$TMUX" ]; then
    tmux switch-client -t "$session_name"
  else
    tmux attach-session -t "$session_name"
  fi
}

main "${@}"
