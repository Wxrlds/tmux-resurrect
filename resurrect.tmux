#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$CURRENT_DIR/scripts/variables.sh"
source "$CURRENT_DIR/scripts/helpers.sh"

set_save_bindings() {
    local key_bindings=$(get_tmux_option "$save_option" "$default_save_key")
    local key
    for key in $key_bindings; do
        tmux bind-key "$key" command-prompt -p "Save session as (leave empty for date):" "run-shell '$CURRENT_DIR/scripts/save.sh \"\" \"%1\"'"
    done
}

set_restore_bindings() {
    local key_bindings=$(get_tmux_option "$restore_option" "$default_restore_key")
    local key
    for key in $key_bindings; do
        tmux bind-key "$key" run-shell "tmux display-popup -w 60 -h 20 -E \"bash '$CURRENT_DIR/scripts/restore_menu.sh'\" 2>/dev/null || tmux split-window -v -l 15 \"bash '$CURRENT_DIR/scripts/restore_menu.sh'\""
    done
}

set_default_strategies() {
    tmux set-option -gq "${restore_process_strategy_option}irb" "default_strategy"
    tmux set-option -gq "${restore_process_strategy_option}mosh-client" "default_strategy"
}

set_script_path_options() {
    tmux set-option -gq "$save_path_option" "$CURRENT_DIR/scripts/save.sh"
    tmux set-option -gq "$restore_path_option" "$CURRENT_DIR/scripts/restore.sh"
}

main() {
    set_save_bindings
    set_restore_bindings
    set_default_strategies
    set_script_path_options
}
main
