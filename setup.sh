#!/bin/bash

# Check if the system is Arch Linux
if ! grep -q "Arch" /etc/os-release; then
    echo "This script is designed for Arch Linux. Exiting..."
    exit 1
fi

# Prompt user for action
echo "Do you want to (1) Rebuild .bashrc or (2) Append and Override to the existing .bashrc? (Default: Rebuild)"
echo "Enter 1 for Rebuild, 2 for Append, or press Enter for default:"
read -r choice

# If no choice is provided, default to append
if [[ -z $choice ]]; then
    choice=1
fi

# Define the custom lines to add or override
custom_lines=(
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

    "# Pacman Shortcuts for Arch Linux"
    'alias sync="sudo pacman -Syyy"'
    'alias install="sudo pacman -S"'
    'alias update="sudo pacman -Syyu | lolcat"'

    "# Cleanup"
    'alias cleanup="sudo pacman -Rns $(pacman -Qdtq)"'
    'alias clean="sudo pacman -Scc --noconfirm"'

    "# Networking "
    'alias myip="curl ifconfig.me"'
    'alias ports="netstat -tulanp"'
    'alias ping="ping -c 5"'
    'alias wget="wget -c"'
    'alias speedtest="curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python -"'

    "# Git "
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

    "# Fun and Creative Additions"
    'alias sayhello="echo \"Hello, $USER! Have a great day ahead!\""'
    'alias weather="curl wttr.in"'

    "# Enhanced Terminal Features"
    'alias neofetch="neofetch"'
    'alias disk-usage="ncdu"'
    'alias tree="tree -C"'

    "# Color Aliases"
    'alias red="echo -e \"\033[31m\""'     # Red
    'alias green="echo -e \"\033[32m\""'   # Green
    'alias yellow="echo -e \"\033[33m\""'  # Yellow
    'alias blue="echo -e \"\033[34m\""'    # Blue
    'alias magenta="echo -e \"\033[35m\""' # Magenta
    'alias cyan="echo -e \"\033[36m\""'    # Cyan
    'alias reset="echo -e \"\033[0m\""'    # Reset to default
    'alias bold="echo -e \"\033[1m\""'     # Bold text
    'alias underline="echo -e \"\033[4m\""' # Underlined text

    "# Extra"
    'alias uptime="uptime -p"'

    "# Display a random quote from the file each time a new terminal session starts"
    'neofetch | lolcat'
    'QUOTE_FILE="$HOME/.Terminal_Quotes"'
    'if [ -f "$QUOTE_FILE" ]; then'
    '    RANDOM_QUOTE=$(shuf -n 1 "$QUOTE_FILE")'
    '    echo -e "\n$RANDOM_QUOTE\n" | lolcat'
    'else'
    '    echo -e "\nNo quote file found! Create $QUOTE_FILE to enjoy random quotes.\n"'
    'fi'
)

if [[ $choice == 1 ]]; then
    # Rebuild mode
    echo "Rebuilding ~/.bashrc..."
    cp ~/.bashrc ~/.bashrc.bak  # Backup existing .bashrc
    echo "# Default .bashrc file" > ~/.bashrc
    echo "export PATH=\$PATH:/usr/local/bin" >> ~/.bashrc
    echo "PS1='[\u@\h \W]\$ '" >> ~/.bashrc
    echo "# Custom Aliases" >> ~/.bashrc

    # Add custom lines
    for line in "${custom_lines[@]}"; do
        echo "$line" >> ~/.bashrc
    done
elif [[ $choice == 2 ]]; then
    # Append and Override mode
    echo "Appending and overriding custom lines in ~/.bashrc..."
    cp ~/.bashrc ~/.bashrc.bak  # Backup existing .bashrc

    # Add or replace custom lines
    for line in "${custom_lines[@]}"; do
        key=$(echo "$line" | awk '{print $2}' | cut -d '=' -f 1)  # Extract alias name
        if grep -q "alias $key=" ~/.bashrc; then
            # If the alias exists, replace it
            sed -i "s|alias $key=.*|$line|" ~/.bashrc
        else
            # If the alias doesn't exist, append it
            echo "$line" >> ~/.bashrc
        fi
    done
else
    echo "Invalid choice. Exiting..."
    exit 1
fi

# Move 'mine' file to hidden .Terminal_Quotes directory if it exists
if [ -f "$HOME/TermiCool/mine" ]; then
    mv "$HOME/TermiCool/mine" "$HOME/.Terminal_Quotes"
fi

# Reload the .bashrc to apply the changes
echo "Reloading ~/.bashrc to apply the changes..."
source ~/.bashrc

# Inform the user
echo "Setup complete! :-)"
echo "You can now use the enhanced commands on your terminal."
echo "Restart the terminal and enjoy... 🤯"
