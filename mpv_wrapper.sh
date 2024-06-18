#!/bin/bash

# Check if the script is being called as "mpv"
if [[ "$(basename "$0")" == "mpv" ]]; then
    # Log file path
    LOG_FILE="$(cd "$(dirname "$0")" && pwd)/launcher.log"

    # Function to log messages to the file
    log() {
        echo "$(date +'%Y-%m-%d %H:%M:%S') $@" >> "$LOG_FILE"
    }

    # Initialize the log file (clear previous contents)
    > "$LOG_FILE"

    # Custom mpv script logic
    mpv_wrapper() {
        log "In mpv_wrapper"

        # Function to handle the mpv version check
        handle_version_check() {
            log "Handling version check"
            /usr/bin/mpv --version
            exit 0
        }

        # Check if mpv is being invoked to check its version
        for arg in "$@"; do
            case "$arg" in
                --version|-v)
                    handle_version_check
                    ;;
            esac
        done

        # Function to launch mitmproxy and mpv
        launch_mitmproxy_and_mpv() {
            log "Launching mitmproxy and mpv"
            # Launch mitmdump in the background
            mitmdump &
            log "Mitmproxy launched with PID $!"

            # Get the PID of mitmdump
            mitmdump_pid=$!

            sleep 1

            # Launch mpv and forward its stdout and stderr to log file
            /usr/bin/mpv "$@" &
            log "mpv launched with PID $!"

            # Wait for mpv to finish
            mpv_pid=$!
            wait $mpv_pid

            log "mpv exited"

            # Kill mitmdump when mpv exits
            kill $mitmdump_pid
            log "Mitmproxy killed"
        }

        # Get the parent process ID
        ppid=$(grep -i ppid /proc/$$/status | awk '{print $2}')
        log "Parent process ID: $ppid"

        # Check the parent process name
        cl=$(ps -p $ppid -o comm=)
        log "Parent process name: $cl"

        # If the parent process name contains the program name substring
        if echo "$cl" | grep -iqF "AniLab"; then
            log "Parent process name contains program name substring"
            launch_mitmproxy_and_mpv "$@"
        else
            log "Not launched by the specific program, forwarding mpv's output"
            /usr/bin/mpv "$@" >> "$LOG_FILE" 2>&1
        fi
    }

    mpv_wrapper "$@"
    exit 0
fi

# Proceed with main script if not called as mpv

# Get the absolute path to the script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Determine the name of the actual program by finding the first executable file in the directory
PROGRAM_NAME=$(find "$SCRIPT_DIR" -maxdepth 1 -type f -executable ! -name "$(basename "$0")" -exec basename {} \; | head -n 1)

# Exit if no executable program is found
if [[ -z "$PROGRAM_NAME" ]]; then
    echo "No executable program found in $SCRIPT_DIR"
    exit 1
fi

# Export the directory of this script to the PATH to override mpv
export PATH="$SCRIPT_DIR:$PATH"

# Create a symlink for mpv in the same directory as this script if it doesn't already exist
if [[ ! -e "$SCRIPT_DIR/mpv" ]]; then
    ln -s "$SCRIPT_DIR/$(basename "$0")" "$SCRIPT_DIR/mpv"
    link_created=true
else
    link_created=false
fi

# Launch the actual program with any passed arguments
exec "$SCRIPT_DIR/$PROGRAM_NAME" "$@"

# Clean up the symlink if it was created by this script
if [[ "$link_created" == true ]]; then
    rm "$SCRIPT_DIR/mpv"
fi
