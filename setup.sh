#!/bin/bash

# Script to customize .bashrc for Arch-based Linux systems

# Function to check if the system is Arch-based
is_arch_based() {
    grep -qi 'ID=arch' /etc/os-release || grep -qi 'ID_LIKE=arch' /etc/os-release
}

# Verify Arch-based system
if ! is_arch_based; then
    echo "❌ This script is designed for Arch-based Linux distributions only. Exiting..."
    exit 1
fi

# Detect package manager
if command -v pamac &> /dev/null; then
    PKG_MGR="pamac install --no-confirm"
elif command -v pacman &> /dev/null; then
    PKG_MGR="sudo pacman -Sy --noconfirm"
else
    echo "❌ No supported package manager (pamac/pacman) found. Exiting..."
    exit 1
fi

# Define required packages
required_pkgs=(
    "lolcat" "neofetch" "ncdu" "htop" "tree" "lm_sensors" "curl" "wget" "git" "net-tools"
    "bat" "exa" "fzf" "tmux" "python" "python-pip" "fortune-mod" "ripgrep" "fd" "unzip"
)
missing_pkgs=()

# Check for missing packages
for pkg in "${required_pkgs[@]}"; do
    if ! pacman -Qi "$pkg" &> /dev/null 2>&1; then
        missing_pkgs+=("$pkg")
    fi
done

# Install missing packages
if [ ${#missing_pkgs[@]} -gt 0 ]; then
    echo "📦 Installing missing packages: ${missing_pkgs[*]}"
    if ! $PKG_MGR "${missing_pkgs[@]}"; then
        echo "❌ Failed to install packages. Exiting..."
        exit 1
    fi
    echo "✅ Packages installed successfully."
else
    echo "✅ All required packages are already installed."
fi

# User choice for .bashrc modification
echo -e "\nChoose an option to customize your .bashrc:"
echo "1) Rebuild .bashrc (recreates with preserved configs + new content)"
echo "2) Append/Override (updates script-managed section only)"
echo "Enter 1 or 2 (default is 2):"
read -r choice
choice=${choice:-2}  # Default to append if empty

# Define custom content
custom_content=(
    "# >>> TermiCool custom content >>>"
    "# Custom Aliases and Functions added by customize_bashrc.sh"

    "## Navigational Aliases"
    'alias ..="cd .."'
    'alias ...="cd ../.."'
    'alias ....="cd ../../.."'
    'alias back="cd -"'
    'alias home="cd ~"'
    'alias root="cd /"'
    'alias docs="cd ~/Documents"'
    'alias dwnld="cd ~/Downloads"'

    "## Package Management (Pacman)"
    'alias sync="sudo pacman -Sy"'
    'alias install="sudo pacman -S"'
    'alias update="sudo pacman -Syu"'
    'alias cleanup="sudo pacman -Rns $(pacman -Qdtq)"'
    'alias clean="sudo pacman -Scc --noconfirm"'

    "## Networking Tools"
    'alias myip="curl ifconfig.me"'
    'alias ports="netstat -tulanp"'
    'alias ping="ping -c 5"'
    'alias wget="wget -c"'
    'alias speedtest="curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python -"'

    "## Git Shortcuts"
    'alias gs="git status"'
    'alias ga="git add"'
    'alias gc="git commit"'
    'alias gp="git push"'
    'alias gl="git log --oneline --graph --decorate"'
    'alias gco="git checkout"'
    'alias gbr="git branch"'
    'alias gpull="git pull"'
    'alias gclone="git clone"'

    "## System Monitoring"
    'alias usage="df -h"'
    'alias mem="free -h"'
    'alias top="htop"'
    'alias psx="ps aux --sort=-%mem | head"'
    'alias temps="sensors"'

    "## File Management"
    'alias ll="exa -lah --color=always"  # Enhanced ls with exa'
    'alias mkdir="mkdir -p"'
    'alias rm="rm -i"'
    'alias cp="cp -iv"'
    'alias mv="mv -iv"'
    'alias duh="du -h --max-depth=1"'

    "## Text Editing and Viewing"
    'alias nano="nano -c"'
    'alias vim="vim -p"'
    'alias cat="bat --paging=never"  # Use bat instead of cat'

    "## Search and Find"
    'alias grep="rg --color=auto"  # Use ripgrep instead of grep'
    'alias findfile="fd"'
    'alias ftext="rg -r"'

    "## System Utilities"
    'alias reboot="sudo reboot"'
    'alias shutdown="sudo poweroff"'
    'alias uptime="uptime -p"'

    "## Python Virtual Environments"
    'mkvenv() {'
    '    python -m venv "$1" && source "$1/bin/activate" && echo "Virtual environment \'$1\' created and activated."'
    '}'
    'actvenv() {'
    '    if [ -d "$1" ]; then source "$1/bin/activate"; else echo "Directory \'$1\' not found."; fi'
    '}'
    'deactvenv() {'
    '    deactivate'
    '}'

    "## Custom Functions"
    'mkcd() {'
    '’av mkdir -p "$1" && cd "$1"'
    '}'
    'extract() {'
    '    if [ -f "$1" ]; then'
    '        case "$1" in'
    '            *.tar.gz) tar xzf "$1" ;;'
    '            *.zip) unzip "$1" ;;'
    '            *.tar) tar xf "$1" ;;'
    '            *) echo "Unsupported format: $1" ;;'
    '        esac'
    '    else'
    '        echo "File not found: $1"'
    '    fi'
    '}'

    "## Fun and Creative"
    'alias sayhello="echo \"Hello, \$USER! Have a great day!\" | lolcat"'
    'alias weather="curl wttr.in"'
    'alias cowsay="cowsay Hello, \$USER!"'
    'alias starwars="telnet towel.blinkenlights.nl"'

    "## History Enhancements"
    'alias h="history | tail -n 20"'
    'export HISTCONTROL=ignoredups:erasedups'
    'export HISTSIZE=10000'
    'export HISTFILESIZE=20000'

    "## Prompt Customization (uncomment to use)"
    '# PS1="\[\e[32m\]\u@\h \[\e[33m\]\w\[\e[0m\] \$ "  # Green user@host, yellow dir'

    "## Startup Features (interactive shells only)"
    'if [[ $- == *i* ]]; then'
    '    neofetch | lolcat'
    '    if command -v fortune &> /dev/null; then'
    '        fortune | lolcat'
    '    fi'
    '    if [ -f "$HOME/.Terminal_Quotes/quotes" ]; then'
    '        RANDOM_QUOTE=$(shuf -n 1 "$HOME/.Terminal_Quotes/quotes")'
    '        echo -e "\n$RANDOM_QUOTE\n" | lolcat'
    '    else'
    '        echo -e "\nCreate $HOME/.Terminal_Quotes/quotes for random quotes!\n" | lolcat'
    '    fi'
    'fi'

    "# <<< TermiCool custom content <<<"
)

# Backup .bashrc
backup_file="$HOME/.bashrc.bak-$(date +%Y%m%d%H%M%S)"
if [ -f "$HOME/.bashrc" ]; then
    cp "$HOME/.bashrc" "$backup_file"
    echo "✅ Backup created: $backup_file"
else
    echo "# Initial .bashrc created by customize_bashrc.sh" > "$HOME/.bashrc"
    echo "⚠️ No existing .bashrc found. Created a new one."
fi

# Process user choice
if [[ "$choice" == "1" ]]; then
    echo "🔄 Rebuilding .bashrc..."
    {
        # Preserve critical configs
        grep -P '^export (PATH|EDITOR|VISUAL|HIST\w+|PAGER|LANG)=' "$backup_file" 2>/dev/null || true
        grep -P '^PS1=' "$backup_file" 2>/dev/null || true
        grep -P '^shopt ' "$backup_file" 2>/dev/null || true

        # Add custom content
        printf "%s\n" "${custom_content[@]}"
    } > "$HOME/.bashrc.tmp"

    mv "$HOME/.bashrc.tmp" "$HOME/.bashrc"
    echo "✅ .bashrc rebuilt successfully."

elif [[ "$choice" == "2" ]]; then
    echo "🔧 Updating .bashrc (append/override mode)..."
    # Remove existing custom content section
    sed -i '/# >>> TermiCool custom content >>>/,/# <<< TermiCool custom content <<</d' "$HOME/.bashrc"
    # Append new custom content
    printf "%s\n" "${custom_content[@]}" >> "$HOME/.bashrc"
    echo "✅ .bashrc updated successfully."

else
    echo "❌ Invalid choice. Exiting..."
    exit 1
fi

# Handle quote file migration
if [ -f "$HOME/TermiCool/mine" ]; then
    mkdir -p "$HOME/.Terminal_Quotes"
    mv "$HOME/TermiCool/mine" "$HOME/.Terminal_Quotes/quotes"
    echo "📜 Moved quote file to $HOME/.Terminal_Quotes/quotes"
fi

# Syntax check
if ! bash -n "$HOME/.bashrc"; then
    echo "❌ Syntax error in .bashrc. Restoring backup..."
    mv "$backup_file" "$HOME/.bashrc"
    exit 1
fi

# Reload .bashrc
echo "♻️ Reloading .bashrc..."
source "$HOME/.bashrc"

echo "🎉 Customization completed successfully! Enjoy your enhanced terminal!"
