#!/bin/bash

# TermiCool: Ultimate Arch Linux terminal with extensive developer/user tools and customization

# Enable strict error handling
set -euo pipefail

# Log messages with timestamp
log_message() {
    local color=$1 symbol=$2
    shift 2
    echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] \033[${color}m${symbol} $@\033[0m" | tee -a /tmp/termicool.log
}

# Check if system is Arch-based
is_arch_based() {
    grep -qi 'ID=arch' /etc/os-release || grep -qi 'ID_LIKE=arch' /etc/os-release
}

if ! is_arch_based; then
    log_message "31" "❌" "Arch-based system required. Exiting..."
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
    log_message "31" "❌" "No supported package manager found. Exiting..."
    exit 1
fi

# Define packages
required_pkgs=(
    "lolcat" "neofetch" "ncdu" "htop" "tree" "lm_sensors" "curl" "wget" "git" "net-tools"
    "bat" "exa" "lsd" "fzf" "tmux" "python" "python-pip" "fortune-mod" "ripgrep" "fd"
    "unzip" "bash-completion" "figlet" "toilet" "zoxide" "jq" "shellcheck" "tldr" "cowsay"
    "taskwarrior" "ffmpeg" "yt-dlp" "p7zip"
)
optional_pkgs=(
    "docker" "kubectl" "nodejs" "npm" "python-black" "python-pylint" "python-pytest" "go"
    "rust" "openjdk17-jdk" "ruby" "aws-cli" "google-cloud-sdk" "terraform" "postgresql" "mysql"
    "starship" "yay" "gcc" "clang" "clang-format" "php" "typescript" "eslint" "prettier"
    "ansible" "vagrant" "minikube" "helm" "packer" "gh" "deno" "julia" "jest"
)

# Install packages with retry
install_packages() {
    local pkg_list=("$@") missing_pkgs=() retries=3 attempt=1
    log_message "34" "🔍" "Checking packages..."
    for pkg in "${pkg_list[@]}"; do
        $PKG_CHECK "$pkg" &> /dev/null 2>&1 || { missing_pkgs+=("$pkg"); log_message "33" "⚠️" "$pkg missing."; }
    done
    if [ ${#missing_pkgs[@]} -gt 0 ]; then
        log_message "34" "📦" "Installing: ${missing_pkgs[*]}"
        while [ $attempt -le $retries ]; do
            if $PKG_MGR "${missing_pkgs[@]}" 2>&1 | tee -a /tmp/pkg_install.log; then
                log_message "32" "✅" "Packages installed."
                return 0
            fi
            log_message "31" "❌" "Attempt $attempt/$retries failed."
            ((attempt++))
            sleep 3
        done
        log_message "31" "❌" "Installation failed. Check /tmp/pkg_install.log."
        exit 1
    fi
    log_message "32" "✅" "All packages installed."
}

# Install required packages
install_packages "${required_pkgs[@]}"

# Ask for optional packages
log_message "34" "❓" "Install developer/system tools (${optional_pkgs[*]})? [y/N]"
read -r install_optional
if [[ "$install_optional" =~ ^[Yy]$ ]]; then
    if [[ " ${optional_pkgs[*]} " =~ " yay " ]] && ! command -v yay &> /dev/null; then
        log_message "34" "📦" "Installing yay (AUR helper)..."
        git clone https://aur.archlinux.org/yay.git /tmp/yay
        cd /tmp/yay
        makepkg -si --noconfirm || log_message "31" "⚠️" "Failed to install yay."
        cd -
    fi
    install_packages "${optional_pkgs[@]}"]
fi

# Create TermiCool config file if not exists
CONFIG_FILE="$HOME/.termicool_config"
if [ ! -f "$CONFIG_FILE" ]; then
    cat > "$CONFIG_FILE" << EOF
# TermiCool Configuration
SHOW_NEOFETCH=true
SHOW_QUOTES=true
SHOW_FORTUNE=true
SHOW_COWSAY=true
PROMPT_STYLE=git
COLOR_SCHEME=default
EOF
    log_message "32" "✅" "Created config file: $CONFIG_FILE"
fi

# Interactive menu
log_message "34" "🛠️" "Choose: 1) Rebuild .bashrc  2) Append (default)  3) Preview"
read -r choice
choice=${choice:-2}

# Define custom content
custom_content=(
    "# >>> TermiCool Ultimate Configuration >>>"
    "# Extensive developer/user aliases, functions, and customization"

    "## Environment Setup"
    'export HISTCONTROL=ignoredups:erasedups'
    'export HISTSIZE=10000'
    'export HISTFILESIZE=20000'
    'export EDITOR=nano'
    'export VISUAL=nano'
    'export GOPATH="$HOME/go"'
    'export PATH="$PATH:$GOPATH/bin:/usr/local/go/bin:$HOME/.cargo/bin:$HOME/.local/bin:$HOME/.gem/ruby/bin:/usr/lib/jvm/java-17-openjdk/bin:/usr/local/php/bin:/usr/local/node/bin:/usr/local/deno/bin:/usr/local/julia/bin"'

    "## Load TermiCool Config"
    '[ -f "$HOME/.termicool_config" ] && source "$HOME/.termicool_config"'
    '[ -f "$HOME/.termicool_aliases" ] && source "$HOME/.termicool_aliases"'

    "## Prompt Customization"
    'parse_git_branch() { git branch 2>/dev/null | sed -e "/^[^*]/d" -e "s/* \(.*\)/ (\1)/"; }'
    'set_prompt() {'
    '    case "$COLOR_SCHEME" in'
    '        default) USER_COLOR="\e[32;1m"; DIR_COLOR="\e[33;1m"; GIT_COLOR="\e[35;1m" ;;'
    '        neon) USER_COLOR="\e[36;1m"; DIR_COLOR="\e[34;1m"; GIT_COLOR="\e[31;1m" ;;'
    '        pastel) USER_COLOR="\e[35;1m"; DIR_COLOR="\e[36;1m"; GIT_COLOR="\e[32;1m" ;;'
    '        *) USER_COLOR="\e[32;1m"; DIR_COLOR="\e[33;1m"; GIT_COLOR="\e[35;1m" ;;'
    '    esac'
    '    case "$PROMPT_STYLE" in'
    '        simple) PS1="\[$USER_COLOR\]\u@\h \[$DIR_COLOR\]\w\[\e[0m\] \$ " ;;'
    '        git) PS1="\[$USER_COLOR\]\u@\h \[$DIR_COLOR\]\w\[$GIT_COLOR\]\$(parse_git_branch)\[\e[0m\] \$ " ;;'
    '        minimal) PS1="\[$DIR_COLOR\]\w\[\e[0m\] \$ " ;;'
    '        fancy) PS1="\[$USER_COLOR\][\u@\h] \[$DIR_COLOR\]\w\[$GIT_COLOR\]\$(parse_git_branch)\[\e[0m\] > " ;;'
    '        *) PS1="\[$USER_COLOR\]\u@\h \[$DIR_COLOR\]\w\[$GIT_COLOR\]\$(parse_git_branch)\[\e[0m\] \$ " ;;'
    '    esac'
    '}'
    'prompt_toggle() {'
    '    [ -z "$1" ] && { echo "Usage: prompt_toggle {simple|git|minimal|fancy}"; return 1; }'
    '    sed -i "s/PROMPT_STYLE=.*/PROMPT_STYLE=$1/" "$HOME/.termicool_config"'
    '    source "$HOME/.termicool_config" && set_prompt'
    '}'
    'color_toggle() {'
    '    [ -z "$1" ] && { echo "Usage: color_toggle {default|neon|pastel}"; return 1; }'
    '    sed -i "s/COLOR_SCHEME=.*/COLOR_SCHEME=$1/" "$HOME/.termicool_config"'
    '    source "$HOME/.termicool_config" && set_prompt'
    '}'
    'command -v starship &> /dev/null && eval "$(starship init bash)"'
    'set_prompt'

    "## Navigation"
    'alias ..="cd .."'
    'alias ...="cd ../.."'
    'alias ....="cd ../../.."'
    'alias back="cd -"'
    'alias home="cd ~"'
    'alias root="cd /"'
    'alias docs="cd ~/Documents"'
    'alias dwnld="cd ~/Downloads"'
    'command -v zoxide &> /dev/null && eval "$(zoxide init bash)" && alias cd="z"'

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
    'alias lsd="lsd --group-dirs first"'
    'alias mkdir="mkdir -p"'
    'alias rm="rm -i"'
    'alias cp="cp -iv"'
    'alias mv="mv -iv"'
    'alias duh="du -h --max-depth=1"'
    'alias findlarge="find . -type f -size +100M"'
    'alias zipit="zip -r"'
    'alias untar="tar -xvf"'
    'alias 7z="7z a"'

    "## Text and Search"
    'alias nano="nano -c"'
    'alias vim="vim -p"'
    'alias cat="bat --paging=never"'
    'alias less="less -R"'
    'alias json="jq ."'
    'alias grep="rg --color=auto"'
    'alias findfile="fd"'
    'alias ftext="rg -r"'
    'alias fuzzy="fzf --preview \"bat --color=always {}\""'
    'alias tldr="tldr --theme ocean"'
    'alias cheat="cheat"'

    "## System Monitoring and Diagnostics"
    'alias usage="df -h"'
    'alias mem="free -h"'
    'alias top="htop"'
    'alias psx="ps aux --sort=-%mem | head"'
    'alias temps="sensors"'
    'alias logs="sudo journalctl -p 3 -xb"'
    'alias services="systemctl list-units --type=service"'
    'alias sysinfo="inxi -Fxxxz"'
    'alias lscpu="lscpu"'
    'alias lsblk="lsblk -f"'
    'alias iotop="iotop"'

    "## Networking"
    'alias myip="curl ifconfig.me"'
    'alias ports="netstat -tulanp"'
    'alias ping="ping -c 5"'
    'alias wget="wget -c"'
    'alias speedtest="curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python -"'
    'alias nmap="nmap -sP"'
    'alias ghstats="gh repo view --json stargazers_count,watchers_count,forks_count"'

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
    'alias ghpr="gh pr create"'
    'alias ghissue="gh issue create"'

    "## Python Development"
    'alias pipup="pip install --upgrade pip"'
    'alias pyfmt="black ."'
    'alias pylint="pylint --rcfile ~/.pylintrc"'
    'alias pytest="pytest --verbose"'
    'mkvenv() {'
    '    [ -z "$1" ] && { echo "Usage: mkvenv <env_name>"; return 1; }'
    '    python -m venv "$1" && source "$1/bin/activate" && pipup && pip install black pylint pytest'
    '    echo "Virtual environment \'$1\' created."'
    '}'
    'actvenv() { [ -d "$1" ] && source "$1/bin/activate" || echo "Directory \'$1\' not found."; }'
    'deactvenv() { deactivate 2>/dev/null || echo "No virtual environment active."; }'

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

    "## Node.js and TypeScript Development"
    'alias nr="npm run"'
    'alias ni="npm install"'
    'alias nstart="npm start"'
    'alias ntest="npm test"'
    'alias ts="npx tsc"'
    'alias lint="eslint ."'
    'alias fmt="prettier --write ."'
    'alias jest="jest --verbose"'

    "## C/C++ Development"
    'alias gcc="gcc -Wall -Wextra"'
    'alias clang="clang -Wall -Wextra"'
    'alias make="make -j$(nproc)"'
    'alias cfmt="clang-format -i"'

    "## PHP Development"
    'alias php="php -d display_errors=On"'
    'alias composer="composer --no-interaction"'

    "## Deno Development"
    'alias deno="deno run"'
    'alias denofmt="deno fmt"'
    'alias denotest="deno test"'

    "## Julia Development"
    'alias julia="julia --color=yes"'

    "## Cloud and DevOps Tools"
    'alias awsls="aws s3 ls"'
    'alias awscfg="aws configure"'
    'alias gcloud="gcloud"'
    'alias tf="terraform"'
    'alias tfinit="terraform init"'
    'alias tfplan="terraform plan"'
    'alias tfapply="terraform apply"'
    'alias ans="ansible-playbook"'
    'alias vag="vagrant"'
    'alias mkube="minikube"'
    'alias helm="helm"'
    'alias pack="packer"'

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

    "## Media Utilities"
    'alias ytdl="yt-dlp"'
    'alias ffmpeg="ffmpeg -hide_banner"'

    "## Productivity"
    'alias task="task"'
    'alias taskadd="task add"'
    'alias taskdone="task done"'

    "## Custom Functions"
    'mkcd() { mkdir -p "$1" && cd "$1"; }'
    'extract() {'
    '    [ -f "$1" ] || { echo "File not found: $1"; return 1; }'
    '    case "$1" in'
    '        *.tar.gz) tar xzf "$1" ;;'
    '        *.tar) tar xf "$1" ;;'
    '        *.zip) unzip "$1" ;;'
    '        *.7z) 7z x "$1" ;;'
    '        *.rar) unrar x "$1" 2>/dev/null || echo "Install unrar"; ;;'
    '        *) echo "Unsupported format: $1" ;;'
    '    esac'
    '}'
    'newproj() {'
    '    [ -z "$1" ] && { echo "Usage: newproj <name> [python|go|rust|node|java|ruby|cpp|php|deno|julia]"; return 1; }'
    '    mkdir -p "$1" && cd "$1" && git init && echo "# $1" > README.md'
    '    case "$2" in'
    '        python) mkvenv venv && touch main.py ;;'
    '        go) go mod init "$1" && touch main.go ;;'
    '        rust) cargo init && touch src/main.rs ;;'
    '        node) npm init -y && touch index.js ;;'
    '        java) touch Main.java ;;'
    '        ruby) touch main.rb ;;'
    '        cpp) touch main.cpp && echo -e "#include <iostream>\nint main() {\n    std::cout << \"Hello, World!\\n\";\n    return 0;\n}" > main.cpp ;;'
    '        php) touch index.php && echo "<?php phpinfo(); ?>" > index.php ;;'
    '        deno) touch main.ts && echo "console.log(\"Hello, Deno!\");" > main.ts ;;'
    '        julia) touch main.jl && echo "println(\"Hello, Julia!\")" > main.jl ;;'
    '        *) echo "Basic project created." ;;'
    '    esac'
    '    echo "Created $2 project: $1"'
    '}'

    "## Alias Viewing Function"
    'shortcuts() {'
    '    if command -v lolcat &> /dev/null; then'
    '        local c="lolcat"'
    '    else'
    '        local c="cat"'
    '    fi'
    '    echo "Main TermiCool Aliases:" | $c'
    '    echo -e "\nNavigation:" | $c'
    '    echo "  .., ..., ...., back, home, root, docs, dwnld, cd (zoxide)" | $c'
    '    echo -e "\nPackage Management:" | $c'
    '    echo "  sync, install, update, cleanup, clean, pkginfo, aur" | $c'
    '    echo -e "\nFile Management:" | $c'
    '    echo "  ll, ls, lsd, mkdir, rm, cp, mv, duh, findlarge, zipit, untar, 7z, extract" | $c'
    '    echo -e "\nText/Search:" | $c'
    '    echo "  nano, vim, cat, less, json, grep, findfile, ftext, fuzzy, tldr, cheat" | $c'
    '    echo -e "\nSystem Monitoring:" | $c'
    '    echo "  usage, mem, top, psx, temps, logs, services, sysinfo, lscpu, lsblk, iotop" | $c'
    '    echo -e "\nNetworking:" | $c'
    '    echo "  myip, ports, ping, wget, speedtest, nmap, ghstats" | $c'
    '    echo -e "\nGit:" | $c'
    '    echo "  gs, ga, gc, gp, gl, gco, gbr, gpull, gclone, gdiff, gst, gsp, grebase, gundo, ghpr, ghissue" | $c'
    '    echo -e "\nPython:" | $c'
    '    echo "  pipup, pyfmt, pylint, pytest, mkvenv, actvenv, deactvenv" | $c'
    '    echo -e "\nGo:" | $c'
    '    echo "  gob, gor, got, gofmt" | $c'
    '    echo -e "\nRust:" | $c'
    '    echo "  cr, cb, ct, cfmt" | $c'
    '    echo -e "\nJava:" | $c'
    '    echo "  javac, java" | $c'
    '    echo -e "\nRuby:" | $c'
    '    echo "  rb, gemup" | $c'
    '    echo -e "\nNode.js/TypeScript:" | $c'
    '    echo "  nr, ni, nstart, ntest, ts, lint, fmt, jest" | $c'
    '    echo -e "\nC/C++:" | $c'
    '    echo "  gcc, clang, make, cfmt" | $c'
    '    echo -e "\nPHP:" | $c'
    '    echo "  php, composer" | $c'
    '    echo -e "\nDeno:" | $c'
    '    echo "  deno, denofmt, denotest" | $c'
    '    echo -e "\nJulia:" | $c'
    '    echo "  julia" | $c'
    '    echo -e "\nCloud/DevOps:" | $c'
    '    echo "  awsls, awscfg, gcloud, tf, tfinit, tfplan, tfapply, ans, vag, mkube, helm, pack" | $c'
    '    echo -e "\nDatabase:" | $c'
    '    echo "  psqlstart, psqlstop, mysqlstart, mysqlstop" | $c'
    '    echo -e "\nDocker:" | $c'
    '    echo "  dkr, dkps, dkimg, dkclean, dkbuild" | $c'
    '    echo -e "\nKubernetes:" | $c'
    '    echo "  k, kctx, kns" | $c'
    '    echo -e "\nMedia:" | $c'
    '    echo "  ytdl, ffmpeg" | $c'
    '    echo -e "\nProductivity:" | $c'
    '    echo "  task, taskadd, taskdone" | $c'
    '    echo -e "\nFun:" | $c'
    '    echo "  sayhello, weather, cowsay, starwars, banner, fortune, asciiart" | $c'
    '}'

    "## Help Command"
    'termicool_help() {'
    '    termicool_aliases'
    '    echo -e "\nFunctions: mkcd, extract, newproj, prompt_toggle, color_toggle, termicool_help, termicool_aliases" | lolcat'
    '    echo "Customization: Edit ~/.termicool_config or ~/.termicool_aliases" | lolcat'
    '    echo "Run \`prompt_toggle {simple|git|minimal|fancy}\` or \`color_toggle {default|neon|pastel}\` to customize prompt" | lolcat'
    '}'

    "## Auto-completion"
    '[ -f /usr/share/bash-completion/bash_completion ] && . /usr/share/bash-completion/bash_completion'

    "## Startup Features (interactive shells only)"
    'if [[ $- == *i* ]]; then'
    '    command -v toilet &> /dev/null && toilet -f term -F border --gay "Welcome, $USER!" | lolcat'
    '    [ "$SHOW_NEOFETCH" = true ] && command -v neofetch &> /dev/null && neofetch --colors 2 3 4 5 6 7 | lolcat'
    '    [ "$SHOW_FORTUNE" = true ] && command -v fortune &> /dev/null && fortune | lolcat'
    '    [ "$SHOW_COWSAY" = true ] && command -v cowsay &> /dev/null && cowsay -f tux "Hello, $USER!" | lolcat'
    '    [ "$SHOW_QUOTES" = true ] && [ -f "$HOME/.Terminal_Quotes/quotes" ] && shuf -n 1 "$HOME/.Terminal_Quotes/quotes" | lolcat || echo "Create ~/.Terminal_Quotes/quotes for random quotes!" | lolcat'
    'fi'

    "# <<< TermiCool Ultimate Configuration <<<"
)

# Preview mode
if [[ "$choice" == "3" ]]; then
    log_message "34" "👀" "Previewing customizations:"
    printf "%s\n" "${custom_content[@]}" | less
    exit 0
fi

# Backup .bashrc
backup_file="$HOME/.bashrc.bak-$(date +%Y%m%d%H%M%S)"
if [ -f "$HOME/.bashrc" ]; then
    cp "$HOME/.bashrc" "$backup_file"
    log_message "32" "✅" "Backup created: $backup_file"
else
    echo "# Initial .bashrc" > "$HOME/.bashrc"
    log_message "33" "⚠️" "No .bashrc found. Created new one."
fi

# Process user choice
if [[ "$choice" == "1" ]]; then
    log_message "34" "🔄" "Rebuilding .bashrc..."
    {
        grep -P '^export (PATH|EDITOR|VISUAL|HIST\w+|PAGER|LANG|GOPATH)=' "$backup_file" 2>/dev/null || true
        grep -P '^PS1=' "$backup_file" 2>/dev/null || true
        grep -P '^shopt ' "$backup_file" 2>/dev/null || true
        printf "%s\n" "${custom_content[@]}"
    } > "$HOME/.bashrc.tmp"
    mv "$HOME/.bashrc.tmp" "$HOME/.bashrc"
    log_message "32" "✅" ".bashrc rebuilt."

elif [[ "$choice" == "2" ]]; then
    log_message "34" "🔧" "Updating .bashrc..."
    sed -i '/# >>> TermiCool Ultimate Configuration >>>/,/# <<< TermiCool Ultimate Configuration <<</d' "$HOME/.bashrc"
    printf "%s\n" "${custom_content[@]}" >> "$HOME/.bashrc"
    log_message "32" "✅" ".bashrc updated."

else
    log_message "31" "❌" "Invalid choice. Exiting..."
    exit 1
fi

# Handle quote file migration
if [ -f "$HOME/TermiCool/mine" ]; then
    mkdir -p "$HOME/.Terminal_Quotes"
    mv "$HOME/TermiCool/mine" "$HOME/.Terminal_Quotes/quotes"
    log_message "32" "📜" "Moved quote file to ~/.Terminal_Quotes/quotes"
fi

# Syntax check
if ! bash -n "$HOME/.bashrc" 2>&1 | tee /tmp/termicool_syntax.log; then
    log_message "31" "❌" "Syntax error in .bashrc. Check /tmp/termicool_syntax.log. Restoring backup..."
    mv "$backup_file" "$HOME/.bashrc"
    exit 1
fi

# Reload .bashrc
log_message "34" "♻️" "Reloading .bashrc..."
source "$HOME/.bashrc"

log_message "32" "🎉" "Setup complete! Run 'termicool_help' or 'termicool_aliases' for commands."
