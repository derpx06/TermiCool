#!/bin/bash

# Check if the system is Arch Linux
if ! grep -q "Arch" /etc/os-release; then
    echo "This script is designed for Arch Linux. Exiting..."
    exit 1
fi

# Ask the user if they want to rebuild or append the .bashrc
echo "Do you want to (1) Rebuild .bashrc or (2) Append to the existing .bashrc?"
echo "Enter 1 for Rebuild, 2 for Append:"
read -r choice

# Define the custom lines you want to add to .bashrc
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
    
    "# Keys alias displaying all Shortcuts"
    'alias keys="echo -e \"Navigational Shortcuts:\\n.., ..., ...., back, home, root, docs, dwnld\\n\\nPacman Shortcuts:\\nsync, install, update\\n\\nCleanup Tasks:\\ncleanup, clean\\n\\nNetworking shortcuts:\\nmyip, ports, ping, wget, speedtest\\n\\nGit Aliases:\\ngs, ga, gc, gp, gl, gco, gbr, gpull, gclone\\n\\nSystem Monitoring Shortcuts:\\nusage, mem, top, psx, temps\\n\\nDevelopment and Coding Aliases:\\ncls, pyserve, c, cxx, jvbuild, jvexec\\n\\nHandy Shortcuts:\\ntoday, timestamp, reload\\n\\nSystem Actions:\\nshutdown, reboot\\n\\nEnhanced Terminal Features:\\nneofetch, disk-usage, tree\\n\\nFun and Creative Additions:\\nsayhello, weather\\n\\nExtra Shortcut:\\nuptime\""'

    "# System Monitoring"
    'alias usage="df -h"'
    'alias mem="free -h"'
    'alias top="htop"'
    'alias psx="ps aux --sort=-%mem | head"'
    'alias temps="sensors"'

    "# Development and Coding"
    'alias cls="clear"'
    'alias pyserve="python -m http.server 8000"'
    'alias c="gcc -Wall -o"'
    'alias cxx="g++ -std=c++17 -o"'
    'alias jvbuild="javac"'
    'alias jvexec="java"'

    "# Motivational and Handy "
    'alias today="date +\"%A, %B %d, %Y\""'
    'alias timestamp="date +\"%Y-%m-%d %H:%M:%S\""'
    'alias reload="source ~/.bashrc"'

    "# System Actions"
    'alias shutdown="sudo shutdown now"'
    'alias reboot="sudo reboot"'

    "# Timeout for Inactive Shells"
    'export TMOUT=2000  # Auto-logout after 2000 seconds of inactivity'

    "# Enhanced Terminal Features"
    'alias neofetch="neofetch"'
    'alias disk-usage="ncdu"'
    'alias tree="tree -C"'

    "# Fun and Creative Additions"
    'alias sayhello="echo \"Hello, $USER! Have a great day ahead!\""'
    'alias weather="curl wttr.in"'

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
    # Backup existing .bashrc
    echo "Creating a backup of the existing ~/.bashrc as ~/.bashrc.bak..."
    cp ~/.bashrc ~/.bashrc.bak

    # Create a fresh .bashrc file with default content
    echo "# Default .bashrc file" > ~/.bashrc
    echo "export PATH=\$PATH:/usr/local/bin" >> ~/.bashrc
    echo "PS1='[\u@\h \W]\$ '" >> ~/.bashrc
    echo "# Custom Aliases" >> ~/.bashrc

    # Add custom lines
    for line in "${custom_lines[@]}"; do
        echo "$line" >> ~/.bashrc
    done
elif [[ $choice == 2 ]]; then
    echo "Appending custom lines to the existing ~/.bashrc..."
    # Backup existing .bashrc
    cp ~/.bashrc ~/.bashrc.backup

    # Add lines if they do not already exist
    for line in "${custom_lines[@]}"; do
        if ! grep -Fxq "$line" ~/.bashrc; then
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
