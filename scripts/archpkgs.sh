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
LOG="$(basename $LOGS_DIR)/archpkgs-$(date "+%Y-%m-%d_%H-%M-%S").log"

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

# Installing basic packages and yay
sudo pacman -S --needed git base-devel || { echo "${ERROR} Failed to install base packages"; exit 1; }
git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si || { echo "${ERROR} Failed to install yay"; exit 1; }
cd .. && rm -rf yay

# Installing all packages
yay -S $(awk '{print $1}' pkgs.txt) || { echo "${ERROR} Failed to install packages from pkgs.txt"; exit 1; }

# Adding user to groups
for group in input video; do
    sudo usermod -aG "$group" yehorych || { echo "${ERROR} Failed to add yehorych to group $group"; exit 1; }
done

# Change shell to zsh
chsh -s $(which zsh) || { echo "${ERROR} Failed to change shell"; exit 1; }

# oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || { echo "${ERROR} Failed to install oh-my-zsh"; exit 1; }

# Zsh plugins
git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"

# Enable services
systemctl --user enable pipewire wireplumber
systemctl --user enable xdg-desktop-portal-hyprland
sudo systemctl enable sddm || { echo "${ERROR} Failed to enable sddm"; exit 1; }

# Install configs
"$PARENT_DIR/install.sh" || { echo "${ERROR} Failed to run install.sh"; exit 1; }

printf "%s\n" "${NOTE} Please reboot system"
