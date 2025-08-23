#!/bin/sh
set -eu

main() {
  selection=$(make_selection)
  if [ -z "$selection" ]; then
    exit 0
  fi

  # Remove prefix if present
  clean_selection=$(echo "$selection" | sed 's/^[* ] //')

  if session_exists "$clean_selection"; then
    session_name="$clean_selection"
  else
    project="$clean_selection"
    project_name=$(basename "$project")

    if is_oss_project "$project"; then
      branch_name=$(select_oss_branch "$project")
      project_dir="$(pwd)/$project/${branch_name}.jj"
      session_name="$project/${branch_name}"
    else
      project_dir="$(pwd)/$project"
      session_name="$project"
    fi

    if ! session_exists "$session_name"; then
      create_session "$session_name" "$project_dir"
    fi
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

make_selection() {
  sessions_and_projects | fzf_select --prompt="Select project or session: " --tiebreak=index
}

sessions_and_projects() {
  existing_sessions=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | grep -E "^(src|oss)/" || true)
  projects=$(ls -dt src/* oss/* 2>/dev/null)

  if [ -n "$existing_sessions" ]; then
    prefixed_sessions=$(echo "$existing_sessions" | sed 's/^/* /')
    prefixed_projects=$(echo "$projects" | sed 's/^/  /')
    printf "%s\n%s" "$prefixed_sessions" "$prefixed_projects"
  else
    printf "%s" "$projects"
  fi
}

session_exists() {
  tmux has-session -t "=$1" 2>/dev/null
}

is_oss_project() {
  echo "$1" | grep -q "^oss/"
}

fzf_select() {
  fzf "$@" || true
}

check_for_empty_branch() {
  branch_name="$1"
  if [ -z "$branch_name" ]; then
    exit 0
  fi
}

select_oss_branch() {
  project="$1"
  branches=$(ls -dt "$project"/*.jj 2>/dev/null | sed 's|.*/||; s|\.jj$||')
  branch_name=$(echo "$branches" | fzf_select --prompt="Select branch: " --print-query | tail -n1)
  check_for_empty_branch "$branch_name"

  if [ ! -d "$project/${branch_name}.jj" ]; then
    jj -R "$project/default.jj" workspace add --name "$branch_name" "$project/${branch_name}.jj"
  fi

  echo "$branch_name"
}

main "${@}"
