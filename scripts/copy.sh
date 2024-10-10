#!/bin/bash

# This scripts was made by https://github.com/freyyrr

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
LOG="$(basename $LOGS_DIR)/copy-$(date "+%Y-%m-%d_%H-%M-%S").log"

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
		if cp -r "$CONFIGS_DIR/$CONF_NAME/.zshrc" "$HOME/" >/dev/null 2>&1 ; then
			printf "%s\n" "${OK} .zshrc copied successfuly!"
		else
			cp -r "$CONFIGS_DIR/$CONF_NAME/.zshrc" "$HOME/" 2>>"$LOG"
			printf "%s\n" "${ERROR} Failed to copy .zshrc :( Check $LOG"
		fi
	else
		if cp -r "$CONFIGS_DIR/$CONF_NAME" "$BASE_CONFIG_DIR/$CONF_NAME" >/dev/null 2>&1 ; then
			printf "%s\n" "${OK} $CONF_NAME copied successfuly!"
		else
			cp -r "$CONFIGS_DIR/$CONF_NAME" "$BASE_CONFIG_DIR/" 2>>"$LOG"
			printf "%s\n" "${ERROR} Failed to copy $CONF_NAME :( Check $LOG"
		fi
	fi
done



