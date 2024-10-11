#!/bin/bash

# Check if running as root. If root, script will exit
if [[ $EUID -eq 0 ]]; then
    echo "This script should not be executed as root! Exiting......."
    exit 1
fi

# --------------- VARIABLES ---------------


# Determine the directory where the script is located
# And change (just in case) the working directory to the "hyprdots" (parent dir)
SCRIPTS_DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

PARENT_DIR="$SCRIPTS_DIR/.."
cd $PARENT_DIR

# Determine other directories
BASE_CONFIG_DIR="$HOME/.config"
CONFIGS_DIR="$PARENT_DIR/configs"
WALLPAPERS_DIR="$PARENT_DIR/wallpapers"
LOGS_DIR="$PARENT_DIR/Logs"

# Create dir for logs and ~/.config if it dosen't exist
mkdir -p "$LOGS_DIR"
mkdir -p "$BASE_CONFIG_DIR"

# Determine variable for .log file
LOG="$(basename $LOGS_DIR)/symlink-$(date "+%Y-%m-%d_%H-%M-%S").log"

# Set colors for messages
RED="$(tput setaf 160)"
GREEN="$(tput setaf 46)"
BLUE="$(tput setaf 39)"
YELLOW="$(tput setaf 226)"
ORANGE="$(tput setaf 202)"
CYAN="$(tput setaf 51)"
RESET="$(tput sgr0)"

ERROR="$(tput setaf 196)[ERROR]${RESET}"
OK="${GREEN}[OK]${RESET}"
NOTE="${BLUE}[NOTE]${RESET}"
ACTION="${YELLOW}[ACTION]${RESET}"
WARN="${ORANGE}[WARNING]${RESET}"
ATTENTION="${ORANGE}[ATTENTION]${RESET}"
QUESTION="${CYAN}[QUESTION]${RESET}"

# --------------- MAIN SCRIPT ---------------

# Create a symlinks
for CONF in "$CONFIGS_DIR"/* ; do 
	CONF_NAME="$(basename $CONF)"
	if [ "$CONF_NAME" == "zsh" ] ; then
		if ln -s "$CONFIGS_DIR/$CONF_NAME/.zshrc" "$HOME/.zshrc" >/dev/null 2>&1 ; then
			printf "%s\n" "${OK} Symlink for .zshrc created!"
		else
			ln -s "$CONFIGS_DIR/$CONF_NAME/.zshrc" "$HOME/.zshrc" 2>>"$LOG"
			printf "%s\n" "${ERROR} Failed to create symlink for .zshrc :( Check $LOG"
		fi
	else
		if ln -s "$CONFIGS_DIR/$CONF_NAME" "$BASE_CONFIG_DIR/$CONF_NAME" >/dev/null 2>&1 ; then
			printf "%s\n" "${OK} Symlink for $CONF_NAME created!"
		else
			ln -s "$CONFIGS_DIR/$CONF_NAME" "$BASE_CONFIG_DIR/$CONF_NAME" 2>>"$LOG"
			printf "%s\n" "${ERROR} Failed to create symlink for $CONF_NAME :( Check $LOG"
		fi
	fi
done


