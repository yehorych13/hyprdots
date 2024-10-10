#!/bin/bash

# This scripts was made by https://github.com/yehorych13

# Check if running as root. If root, script will exit
if [[ $EUID -eq 0 ]]; then
    echo "This script should not be executed as root! Exiting......."
    exit 1
fi

clear

# --------------- VARIABLES ---------------

# Determine the directory where the script is located
# And change (just in case) the working directory to the parent dir
PARENT_DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
cd $PARENT_DIR

# Determine other directories
BASE_CONFIG_DIR="$HOME/.config"
SCRIPTS_DIR="$PARENT_DIR/scripts"
CONFIGS_DIR="$PARENT_DIR/configs"
WALLPAPERS_DIR="$PARENT_DIR/wallpapers"
LOGS_DIR="$PARENT_DIR/Logs"

# Determine back up dir variable
BACKUP_DIR="$HOME/.config/backup_$(date "+%Y-%m-%d_%H-%M-%S")"

# Create dir for logs and ~/.config if it dosen't exist
mkdir -p "$LOGS_DIR"
mkdir -p "$BASE_CONFIG_DIR"

# Determine variable for .log file
LOG="$(basename $LOGS_DIR)/install-$(date "+%Y-%m-%d_%H-%M-%S").log"

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
NOTE="${YELLOW}[NOTE]${RESET}"
ACTION="${BLUE}[ACTION]${RESET}"
WARN="${ORANGE}[WARNING]${RESET}"
ATTENTION="${YELLOW}[ATTENTION]${RESET}"

# --------------- FUNCTIONS ---------------
colorize_msg(){
	local color="$1"
	local msg="$2"
	printf "${color}${msg}${RESET}"
}

execute_script(){
	local script="$1"
	local script_path="$SCRIPTS_DIR/$script"
	if [ -f "$script_path" ]; then
		chmod +x "$script_path"
		if [ -x "$script_path" ]; then
			"$script_path"
		else
			echo "Failed to make script '$script' executable."
		fi
	else
		echo "Script '$script' not found in '$SCRIPTS_DIR'."
	fi
}

# --------------- MAIN SCRIPT ---------------

# ====== BACKING UP START ======

# Check if symlinks for configs exist in ~/.config and remove then
# Also if some configs already installed, move them to the backup dir
for CONF in "$CONFIGS_DIR"/* ; do
	CONF_NAME="$(basename $CONF)"

	# Check for symlinks
	if [ -L "$BASE_CONFIG_DIR/$CONF_NAME" ] ; then
		printf "%s" "${NOTE} Symlink for $CONF_NAME found! Removing..."
		if rm -f "$BASE_CONFIG_DIR/$CONF_NAME" >/dev/null 2>&1; then
			printf "\r\e[K%s\n" "${OK} Symlink for $CONF_NAME removed!"
		else
			rm -f "$BASE_CONFIG_DIR/$CONF_PATH" 2>> "$LOG"
			printf "\r\e[K%s\n" "${ERROR} Failed to remove $CONF_NAME symlink :( Check '$LOG'"
		fi
	elif [ -d "$BASE_CONFIG_DIR/$CONF_NAME" ] ; then

		# Create back up dir if it's needed
		mkdir -p "$BACKUP_DIR"
		printf "%s" "${NOTE} Configs for $CONF_NAME found! Trying to backup..."

		if mv "$BASE_CONFIG_DIR/$CONF_NAME" "$BACKUP_DIR/" >/dev/null 2>&1 ; then
			printf "\r\e[K%s\n" "${OK} Config for $CONF_NANE backed up to $BACKUP_DIR"
		else
			mv "$BASE_CONFIG_DIR/$CONF_NAME" "$BACKUP_DIR/" 2>> "$LOG"
			printf "\r\e[K%s\n" "${ERROR} Failed to back up $CONF_NAME :( Check $LOG"
		fi
	fi
done

# The same as previous but for ~/.zshrc
if [ -L "$HOME/.zshrc" ] ; then
	printf "%s" "${NOTE} Symlink for .zshrc found! Removing..."
	if rm -f "$HOME/.zshrc" >/dev/null 2>&1; then
		printf "\r\e[K%s\n" "${OK} Symlink for .zshrc removed!"
	else
		rm -f "$HOME/.zshrc" 2>> "$LOG"
		printf "\r\e[K%s\n" "${ERROR} Failed to remove .zshrc symlink :( Check '$LOG'"
	fi
elif [ -f "$HOME/.zshrc" ] ; then
	# Create back up dir if it's needed
	mkdir -p "$BACKUP_DIR"
	printf "%s" "${NOTE} Found .zshrc file! Trying ot backup..."
	if mv "$HOME/.zshrc" "$BACKUP_DIR/" >/dev/null 2>&1 ; then
		printf "\r\e[K%s\n" "${OK} .zshrc file backed up to $BACKUP_DIR"
	else
		mv "$HOME/.zshrc" "$BACKUP_DIR/" 2>> "$LOG"
		printf "\r\e[K%s\n" "${ERROR} Failed to back up .zshrc :( Check $LOG"
	fi
fi


# printf "\n%.0s" {1..1}

# ====== BACKING UP END ======


# CHOOSE WHAT YOU WANT TO DO WITH CONFIGS
# 1. Symlink them (in that case DO NOT DELETE parent DIR!!!)
# 2. Copy all configs to correct dirs (in that case you can delete parent dir)
while true; do
	printf "%s\n" "$(colorize_msg "$ORANGE" "You have two options what to do with dotfiles:")"
	printf "%s\n" "$(colorize_msg "$YELLOW" "1. Create a symlink for configs(in that case DO NOT DELETE PARENT DIR!!)")"
	printf "%s\n" "$(colorize_msg "$YELLOW" "2. Copy dotfiles(in that case after copying you can delete parent dir)")"
	read -p "${CYAN}Enter a number of your choice: ${RESET}" choice

		case $choice in
		1)
			execute_script "symlink.sh"
			break
			;;
		2)
			execute_script "copy.sh"
			break
			;;
		*)
			echo "Invalid choice. Please enter 1 for symlink or 2 for copy."
			;;
	esac
done


# Copy wallpapers
mkdir -p ~/Pictures/wallpapers
cp -r "$WALLPAPERS_DIR"/* ~/Pictures/wallpapers/ && { echo "${OK} Wallpapers copy completed!"; } || { echo "${ERROR} Failed to copy wallpapers."; exit 1; } 2>&1 | tee -a "$LOG"

printf "%s\n" "${GREEN}DONE!${RESET}"
