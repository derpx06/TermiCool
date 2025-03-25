#!/bin/bash

# Enable debugging (comment out if not needed)
# set -x

# Check if the system is Arch Linux
if ! grep -q "Arch" /etc/os-release; then
    echo "This script is designed for Arch Linux. Exiting..."
    exit 1
fi

# Check for required packages and install if missing
required_pkgs=("lolcat" "neofetch" "ncdu" "htop" "tree" "lm_sensors" "curl" "wget" "git" "net-tools")
missing_pkgs=()

for pkg in "${required_pkgs[@]}"; do
    if ! pacman -Qi "$pkg" &> /dev/null; then
        missing_pkgs+=("$pkg")
    fi
done

if [ ${#missing_pkgs[@]} -gt 0 ]; then
    echo "Installing missing packages: ${missing_pkgs[*]}"
    sudo pacman -Sy --noconfirm "${missing_pkgs[@]}" || {
        echo "Failed to install packages. Exiting..."
        exit 1
    }
fi

# Prompt user for action
echo "Do you want to (1) Rebuild .bashrc or (2) Append and Override to the existing .bashrc? (Default: Append)"
echo "Enter 1 for Rebuild, 2 for Append, or press Enter for default:"
read -r choice

# Default to append if no choice
if [[ -z $choice ]]; then
    choice=2
fi

# Define custom configuration elements
custom_content=(
    "# Custom Aliases and Functions"

    "# Display ISO version and distribution information in short"
    'alias version="sed -n 1p /etc/os-release && sed -n 12p /etc/os-release && sed -n 13p /etc/os-release"'

    "# Navigational "
    'alias ..="cd .."'
    'alias ...="cd ../.."'
    'alias ....="cd ../../.."'
    'alias back="cd -"'
    'alias home="cd ~"'
    'alias root="cd /"'
    'alias docs="cd ~/Documents"'
    'alias dwnld="cd ~/Downloads"'

    "# Pacman Shortcuts"
    'alias sync="sudo pacman -Sy"'
    'alias install="sudo pacman -S"'
    'alias update="sudo pacman -Syu | lolcat"'

    "# Cleanup"
    'alias cleanup="sudo pacman -Rns $(pacman -Qdtq)"'
    'alias clean="sudo pacman -Scc --noconfirm"'

    "# Networking"
    'alias myip="curl ifconfig.me"'
    'alias ports="netstat -tulanp"'
    'alias ping="ping -c 5"'
    'alias wget="wget -c"'
    'alias speedtest="curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python -"'

    "# Git"
    'alias gs="git status"'
    'alias ga="git add"'
    'alias gc="git commit"'
    'alias gp="git push"'
    'alias gl="git log --oneline --graph --decorate"'
    'alias gco="git checkout"'
    'alias gbr="git branch"'
    'alias gpull="git pull"'
    'alias gclone="git clone"'

    "# System Monitoring"
    'alias usage="df -h"'
    'alias mem="free -h"'
    'alias top="htop"'
    'alias psx="ps aux --sort=-%mem | head"'
    'alias temps="sensors"'

    "# Fun and Creative"
    'alias sayhello="echo \"Hello, \$USER! Have a great day!\""'
    'alias weather="curl wttr.in"'
    'alias cowsay="cowsay Hello, \$USER!"'

    "# Enhanced Features"
    'alias neofetch="neofetch"'
    'alias disk-usage="ncdu"'
    'alias tree="tree -C"'

    "# Terminal Colors"
    'alias red="echo -e \"\033[31m\""'
    'alias green="echo -e \"\033[32m\""'
    'alias yellow="echo -e \"\033[33m\""'
    'alias blue="echo -e \"\033[34m\""'
    'alias magenta="echo -e \"\033[35m\""'
    'alias cyan="echo -e \"\033[36m\""'
    'alias reset="echo -e \"\033[0m\""'
    'alias bold="echo -e \"\033[1m\""'
    'alias underline="echo -e \"\033[4m\""'

    "# Utility"
    'alias uptime="uptime -p"'

    "# Startup Features"
    'neofetch | lolcat'
    'QUOTE_FILE="$HOME/.Terminal_Quotes/quotes"'
    'if [ -f "$QUOTE_FILE" ]; then'
    '    RANDOM_QUOTE=$(shuf -n 1 "$QUOTE_FILE")'
    '    echo -e "\n$RANDOM_QUOTE\n" | lolcat'
    'else'
    '    echo -e "\nCreate $QUOTE_FILE for random quotes!\n"'
    'fi'
)

# Backup original .bashrc
backup_file="$HOME/.bashrc.bak-$(date +%Y%m%d%H%M%S)"
cp "$HOME/.bashrc" "$backup_file"
echo "Backup created: $backup_file"

if [[ $choice == 1 ]]; then
    # Rebuild mode: Merge existing critical configs with new content
    echo "Rebuilding ~/.bashrc..."
    
    # Preserve critical existing configurations
    {
        # Keep original environment exports and PS1
        grep -P '^export (PATH|EDITOR|VISUAL|HIST\w+|PAGER|LANG)=' "$backup_file"
        grep -P '^PS1=' "$backup_file"
        grep -P '^shopt ' "$backup_file"
        grep -P '^# (EXP|alias|fun)' "$backup_file"  # Keep original comments
        
        # Add custom content
        printf "%s\n" "${custom_content[@]}"
        
        # Keep existing functions and personalizations
        grep -P '^(function|alias|#|\[ -f )' "$backup_file" | grep -Fvx "${custom_content[@]}"
        
    } > "$HOME/.bashrc.tmp"
    
    # Replace original .bashrc
    mv "$HOME/.bashrc.tmp" "$HOME/.bashrc"

elif [[ $choice == 2 ]]; then
    # Append mode: Add new content and update existing entries
    echo "Appending custom configurations..."
    
    # Temporary file for processing
    tmp_file="$HOME/.bashrc.tmp"
    cp "$HOME/.bashrc" "$tmp_file"
    
    # Process each custom line
    for line in "${custom_content[@]}"; do
        # Handle aliases
        if [[ $line == alias* ]]; then
            alias_name=$(echo "$line" | sed -E 's/alias ([^=]*)=.*/\1/')
            
            # Check if alias exists
            if grep -q "alias $alias_name=" "$tmp_file"; then
                # Replace existing alias
                sed -i "/alias $alias_name=/c\\$line" "$tmp_file"
            else
                # Append new alias
                echo "$line" >> "$tmp_file"
            fi
        
        # Handle code blocks
        else
            # Check if the exact line exists
            if ! grep -Fqx "$line" "$tmp_file"; then
                echo "$line" >> "$tmp_file"
            fi
        fi
    done
    
    # Replace original .bashrc
    mv "$tmp_file" "$HOME/.bashrc"

else
    echo "Invalid choice. Exiting..."
    exit 1
fi

# Handle quote file
if [ -f "$HOME/TermiCool/mine" ]; then
    mkdir -p "$HOME/.Terminal_Quotes"
    mv "$HOME/TermiCool/mine" "$HOME/.Terminal_Quotes/quotes"
fi

# Syntax check before reloading
if ! bash -n "$HOME/.bashrc"; then
    echo "Error in .bashrc syntax. Restoring backup..."
    mv "$backup_file" "$HOME/.bashrc"
    exit 1
fi

# Reload .bashrc
echo "Reloading .bashrc..."
source "$HOME/.bashrc"

echo "Setup completed successfully!"
