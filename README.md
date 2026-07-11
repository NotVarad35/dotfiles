<div align="center">

# 🌙 NotVarad's Noctalia based Rice

**Arch Linux dotfiles — Noctalia shell + MangoWM + Quickshell**

[![Arch Linux](https://img.shields.io/badge/Arch%20Linux-1793D1?style=for-the-badge&logo=archlinux&logoColor=white)](https://archlinux.org)
[![Wayland](https://img.shields.io/badge/Wayland-4D4D4D?style=for-the-badge&logo=gnome-terminal&logoColor=white)](https://wayland.freedesktop.org)
[![QuickShell](https://img.shields.io/badge/QuickShell-QML-blue?style=for-the-badge)](https://quickshell.outfoxxed.me)
[![MangoWM](https://img.shields.io/badge/MangoWM-Tiling%20WM-orange?style=for-the-badge)](https://github.com/DreamMaoMao/mangowc)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)

---

A fully riced Arch Linux desktop with **Noctalia shell**, **MangoWM** tiling compositor, **22 randomized SDDM themes**, performance mode toggle, and dynamic wallpaper tools.

<!-- TODO: Add your screenshot or GIF here -->
<!-- ![Preview](screenshot.png) -->

</div>

---

## ✨ Features

- 🖥️ **Noctalia Shell** — custom QML-based bar, launcher, notifications, clipboard history, emoji picker, and settings panel
- 🎨 **22 SDDM Lock Screen Themes** — randomized on every lock for a fresh look
- ⚡ **Performance Mode** — one-key toggle strips blur, shadows, and animations for max FPS
- 🖼️ **Wallpaper Maker** — set wallpapers from screenshot, URL, or clipboard
- 🔒 **Lock Screen** — random SDDM theme selection on every lock
- 🎭 **Dynamic Theming** — sunset / sea / green / dark themes via Noctalia ThemingService
- 📱 **KDE Connect** — phone integration (calls, notifications, file share)
- 🇯🇵 **Japanese Input** — fcitx5 + Mozc with Super key toggle
- 📋 **Clipboard History** — powered by cliphist + Noctalia clipboard widget
- 🔍 **App Launcher** — fuzzy search, categories, usage tracking, and prefix commands (`>clip`, `>emoji`, `>cmd`, `>settings`)
- 🎵 **Media Integration** — MPRIS now-playing, volume/brightness OSD
- 🐧 **Auto Icon Fetcher** — missing app icons auto-downloaded from iconify.design

---

## 🧰 Tech Stack

| Component | Tool |
|---|---|
| 🖥️ Compositor | [MangoWM](https://github.com/DreamMaoMao/mangowc) (mangowm) |
| 🐚 Shell / Bar | [Noctalia](https://noctalia.dev) (QuickShell QML) |
| 📟 Terminal | [Foot](https://codeberg.org/dnkl/foot) |
| ✏️ Editor | [Neovim](https://neovim.io) |
| 🔍 Launcher | [Walker](https://github.com/abenz1267/walker) |
| 📊 System Monitor | [btop](https://github.com/aristocratos/btop) |
| 🎬 Media Player | [mpv](https://mpv.io) |
| 🔐 Display Manager | [SDDM](https://github.com/sddm/sddm) |
| 📝 Input Method | [fcitx5](https://fcitx-im.org) + [Mozc](https://github.com/google/mozc) |
| 🎨 Icon Theme | [Tela-circle](https://github.com/vinceliuice/Tela-circle-icon-theme) |
| 🖱️ Cursor | Bog |
| 📱 Phone Integration | [KDE Connect](https://kde.org/applications/org.kde.kdeconnect) |
| 📸 Screenshots | grim + slurp |
| 📋 Clipboard | cliphist + wl-paste |

---

## 🚀 Installation

### Prerequisites

- Arch Linux (or Arch-based distro)
- `git` and `base-devel` installed
- Internet connection

### Steps

```bash
# 1. Clone the repository
git clone https://github.com/NotVarad35/dotfiles.git ~/dotfiles
cd ~/dotfiles

# 2. Symlink configs (backup existing ones first!)
cp -r ~/.config/{btop,foot,mpv,nvim,fastfetch,walker} ~/.config/.backup/ 2>/dev/null
for dir in config/*/; do
  app=$(basename "$dir")
  ln -sf "$HOME/dotfiles/config/$app" "$HOME/.config/$app"
done

# 3. Copy scripts to ~/.local/bin
mkdir -p ~/.local/bin
cp local/bin/* ~/.local/bin/
chmod +x ~/.local/bin/*

# 4. Copy SDDM themes (requires sudo)
sudo cp -r backup-sddm/themes/* /usr/share/sddm/themes/
sudo cp config/sddm/Xsetup /usr/local/bin/sddm-random-theme.sh
sudo chmod +x /usr/local/bin/sddm-random-theme.sh

# 5. Set up sudoers for lock script (optional)
sudo cp config/sudoers.d/lock-theme /etc/sudoers.d/lock-theme

# 6. Install SDDM config
sudo mkdir -p /etc/sddm.conf.d
echo -e "[Theme]\nCurrent=pixel-dusk-city" | sudo tee /etc/sddm.conf.d/theme.conf

# 7. Enable services
systemctl --user enable cliphist.service
```

### Packages to Install

<details>
<summary><b>📦 Click to expand full package list</b></summary>

```bash
# Core
sudo pacman -S git base-devel

# Shell & Terminal
sudo pacman -S foot neovim fastfetch

# Wayland & Compositor
sudo pacman -S mango quickshell grim slurp wl-clipboard xdg-desktop-portal-wlr

# System
sudo pacman -S btop brightnessctl playerctl pavucontrol networkmanager

# Apps
sudo pacman -S mpv thunar firefox

# Input Method
sudo pacman -S fcitx5 fcitx5-configtool fcitx5-gtk fcitx5-mozc

# Fonts
sudo pacman -S ttf-jetbrains-mono-nerd noto-fonts noto-fonts-cjk noto-fonts-emoji

# Theming
sudo pacman -S qt5ct qt6ct kvantum

# AUR (use yay or paru)
yay -S sddm themes pixel-* sddm theme
```

</details>

---

## 📁 Directory Structure

```
dotfiles/
├── .obsidian/                    # Obsidian config
├── Wallpapers/                   # Wallpaper collection
├── backup-sddm/                  # SDDM theme backups
│   ├── themes/                   # 22 pixel-* SDDM themes
│   └── sddm.conf                 # SDDM backup config
├── config/                       # App configs (symlinked to ~/.config)
│   ├── btop/                     # System monitor
│   ├── fastfetch/                # System info
│   ├── fcitx5/                   # Input method
│   ├── foot/                     # Terminal
│   ├── kdeconnect/               # Phone integration
│   ├── mango/                    # Window manager
│   ├── mpv/                      # Media player
│   ├── noctalia/                 # Shell settings
│   ├── nvim/                     # Editor
│   ├── sddm/                     # Display manager
│   ├── sudoers.d/                # Sudo rules for lock script
│   └── walker/                   # App launcher
├── docs/                         # Notes & plans
├── ideasplan/                    # Feature roadmap
├── local/
│   ├── bin/                      # Scripts (installed to ~/.local/bin)
│   │   ├── lock.sh               # Random SDDM theme + lock
│   │   ├── sddm-random-theme.sh  # Randomize login theme
│   │   ├── toggle-perf-mode.sh   # Performance mode toggle
│   │   ├── wallpaper-maker.sh    # Wallpaper setter
│   │   └── fetch-app-icon.sh     # Auto-fetch missing icons
│   └── share/                    # Local data
├── scripts/                      # Additional scripts
│   ├── fetch-app-icon.sh
│   └── vxwm-lock
├── .gitignore
├── .gtkrc-2.0
├── README.md
└── tree.md
```

---

## ⌨️ Keybinds

### 🏠 General

| Keybind | Action |
|---|---|
| `Super + Space` | App Launcher (Walker) |
| `Super + Q` | Terminal (Foot) |
| `Super + E` | File Manager (Thunar) |
| `Super + B` | Browser (Firefox) |
| `Super + Shift + R` | Reload Config |

### 🪟 Window Management

| Keybind | Action |
|---|---|
| `Super + H/J/K/L` | Focus Left/Down/Up/Right |
| `Super + Shift + H/J/K/L` | Swap Window |
| `Super + W` | Kill Window |
| `Super + V` | Toggle Floating |
| `Super + F` | Toggle Fullscreen |
| `Super + G` | Toggle Global |
| `Super + I` | Minimize |
| `Super + Shift + I` | Restore Minimized |
| `Super + N` | Switch Layout |
| `Alt + A` | Maximize Screen |

### 📂 Workspaces

| Keybind | Action |
|---|---|
| `Super + 1-9` | Switch to Workspace 1-9 |
| `Super + Shift + 1-9` | Move Window to Workspace 1-9 |
| `Ctrl + Super + Left/Right` | Switch Workspace (scroll) |

### 🔒 Lock & Power

| Keybind | Action |
|---|---|
| `Super + Alt + L` | Lock Screen (random theme) |
| `Super + Shift + E` | Kill MangoWM |

### 📸 Media & System

| Keybind | Action |
|---|---|
| `Print` | Screenshot |
| `Super + Shift + S` | Screenshot Annotate |
| `Super + Shift + V` | Clipboard History |
| `F1` / `F2` / `F3` | Mute / Volume Down / Volume Up |
| `F4` | Mic Mute |
| `XF86Audio*` | Volume Controls |
| `XF86Brightness*` | Brightness Controls |

---

## 🛠️ Scripts

| Script | Location | Description |
|---|---|---|
| `lock.sh` | `~/.local/bin/` | Picks a random SDDM theme, updates config, and locks the screen |
| `sddm-random-theme.sh` | `~/.local/bin/` | Randomizes the SDDM login screen theme |
| `toggle-perf-mode.sh` | `~/.local/bin/` | Toggles between full rice (blur, animations) and performance mode (minimal, max FPS) |
| `wallpaper-maker.sh` | `~/.local/bin/` | Set wallpaper from screenshot, URL, or clipboard image |
| `fetch-app-icon.sh` | `~/.local/bin/` | Auto-downloads missing app icons from iconify.design |

---

## 🎨 SDDM Themes

This setup includes **22 randomized SDDM login themes** that change on every lock:

<details>
<summary><b>🎨 Click to view all themes</b></summary>

| # | Theme |
|---|---|
| 1 | `enfield` |
| 2 | `field` |
| 3 | `forest` |
| 4 | `girl-pillow` |
| 5 | `last-of-us` |
| 6 | `man-bicycle` |
| 7 | `material-you` |
| 8 | `minecraft` |
| 9 | `pixel-coffee` |
| 10 | `pixel-cyberpunk` |
| 11 | `pixel-dusk-city` |
| 12 | `pixel-hollowknight` |
| 13 | `pixel-munchlax` |
| 14 | `pixel-night-city` |
| 15 | `pixel-rainyroom` |
| 16 | `pixel-sakura` |
| 17 | `pixel-skyscrapers` |
| 18 | `pixel-waterfall` |
| 19 | `sword` |
| 20 | `winter` |
| 21 | `women-umbrella` |
| 22 | `wuwa` |

</details>

---

## 🙏 Credits

This rice would not be possible without these amazing projects:

| Project | Author | Description |
|---|---|---|
| [Noctalia Shell](https://noctalia.dev) | Noctalia Team | QML-based desktop shell — bar, launcher, notifications, settings |
| [QuickShell](https://quickshell.outfoxxed.me) | outfoxxed | The QML framework powering Noctalia |
| [MangoWM](https://github.com/DreamMaoMao/mangowc) | DreamMaoMao | Wayland tiling compositor |
| [Walker](https://github.com/abenz1267/walker) | abenz1267 | Fast app launcher |
| [SDDM](https://github.com/sddm/sddm) | SDDM Project | Display manager |
| [Tela Circle Icons](https://github.com/vinceliuice/Tela-circle-icon-theme) | vinceliuice | Icon theme |
| [Bog Cursor](https://github.com/varlesh/bog-cursor) | varlesh | Cursor theme |
| [Arch Linux](https://archlinux.org) | Arch Community | The best distro |

### Inspirations

- [lyne-dots](https://github.com/caioax/lyne-dots) — QuickShell bar structure
- [nxtdots](https://github.com/nxtkofi/nxtdots) — pywal theming approach
- [ArchEclipse](https://github.com/beingsuz/ArchEclipse) — performance mode concept
- [riceverse](https://github.com/vatsalj17/riceverse) — modular dotfile structure

---

## ⚠️ Use My Work? Give Credit

If you've used, forked, or built upon this rice — **please give credit**. A simple mention or link back is enough.

> **Used this work without credit?** [Open an issue](https://github.com/NotVarad35/dotfiles/issues/new?title=Missing%20credit%20for%20NotVarad%27s%20Noctalia%20Rice) and I'll sort it out. No drama — just drop a link. 🤝

---

<div align="center">

**Made with 💜 by [NotVarad](https://github.com/NotVarad35)**

*If you like this setup, consider giving it a ⭐*

</div>
