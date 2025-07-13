#!/bin/bash

# Enhanced script to customize .bashrc for Arch-based Linux systems
# Packed with developer tools, system utilities, and visual enhancements

# Enable strict error handling
set -euo pipefail

# Function to log messages with timestamp
log_message() {
    local color=$1
    local symbol=$2
    shift 2
    echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] \033[${color}m${symbol} $@\033[0m" | tee -a /tmp/bashrc_setup.log
}

# Function to check if the system is Arch-based
is_arch_based() {
    grep -qi 'ID=arch' /etc/os-release || grep -qi 'ID_LIKE=arch' /etc/os-release
}

# Verify Arch-based system
if ! is_arch_based; then
    log_message "31" "❌" "This script is designed for Arch-based Linux distributions only. Exiting..."
    exit 1
fi

# Detect package manager
if command -v pamac &> /dev/null; then
    PKG_MGR="pamac install --no-confirm"
    PKG_CHECK="pamac list --installed"
    PKG_AUR="pamac build --no-confirm"
elif command -v pacman &> /dev/null; then
    PKG_MGR="sudo pacman -Sy --noconfirm"
    PKG_CHECK="pacman -Qi"
    PKG_AUR="sudo pacman -S --noconfirm"
else
    log_message "31" "❌" "No supported package manager (pamac/pacman) found. Exiting..."
    exit 1
fi

# Define required and optional packages
required_pkgs=(
    "lolcat" "neofetch" "ncdu" "htop" "tree" "lm_sensors" "curl" "wget" "git" "net-tools"
    "bat" "exa" "fzf" "tmux" "python" "python-pip" "fortune-mod" "ripgrep" "fd" "unzip"
    "bash-completion" "figlet" "toilet" "zoxide" "jq" "shellcheck"
)
optional_pkgs=(
    "docker" "kubectl" "nodejs" "npm" "python-black" "python-pylint"
    "go" "rust" "openjdk17-jdk" "ruby" "aws-cli" "google-cloud-sdk" "terraform"
    "postgresql" "mysql" "starship" "yay"  # yay for AUR packages
)

# Function to install packages with retry and logging
install_packages() {
    local pkg_list=("$@")
    local missing_pkgs=()
    local retries=3
    local attempt=1

    log_message "34" "🔍" "Checking for missing packages..."

    for pkg in "${pkg_list[@]}"; do
        if ! $PKG_CHECK "$pkg" &> /dev/null 2>&1; then
            missing_pkgs+=("$pkg")
            log_message "33" "⚠️" "Package $pkg is missing."
        else
            log_message "32" "✅" "Package $pkg is already installed."
        fi
    done

    if [ ${#missing_pkgs[@]} -gt 0 ]; then
        log_message "34" "📦" "Installing missing packages: ${missing_pkgs[*]}"
        while [ $attempt -le $retries ]; do
            log_message "34" "🔄" "Attempt $attempt/$retries to install packages..."
            if $PKG_MGR "${missing_pkgs[@]}" 2>&1 | tee -a /tmp/pkg_install.log; then
                log_message "32" "✅" "Packages installed successfully."
                return 0
            else
                log_message "31" "❌" "Attempt $attempt/$retries failed. Check /tmp/pkg_install.log."
                ((attempt++))
                sleep 3
            fi
        done
        log_message "31" "❌" "Failed to install packages after $retries attempts. Exiting..."
        exit 1
    else
        log_message "32" "✅" "All required packages are already installed."
    fi
}

# Install required packages
install_packages "${required_pkgs[@]}"

# Ask for optional packages
log_message "34" "❓" "Install optional developer/system tools (${optional_pkgs[*]})? [y/N]"
read -r install_optional
if [[ "$install_optional" =~ ^[Yy]$ ]]; then
    # Check for AUR helper (yay) for starship and other AUR packages
    if [[ " ${optional_pkgs[*]} " =~ " yay " ]] && ! command -v yay &> /dev/null; then
        log_message "34" "📦" "Installing yay (AUR helper)..."
        git clone https://aur.archlinux.org/yay.git /tmp/yay
        cd /tmp/yay
        makepkg -si --noconfirm || {
            log_message "31" "❌" "Failed to install yay. Continuing without AUR packages..."
        }
        cd -
    fi
    install_packages "${optional_pkgs[@]}"
fi

# Interactive menu for .bashrc modification
log_message "34" "🛠️" "Choose an option to customize your .bashrc:"
echo "  1) Rebuild .bashrc (recreates with preserved configs + new content)"
echo "  2) Append/Override (updates script-managed section only)"
echo "  3) Preview customizations (dry run, no changes)"
echo -n "Enter 1, 2, or 3 (default is 2): "
read -r choice
choice=${choice:-2}

# Define custom content
custom_content=(
    "# >>> TermiCool Ultimate Configuration >>>"
    "# Enhanced aliases, functions, and settings for developers and system admins"

    "## Environment Setup"
    'export HISTCONTROL=ignoredups:erasedups'
    'export HISTSIZE=10000'
    'export HISTFILESIZE=20000'
    'export EDITOR=nano'
    'export VISUAL=nano'
    'export GOPATH="$HOME/go"'
    'export PATH="$PATH:$GOPATH/bin:/usr/local/go/bin:$HOME/.cargo/bin:$HOME/.local/bin"'

    "## Prompt Customization (dynamic with Git branch)"
    'parse_git_branch() {'
    '    git branch 2>/dev/null | sed -e "/^[^*]/d" -e "s/* \(.*\)/ (\1)/"'
    '}'
    'PS1="\[\e[32;1m\]\u@\h\[\e[0m\] \[\e[33;1m\]\w\[\e[35;1m\]\$(parse_git_branch)\[\e[0m\] \$ "'
    'if command -v starship &> /dev/null; then'
    '    eval "$(starship init bash)"'
    'fi'

    "## Prompt Theme Toggle"
    'prompt_toggle() {'
    '    case "$1" in'
    '        simple) PS1="\[\e[32m\]\u@\h \[\e[33m\]\w\[\e[0m\] \$ " ;;'
    '        git) PS1="\[\e[32;1m\]\u@\h\[\e[0m\] \[\e[33;1m\]\w\[\e[35;1m\]\$(parse_git_branch)\[\e[0m\] \$ " ;;'
    '        minimal) PS1="\[\e[34m\]\w\[\e[0m\] \$ " ;;'
    '        *) echo "Usage: prompt_toggle {simple|git|minimal}" ;;'
    '    esac'
    '}'

    "## Navigational Aliases"
    'alias ..="cd .."'
    'alias ...="cd ../.."'
    'alias ....="cd ../../.."'
    'alias back="cd -"'
    'alias home="cd ~"'
    'alias root="cd /"'
    'alias docs="cd ~/Documents"'
    'alias dwnld="cd ~/Downloads"'
    'if command -v zoxide &> /dev/null; then'
    '    eval "$(zoxide init bash)"'
    '    alias cd="z"'
    'fi'

    "## Package Management"
    'alias sync="sudo pacman -Sy"'
    'alias install="sudo pacman -S"'
    'alias update="sudo pacman -Syu"'
    'alias cleanup="sudo pacman -Rns $(pacman -Qdtq)"'
    'alias clean="sudo pacman -Scc --noconfirm"'
    'alias pkginfo="pacman -Si"'
    'alias aur="yay -S"'

    "## File Management"
    'alias ll="exa -lah --color=always --group-directories-first"'
    'alias ls="exa --color=always"'
    'alias mkdir="mkdir -p"'
    'alias rm="rm -i"'
    'alias cp="cp -iv"'
    'alias mv="mv -iv"'
    'alias duh="du -h --max-depth=1"'
    'alias findlarge="find . -type f -size +100M"'

    "## Text Editing and Viewing"
    'alias nano="nano -c"'
    'alias vim="vim -p"'
    'alias cat="bat --paging=never"'
    'alias less="less -R"'
    'alias json="jq ."'  # Pretty-print JSON

    "## Search and Find"
    'alias grep="rg --color=auto"'
    'alias findfile="fd"'
    'alias ftext="rg -r"'
    'alias fuzzy="fzf --preview \"bat --color=always {}\""'

    "## System Monitoring and Maintenance"
    'alias usage="df -h"'
    'alias mem="free -h"'
    'alias top="htop"'
    'alias psx="ps aux --sort=-%mem | head"'
    'alias temps="sensors"'
    'alias logs="sudo journalctl -p 3 -xb"'
    'alias services="systemctl list-units --type=service"'
    'alias sysinfo="inxi -Fxxxz"'

    "## Networking"
    'alias myip="curl ifconfig.me"'
    'alias ports="netstat -tulanp"'
    'alias ping="ping -c 5"'
    'alias wget="wget -c"'
    'alias speedtest="curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python -"'
    'alias nmap="nmap -sP"'

    "## Git Shortcuts"
    'alias gs="git status"'
    'alias ga="git add"'
    'alias gc="git commit -m"'
    'alias gp="git push"'
    'alias gl="git log --oneline --graph --decorate"'
    'alias gco="git checkout"'
    'alias gbr="git branch"'
    'alias gpull="git pull"'
    'alias gclone="git clone"'
    'alias gdiff="git diff"'
    'alias gst="git stash"'
    'alias gsp="git stash pop"'
    'alias grebase="git rebase"'
    'alias gundo="git reset HEAD^"'

    "## Python Development"
    'alias pipup="pip install --upgrade pip"'
    'alias pyfmt="black ."'
    'alias pylint="pylint --rcfile ~/.pylintrc"'
    'mkvenv() {'
    '    if [ -z "$1" ]; then echo "Usage: mkvenv <env_name>"; return 1; fi'
    '    python -m venv "$1" && source "$1/bin/activate" && pip install --upgrade pip black pylint'
    '    echo "Virtual environment \'$1\' created and activated."'
    '}'
    'actvenv() {'
    '    if [ -z "$1" ]; then echo "Usage: actvenv <env_path>"; return 1; fi'
    '    if [ -d "$1" ]; then source "$1/bin/activate"; else echo "Directory \'$1\' not found."; fi'
    '}'
    'deactvenv() {'
    '    deactivate 2>/dev/null || echo "No active virtual environment."'
    '}'

    "## Go Development"
    'alias gob="go build"'
    'alias gor="go run"'
    'alias got="go test"'
    'alias gofmt="go fmt"'

    "## Rust Development"
    'alias cr="cargo run"'
    'alias cb="cargo build"'
    'alias ct="cargo test"'
    'alias cfmt="cargo fmt"'

    "## Java Development"
    'alias javac="javac -Xlint"'
    'alias java="java -ea"'

    "## Ruby Development"
    'alias rb="ruby"'
    'alias gemup="gem update --system"'

    "## Cloud Tools"
    'alias awsls="aws s3 ls"'
    'alias awscfg="aws configure"'
    'alias gcloud="gcloud"'
    'alias tf="terraform"'
    'alias tfinit="terraform init"'
    'alias tfplan="terraform plan"'
    'alias tfapply="terraform apply"'

    "## Database Management"
    'alias psqlstart="sudo systemctl start postgresql"'
    'alias psqlstop="sudo systemctl stop postgresql"'
    'alias mysqlstart="sudo systemctl start mysqld"'
    'alias mysqlstop="sudo systemctl stop mysqld"'

    "## Docker Shortcuts"
    'alias dkr="docker"'
    'alias dkps="docker ps -a"'
    'alias dkimg="docker images"'
    'alias dkclean="docker system prune -f"'
    'alias dkbuild="docker build -t"'

    "## Kubernetes Shortcuts"
    'alias k="kubectl"'
    'alias kctx="kubectx"'
    'alias kns="kubens"'

    "## Node.js Shortcuts"
    'alias nr="npm run"'
    'alias ni="npm install"'
    'alias nstart="npm start"'
    'alias ntest="npm test"'

    "## Custom Functions"
    'mkcd() {'
    '    mkdir -p "$1" && cd "$1"'
    '}'
    'extract() {'
    '    if [ -f "$1" ]; then'
    '        case "$1" in'
    '            *.tar.gz) tar xzf "$1" ;;'
    '            *.tar) tar xf "$1" ;;'
    '            *.zip) unzip "$1" ;;'
    '            *.rar) unrar x "$1" 2>/dev/null || echo "Install unrar for .rar support" ;;'
    '            *) echo "Unsupported format: $1" ;;'
    '        esac'
    '    else'
    '        echo "File not found: $1"'
    '    fi'
    '}'
    'newproj() {'
    '    if [ -z "$1" ]; then echo "Usage: newproj <project_name> [python|go|rust|node]"; return 1; fi'
    '    mkdir -p "$1" && cd "$1" && git init && echo "# $1" > README.md'
    '    case "$2" in'
    '        python) mkvenv venv && touch main.py ;;'
    '        go) go mod init "$1" && touch main.go ;;'
    '        rust) cargo init && touch src/main.rs ;;'
    '        node) npm init -y && touch index.js ;;'
    '        *) echo "Basic project created." ;;'
    '    esac'
    '    echo "Created $2 project: $1"'
    '}'

    "## Fun and Creative"
    'alias sayhello="echo \"Hello, \$USER! Welcome to your ultimate terminal!\" | lolcat"'
    'alias weather="curl wttr.in"'
    'alias cowsay="cowsay -f tux Hello, \$USER! | lolcat"'
    'alias starwars="telnet towel.blinkenlights.nl"'
    'alias banner="figlet -f big \$USER | lolcat"'
    'alias fortune="fortune | lolcat"'

    "## Help Command"
    'termicool_help() {'
    '    echo "TermiCool Commands:"'
    '    echo "Navigational: .., ..., ...., back, home, root, docs, dwnld, cd (zoxide)"'
    '    echo "Package: sync, install, update, cleanup, clean, pkginfo, aur"'
    '    echo "Files: ll, ls, mkdir, rm, cp, mv, duh, findlarge, extract"'
    '    echo "Text: nano, vim, cat, less, json, grep, findfile, ftext, fuzzy"'
    '    echo "System: usage, mem, top, psx, temps, logs, services, sysinfo"'
    '    echo "Network: myip, ports, ping, wget, speedtest, nmap"'
    '    echo "Git: gs, ga, gc, gp, gl, gco, gbr, gpull, gclone, gdiff, gst, gsp, grebase, gundo"'
    '    echo "Python: pipup, pyfmt, pylint, mkvenv, actvenv, deactvenv"'
    '    echo "Go: gob, gor, got, gofmt"'
    '    echo "Rust: cr, cb, ct, cfmt"'
    '    echo "Java: javac, java"'
    '    echo "Ruby: rb, gemup"'
    '    echo "Cloud: awsls, awscfg, gcloud, tf, tfinit, tfplan, tfapply"'
    '    echo "Database: psqlstart, psqlstop, mysqlstart, mysqlstop"'
    '    echo "Docker: dkr, dkps, dkimg, dkclean, dkbuild"'
    '    echo "Kubernetes: k, kctx, kns"'
    '    echo "Node.js: nr, ni, nstart, ntest"'
    '    echo "Functions: mkcd, extract, newproj, prompt_toggle, termicool_help"'
    '    echo "Fun: sayhello, weather, cowsay, starwars, banner, fortune"'
    '    echo "Run \`prompt_toggle {simple|git|minimal}\` to change prompt style"'
    '}'

    "## Auto-completion"
    '[ -f /usr/share/bash-completion/bash_completion ] && . /usr/share/bash-completion/bash_completion'

    "## Startup Features (interactive shells only)"
    'if [[ $- == *i* ]]; then'
    '    toilet -f term -F border --gay "Welcome, $USER!" | lolcat'
    '    neofetch --colors 2 3 4 5 6 7 | lolcat'
    '    if command -v fortune &> /dev/null; then'
    '        fortune | lolcat'
    '    fi'
    '    if [ -f "$HOME/.Terminal_Quotes/quotes" ]; then'
    '        RANDOM_QUOTE=$(shuf -n 1 "$HOME/.Terminal_Quotes/quotes")'
    '        echo -e "\n$RANDOM_QUOTE\n" | lolcat'
    '    else'
    '        echo -e "\nCreate $HOME/.Terminal_Quotes/quotes for random quotes!\n" | lolcat'
    '    fi'
    '    termicool_help | lolcat'
    'fi'

    "# <<< TermiCool Ultimate Configuration <<<"
)

# Preview mode
if [[ "$choice" == "3" ]]; then
    log_message "34" "👀" "Previewing customizations (no changes will be made):"
    printf "%s\n" "${custom_content[@]}" | less
    exit 0
fi

# Backup .bashrc
backup_file="$HOME/.bashrc.bak-$(date +%Y%m%d%H%M%S)"
if [ -f "$HOME/.bashrc" ]; then
    cp "$HOME/.bashrc" "$backup_file"
    log_message "32" "✅" "Backup created: $backup_file"
else
    echo "# Initial .bashrc created by customize_bashrc.sh" > "$HOME/.bashrc"
    log_message "33" "⚠️" "No existing .bashrc found. Created a new one."
fi

# Process user choice
if [[ "$choice" == "1" ]]; then
    log_message "34" "🔄" "Rebuilding .bashrc..."
    {
        # Preserve critical configs
        grep -P '^export (PATH|EDITOR|VISUAL|HIST\w+|PAGER|LANG|GOPATH)=' "$backup_file" 2>/dev/null || true
        grep -P '^PS1=' "$backup_file" 2>/dev/null || true
        grep -P '^shopt ' "$backup_file" 2>/dev/null || true
        grep -P '^# (EXP|alias|fun)' "$backup_file" 2>/dev/null || true

        # Add custom content
        printf "%s\n" "${custom_content[@]}"
    } > "$HOME/.bashrc.tmp"

    mv "$HOME/.bashrc.tmp" "$HOME/.bashrc"
    log_message "32" "✅" ".bashrc rebuilt successfully."

elif [[ "$choice" == "2" ]]; then
    log_message "34" "🔧" "Updating .bashrc (append/override mode)..."
    # Remove existing custom content section
    sed -i '/# >>> TermiCool Ultimate Configuration >>>/,/# <<< TermiCool Ultimate Configuration <<</d' "$HOME/.bashrc"
    # Append new custom content
    printf "%s\n" "${custom_content[@]}" >> "$HOME/.bashrc"
    log_message "32" "✅" ".bashrc updated successfully."

else
    log_message "31" "❌" "Invalid choice. Exiting..."
    exit 1
fi

# Handle quote file migration
if [ -f "$HOME/TermiCool/mine" ]; then
    mkdir -p "$HOME/.Terminal_Quotes"
    mv "$HOME/TermiCool/mine" "$HOME/.Terminal_Quotes/quotes"
    log_message "32" "📜" "Moved quote file to $HOME/.Terminal_Quotes/quotes"
fi

# Syntax check
if ! bash -n "$HOME/.bashrc" 2>&1 | tee /tmp/bashrc_syntax.log; then
    log_message "31" "❌" "Syntax error in .bashrc. Check /tmp/bashrc_syntax.log. Restoring backup..."
    mv "$backup_file" "$HOME/.bashrc"
    exit 1
fi

# Reload .bashrc
log_message "34" "♻️" "Reloading .bashrc..."
source "$HOME/.bashrc"

log_message "32" "🎉" "Customization completed successfully! Run 'termicool_help' for a list of commands!"
