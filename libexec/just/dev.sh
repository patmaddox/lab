#!/bin/sh
set -eu

main() {
  project=$(ls -d src/* oss/* 2>/dev/null | fzf --prompt="Select project: ")
  if [ -z "$project" ]; then
    echo "No project selected"
    exit 1
  fi

  project_name=$(basename "$project")

  if is_oss_project "$project"; then
    branch_name=$(select_oss_branch "$project")
    project_dir="$(pwd)/$project/${branch_name}.jj"
  else
    branch_name=$(select_src_branch)
    project_dir="$(pwd)/$project"
  fi

  session_name=$(echo "${project_name}-${branch_name}" | tr '.' '-')

  if ! tmux has-session -t "$session_name" 2>/dev/null; then
    create_session "$session_name" "$project_dir"
  fi

  if [ -n "$TMUX" ]; then
    tmux switch-client -t "$session_name"
  else
    tmux attach-session -t "$session_name"
  fi
}

create_session() {
  session_name="$1"
  project_dir="$2"

  tmux new-session -d -s "$session_name" -c "$project_dir" nvim .
  tmux select-pane -t "$session_name:0.0" -T "editor"

  tmux split-window -t "$session_name:0" -h -c "$project_dir"
  tmux select-pane -t "$session_name:0.1" -T "shell"

  tmux split-window -t "$session_name:0.1" -v -c "$project_dir"
  tmux select-pane -t "$session_name:0.2" -T "claude"

  tmux send-keys -t "$session_name:0.2" "doas jexec -l -u $(whoami) -d $project_dir claude ~/.npm-global/bin/claude" C-m

  tmux select-pane -t "$session_name:0.0"
}

is_oss_project() {
  echo "$1" | grep -q "^oss/"
}

check_for_empty_branch() {
  branch_name="$1"
  if [ -z "$branch_name" ]; then
    echo "No branch selected" >&2
    exit 1
  fi
}

select_oss_branch() {
  project="$1"
  branches=$(find "$project" -maxdepth 1 -name "*.jj" -type d | sed 's|.*/||; s|\.jj$||')
  branch_name=$(echo "$branches" | fzf --prompt="Select branch: " --print-query | tail -n1)
  check_for_empty_branch "$branch_name"

  if [ ! -d "$project/${branch_name}.jj" ]; then
    jj -R "$project/default.jj" workspace add --name "$branch_name" "$project/${branch_name}.jj"
  fi

  echo "$branch_name"
}

select_src_branch() {
  printf "Enter branch name: " >/dev/tty
  read -r branch_name </dev/tty
  check_for_empty_branch "$branch_name"
  echo "$branch_name"
}

main "${@}"
