start_spinner() {
    $CURRENT_DIR/tmux_spinner.sh "$1" "$2" &
    export SPINNER_PID=$!
}

stop_spinner() {
    kill $SPINNER_PID
    if [ -n "$SPINNER_PID" ]; then
        kill "$SPINNER_PID" 2>/dev/null || true
    fi
}
