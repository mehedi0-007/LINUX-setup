# Linux Machine Config

Reproducible Ubuntu workstation configuration for development and systems/infrastructure engineering.

This repository automates the setup of a personal Ubuntu workstation so that a fresh Ubuntu installation can be configured with a consistent desktop environment, development tools, shell configuration, Git configuration, and other workstation preferences.

The configuration is designed for **Ubuntu 26.04 LTS**.

---

## Goals

This repository aims to reproduce the software and configuration of a reference Ubuntu workstation without cloning the machine's hardware-specific configuration.

It configures:

* GNOME desktop appearance
* GNOME extensions
* Themes and icons
* Fonts
* Wallpaper
* GNOME workspace and window behavior
* Keyboard shortcuts
* Desktop utilities
* C/C++ development environment
* Python development environment
* Node.js
* Docker and Docker Compose
* VS Code
* Git defaults
* Bash configuration

---

## Requirements

### Operating system

* Ubuntu 26.04 LTS
* GNOME desktop
* Internet connection
* A user account with `sudo` privileges

The installer is intended for a normal Ubuntu desktop installation.

### Architecture

The configuration is primarily intended for:

```text
x86_64 / amd64
```

---

## Installation

### 1. Install Ubuntu

Install a fresh Ubuntu 26.04 LTS system.

Complete the normal Ubuntu setup and connect to the internet.

### 2. Install Git

```bash
sudo apt update
sudo apt install -y git
```

### 3. Clone the repository

Using SSH:

```bash
git clone git@github.com:USERNAME/linux-machine-config.git
```

Or using HTTPS:

```bash
git clone https://github.com/USERNAME/linux-machine-config.git
```

Enter the repository:

```bash
cd linux-machine-config
```

### 4. Run the installer

```bash
./install.sh
```

The installer executes the configuration layers in this order:

```text
Desktop packages
        ↓
Desktop configuration
        ↓
Development environment
        ↓
Shell configuration
        ↓
Git configuration
```

Some changes, especially Docker group membership and shell configuration, may require logging out and back in.

---

# Repository Structure

```text
linux-machine-config/
│
├── assets/
│   ├── fonts/
│   ├── gnome-extensions/
│   ├── icons/
│   ├── themes/
│   └── wallpaper/
│
├── config/
│   ├── extensions/
│   ├── gnome/
│   ├── dash-to-dock.dconf
│   └── gnome-settings.dconf
│
├── desktop/
│   ├── apt.txt
│   ├── configure.sh
│   ├── extensions.sh
│   ├── gnome-settings.sh
│   └── install.sh
│
├── development/
│   ├── apt.txt
│   ├── docker.sh
│   ├── install.sh
│   ├── node.sh
│   └── vscode.sh
│
├── git/
│   └── configure.sh
│
├── shell/
│   └── install.sh
│
├── scripts/
│   └── capture-extension-settings.sh
│
└── install.sh
```

---

# Desktop Configuration

The desktop layer configures the GNOME environment.

## Appearance

The reference configuration includes:

* Dark GTK appearance
* WhiteSur icons
* Bibata Modern Ice cursor
* SF Pro font
* Custom wallpaper
* Dash-to-Dock configuration

## GNOME Extensions

The following extensions are included:

* Blur My Shell
* Dash to Dock
* User Themes
* Compiz Alike Magic Lamp Effect
* Vitals
* Compiz Windows Effect
* DDC Brightness

Extension settings are stored as dconf configuration files under:

```text
config/extensions/
```

Extension source directories are stored under:

```text
assets/gnome-extensions/
```

This allows the installer to reproduce the extension versions used by the reference machine.

---

# GNOME Configuration

Selected GNOME settings are explicitly configured rather than blindly restoring the entire desktop configuration.

Examples include:

```text
Dynamic workspaces: enabled
Workspace count: 4
Focus mode: click
Auto raise: disabled
Center new windows: enabled
```

Keyboard shortcuts are stored separately under:

```text
config/gnome/
```

Hardware-specific configuration is intentionally not restored.

---

# Development Environment

The development environment includes common systems and application development tools.

## C/C++

```text
GCC
G++
Make
CMake
Ninja
GDB
Valgrind
```

## Linux/System Tools

```text
strace
ltrace
htop
iproute2
iperf3
netcat
```

## Python

The Ubuntu system Python is used for the base development environment.

Python virtual environments should be created per project:

```bash
python3 -m venv .venv
source .venv/bin/activate
```

Specialized environments, such as OCR/ML environments requiring older Python versions, are intentionally kept separate from the base workstation configuration.

## Node.js

Node.js is installed through **NVM**.

The installer configures the Node.js version used by the reference environment while allowing future projects to use different Node versions.

## Docker

Docker Engine and Docker Compose are installed from Docker's official APT repository.

The installer also configures the current user for Docker access.

After installation, a logout/login may be required before running Docker without `sudo`.

Verify:

```bash
docker --version
docker compose version
```

Test:

```bash
docker run --rm hello-world
```

## VS Code

Visual Studio Code is installed from Microsoft's official APT repository.

---

# Git Configuration

The repository configures useful global Git defaults such as:

```text
default branch: main
editor: code --wait
fetch.prune: true
rerere.enabled: true
```

The following are intentionally **not** configured automatically:

```text
user.name
user.email
SSH keys
GitHub tokens
GitHub credentials
```

Set your identity manually:

```bash
git config --global user.name "Your Name"
git config --global user.email "your@email.com"
```

Authenticate with GitHub separately.

For SSH authentication:

```bash
ssh-keygen -t ed25519 -C "your@email.com"
```

Never commit private SSH keys to this repository.

---

# Shell Configuration

The shell layer assumes Bash.

The installer configures useful defaults and aliases such as:

```bash
ll
la
l
..
...
```

It also configures:

```text
EDITOR="code --wait"
VISUAL="code --wait"
```

---

# Hardware-Specific Configuration

This repository intentionally does **not** clone hardware-specific configuration.

The following are not blindly restored:

* Monitor configuration
* Display connector names
* Resolution and refresh rate
* GPU configuration
* Network interfaces
* Wi-Fi configuration
* Bluetooth devices
* Audio hardware
* Storage device identifiers
* Disk mounts
* Bootloader configuration
* Machine-specific kernel parameters

This allows the same repository to be used on different physical machines.

---

# Security

Do **not** commit sensitive information.

Never add:

```text
~/.ssh/
.env
API keys
Access tokens
Passwords
Private keys
Cloud credentials
OpenBao credentials
Database passwords
GitHub tokens
```

Before pushing changes:

```bash
git status
git diff --cached
```

Review staged files carefully.

---

# Updating the Configuration

When the reference machine changes, update the corresponding configuration in this repository.

For example:

```text
New GNOME setting
        ↓
capture/update dconf configuration

New desktop package
        ↓
desktop/apt.txt

New development package
        ↓
development/apt.txt

New Node requirement
        ↓
development/node.sh
```

Avoid copying entire system configuration directories unless there is a specific reason to do so.

---

# Testing

Before using the repository on another machine, validate all shell scripts:

```bash
for f in \
    install.sh \
    desktop/install.sh \
    desktop/configure.sh \
    desktop/extensions.sh \
    desktop/gnome-settings.sh \
    development/install.sh \
    development/node.sh \
    development/docker.sh \
    development/vscode.sh \
    shell/install.sh \
    git/configure.sh
do
    bash -n "$f" || exit 1
done

echo "All scripts: OK"
```

The preferred integration test is a **fresh Ubuntu 26.04 LTS installation**.

After installation, verify:

```bash
node --version
npm --version

python3 --version

docker --version
docker compose version

git --version
gh --version

gcc --version
g++ --version

code --version
```

Then verify GNOME:

```bash
gsettings get org.gnome.mutter dynamic-workspaces
gsettings get org.gnome.desktop.wm.preferences num-workspaces
gsettings get org.gnome.desktop.wm.preferences focus-mode
```

---

# Design Principles

This repository follows several principles:

### 1. Reproducibility

A fresh Ubuntu installation should be able to reach a known workstation state with minimal manual configuration.

### 2. Idempotency

Running the installer multiple times should not continuously duplicate configuration or create broken state.

### 3. Hardware independence

Software configuration should be reproducible without assuming identical hardware.

### 4. Separation of concerns

Desktop, development, shell, and Git configuration are kept in separate layers.

### 5. No secrets

Credentials and private machine state stay outside the repository.

### 6. Explicit configuration

Important settings should be represented by readable scripts or configuration files instead of opaque full-system snapshots.

---

# Current Scope

Currently included:

* Ubuntu 26.04 workstation configuration
* GNOME customization
* GNOME extensions
* Desktop utilities
* Development toolchain
* Node.js
* Docker
* VS Code
* Bash
* Git defaults

Currently excluded:

* OCR/ML Python 3.10 environment
* GPU/CUDA configuration
* Cloud credentials
* SSH keys
* Personal application data
* Browser profiles
* Project repositories
* Database data
* Machine-specific hardware configuration

These can be added later as separate, isolated setup layers.
