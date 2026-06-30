# Todo

## Legend
- ✅ Done
- ◐ Half done
- 🔄 In progress
- ☐ Pending
- ⏸ Blocked

---

## Theming & Visual

### Desktop Environment Modes
- ☐ **Mode 1: vxwm** — tiling WM (current)
- ☐ **Mode 2: mangowm** — floating WM (planned)

### Icon Themes
- ✅ **Tela Circle** — installed and applied (active)

### Cursor
- ✅ **Bog cursor pack** — converted & applied. Animated cursors (Working in bg.ani, Busy.ani) not converted — needs different tool

### Custom Themes
- ☐ Build theme system (sunset orange, sea blue, green, dark)
- ☐ Gradient blur in taskbar
- ☐ Gradient in dolphin file manager

### SDDM Login Page
- ✅ **SDDM** — 22 qylock themes installed, `random-sddm-theme.sh` randomizes on each lock

### Bootloader
- ☐ Customise bootloader (GRUB theme)

### Wallpaper
- ☐ Auto-change wallpaper on interval
- ☐ Wallpaper maker (screenshot→save, URL upload, Reddit import)

### Fastfetch
- ◐ **Fastfetch** — config exists with sakuta.jpeg logo, key colors set. Could be enhanced with more info / better layout

---

## Bar & Desktop

### Currently Implemented (Quickshell)
- ✅ Time/clock (Calendar.qml)
- ✅ Volume OSD (VolumePopup.qml)
- ✅ Brightness OSD (BrightnessPopup.qml)
- ✅ Notifications dropdown (NotifPopup.qml)
- ✅ Workspaces display + scroll to switch (Workspaces.qml)
- ✅ Now playing (NowPlaying.qml — playerctl/MPRIS)
- ✅ Keyboard layout switcher (SinkSwitcher.qml — EN/JP via fcitx5)
- ✅ Japanese input (fcitx5 + mozc)
- ✅ Clipboard utility (Clipboard.qml)
- ✅ Wallpaper selector (WallpaperSelector.qml)
- ✅ App launcher (Launcher.qml)
- ✅ Emoji picker (EmojiPicker.qml)
- ✅ System stats (SystemStats.qml — CPU/RAM/Disk, Pipewire sink, UPower battery)

### Power Menu
- ☐ **Power menu** — current implementation in SystemStats.qml is temporary. Needs proper design with shutdown, reboot, suspend, hibernate, lock

### Alt-Tab
- ☐ Customise alt-tab switcher

### WiFi Password Input
- ☐ **WiFi password dialog** — `NetworkPanel.qml` password TextField doesn't receive keyboard focus when dialog opens; keystrokes go to PopupWindow instead. Priority: not important

### Cava
- ☐ Cava on desktop without terminal background

### Screensaver
- ☐ Screensaver (from omarchy)

### Power Profiles
- ☐ Power profiles for gaming laptop (fan speed, RGB keyboard, backlight levels)

---

## Launcher & Search

### Universal Search
- ☐ Search prefix routing:
  - `goo<space>` → Google results
  - `yt<space>` → YouTube results
  - `gem<space>` → Gemini AI results

### Webapp Maker
- ☐ GUI tool to create webapps with meta keybind → import to launcher

---

## Apps to Install

### Communication & Cloud
- ☐ Browser (Brave/Firefox — migrate from Chrome: passwords, login info, extensions)
- ☐ Tailscale
- ☐ VPN (free, good speed)
- ☐ KDE Connect (phone integration)

### Development
- ☐ VSCode
- ☐ Code Studio (C#/Unity)
- ☐ Lazyvim (personal config)
- ☐ Git (installed, config needed)
- ☐ C++, C#, Java toolchains

### Media & Gaming
- ☐ Davinci Resolve
- ☐ Lutris / Heroic Games Launcher
- ☐ Steam
- ☐ qBittorrent
- ☐ Multimc / Modrinth (Minecraft)
- ☐ Wine (Cosmic Byte Firestorm mouse software)

### Productivity
- ✅ Obsidian (notes) — AppImage at ~/.local/bin/obsidian.AppImage, .desktop entry added, launches via app launcher
- ☐ yt-dlp GUI with multi-link paste
- ☐ Kitty terminal (personal config)
- ☐ Flatpak GUI
- ☐ XFCE settings

### Fonts
- ✅ JetBrains Mono Nerd Font
- ✅ Minecraft font
- ☐ Pixel font

---

## Misc

### Phone Integration
- ☐ Answer calls from laptop via KDE Connect

### Performance
- ☐ Optimise for fast startup and ease of use

### Notes
- `~/.config/mango/config.conf` has fcitx5 env vars and XKB layout `us,jp` with `grp:lalt_lshift_toggle`
- Power menu temp implementation in `SystemStats.qml:104` → `PopupWindow` with Suspend/Reboot/ShutDown
- Japanese input via fcitx5-remote (`toggle-jp.sh`), no daemon needed







themes :


enfield
field
forest
girl-pillow
last-of-us
man-bicycle
material-you
minecraft
pixel-coffee
pixel-cyberpunk
pixel-dusk-city
pixel-hollowknight
pixel-munchlax
pixel-night-city
pixel-rainyroom
pixel-sakura
pixel-skyscrapers
pixel-waterfall
sword
winter
women-umbrella
wuwa
