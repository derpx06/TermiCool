TermiCool
Make your Arch terminal fun, productive, and developer-ready!
TermiCool is a streamlined setup script that transforms your Arch Linux terminal into a vibrant, efficient, and feature-rich environment. Perfect for developers and terminal enthusiasts, it automates the installation of essential tools, adds powerful shortcuts, and enhances your terminal with colorful prompts, ASCII art, and motivational quotes. From coding in Python, Go, or Rust to managing Docker containers, TermiCool makes your workflow both fun and productive.

Features

Developer Shortcuts: Aliases for Git, Python, Go, Rust, Docker, Kubernetes, and more to streamline coding tasks.
System Utilities: Easy commands for package management, system monitoring, and navigation.
Smart Navigation: Uses zoxide for intelligent directory switching and fzf for fuzzy finding.
Pacman Shortcuts: Simplified Arch Linux package management with install, update, and cleanup.
Visual Flair: Colorful Git-aware prompt, starship support, neofetch, lolcat, and ASCII art for a stunning terminal.
Motivational Quotes: Displays random quotes on startup from a customizable file.
Customizable: XDG-compliant quote storage and easy .bashrc editing for personalization.
Robust Setup: Debugged installation with logging and backup support.

How to Install
Prerequisites

Operating System: Arch Linux or an Arch-based distribution (e.g., Manjaro).
Privileges: sudo access for installing packages.
Internet: Required for package installation and tools like neofetch.

Installation Steps

Clone the Repository:
[ -d "TermiCool" ] && rm -rf TermiCool
git clone https://github.com/manas1511200/TermiCool.git
cd TermiCool


Run the Setup Script:
chmod +x setup.sh
./setup.sh


Follow the Prompts:

Choose:
1: Rebuild .bashrc (replaces with preserved configs).
2: Append (updates script-managed section, default).
3: Preview customizations without applying.


Opt to install developer tools (e.g., Python, Go, Docker) when prompted.


Reload Your Shell:
source ~/.bashrc
cd ..



Additional Commands

List Available Commands:
termicool_help

  Displays all TermiCool aliases and functions.

Revert to Backup:
cp ~/.bashrc.bak-$(ls -t ~/.bashrc.bak-* | head -n1) ~/.bashrc
source ~/.bashrc

  Restores the latest backup created during setup.

Reset to System Default:
cp /etc/skel/.bashrc ~/.bashrc
source ~/.bashrc

  Reverts to Arch’s default .bashrc.

Reload TermiCool Setup:
cd TermiCool
./setup.sh
source ~/.bashrc
cd ..

  Reapplies TermiCool customizations.


Customization

Edit .bashrc: Modify ~/.bashrc to tweak aliases or the prompt. Run prompt_toggle {simple|git|minimal} to switch prompt styles (if added in future updates).
Add Quotes: Create ~/.Terminal_Quotes/quotes with one quote per line for random startup messages.
Starship Prompt: If installed, customize the prompt via ~/.config/starship.toml.
Logs: Check /tmp/termicool.log or /tmp/pkg_install.log for setup issues.

Troubleshooting

Installation Errors: Review /tmp/pkg_install.log for package issues. Ensure internet connectivity.
Syntax Errors: If .bashrc fails, check /tmp/termicool.log and restore a backup.
Missing Tools: Some aliases require optional packages. Rerun setup.sh and select y for developer tools.
