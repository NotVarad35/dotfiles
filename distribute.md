Here's the breakdown:
Already works in Noctalia ✅
- Time/clock, volume/brightness OSD, notifications
- Workspaces (scroll to switch)
- Now playing (MPRIS), emoji picker
- App launcher (search, categories)
- Clipboard, wallpaper selector
- Battery, WiFi, Bluetooth, system tray
- Session/power menu (basic)
- Japanese input (fcitx5)
- SDDM login theming, Bog cursor, Tela icons
Can add as Noctalia QML widgets 🔨
- Theme selector — GUI for sunset/sea/green/dark themes (hook into existing ThemingService)
- Wallpaper maker — screenshot→save, URL upload, Reddit import (as a panel widget, uses existing wallpaper service)
- Launcher search prefixes — goo<space>, yt<space>, gem<space> → add providers in Modules/Panels/Launcher/Providers/
- Auto wallpaper change — timer widget calling wallpaper random IPC
- Power profiles (fan/RGB/backlight) — extend existing PowerProfile.qml
- Screensaver — integrate with idle service
- On-desktop cava — spawn cava as a layer window
- Gradient blur bar — modify bar background styling
- Power menu (shutdown/reboot/hibernate) — improve existing
Better as separate tools 🛠
- Webapp maker — standalone script (generates .desktop files + mangowm keybinds)
- Custom bootloader — GRUB theme, outside shell
- Fastfetch — config file only
- yt-dlp GUI — separate app
- Phone integration — KDE Connect
- Window mode switcher (tile/float) — mangowm layout toggle




