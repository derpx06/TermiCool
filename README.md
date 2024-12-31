# TermiCool

**Make your Arch terminal fun again!**

TermiCool is a comprehensive setup script designed to supercharge your Arch Linux terminal experience. It brings fun and productivity to your workflow by adding useful tools, shortcuts, and visual enhancements. The script automatically installs essential packages like `lolcat`, `neofetch`, and more, while adding practical aliases for navigation, system monitoring, Git, and development. It even includes motivational quotes and tweaks to make your terminal experience more enjoyable.

![Screenshot](https://github.com/user-attachments/assets/e2ee8ae5-2bf7-48ef-9db7-4fba5c1b1192)

## Features
- **Custom Shortcuts:** Speed up your command-line navigation with user-friendly shortcuts.
- **Pacman Shortcuts:** Simplified package management for Arch Linux with pacman aliases.
- **Quotes:** Enjoy  quotes about system info on terminal startup.
- **Fun Additions:** Includes `neofetch`, `lolcat`, and more to add fun and vibrancy to your terminal.
- **Customizable:** Structured, XDG-compliant configuration file for quotes and personalization.
  
## How to Install

### Prerequisites
Make sure you're running Arch Linux and have sudo privileges.

### Installation Steps
1. Clone the repository and navigate to the project directory:
    ```bash
    [ -d "TermiCool" ] && rm -rf "TermiCool"
    git clone https://github.com/manas1511200/TermiCool.git
    cd TermiCool
    chmod +x setup.sh
    ./setup.sh
    source ~/.bashrc
    ```

### Additional Commands

- **Check the added keys:**
    ```bash
    keys
    ```

- **Revert back to your original `.bashrc`:**
    ```bash
    cp ~/.bashrc.backup ~/.bashrc
    source ~/.bashrc
    ```

- **Reset to the system default `.bashrc`:**
    ```bash
    cp /etc/skel/.bashrc ~/
    ```

- **Reload the setup (if you want to reapply the changes):**
    ```bash
    reload
    ```

### Customization
You can easily edit the `.bashrc` file to modify configurations, add new aliases, or make other adjustments to fit your preferences.

## Contributions
Feel free to fork this project and contribute improvements. If you have any suggestions or issues, please open an issue or create a pull request.
