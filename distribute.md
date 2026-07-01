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





















Architecture Overview
It's not a single "app launcher" — it's a modular, provider-based search system with 8 providers, each contributing results to a unified search UI. All 16 files in Modules/Panels/Launcher/ plus wiring in IPCService.qml and PanelService.qml.
Trigger Chain
Super+Space (mango keybind)
  → qs -c noctalia-shell ipc call launcher toggle
    → IPCService.qml:319-334 (IpcHandler "launcher")
      → PanelService.qml:
          overlay mode? → LauncherOverlayWindow (separate WlrLayer.Overlay window)
          normal mode?  → Launcher.qml (SmartPanel attached to bar)
            → LauncherCore.qml (shared core logic)
The IPC handler (line 317-406) exposes 6 toggle modes: toggle, clipboard, command, emoji, windows, settings — each setting the search prefix (e.g., >clip , >emoji , >win ).
Core Engine: LauncherCore.qml (909 lines)
This is the heart. It's a Rectangle embedded by both Launcher.qml (bar-attached panel) and LauncherOverlayWindow.qml (overlay mode).
What it does:
- Registers all 8 providers at init (lines 539-603)
- Holds the search state (searchText, selectedIndex, results[])
- Runs the search pipeline on every keystroke (onSearchTextChanged → updateResults(), line 163-167)
- Manages view modes (list/grid/single), density, categories, keyboard navigation
- Delegates navigation math to LauncherNavigation.js (9 functions: selectNext, selectPrevious, page up/down, row/column in grid)
Search flow (lines 293-368):
1. If search starts with >, tries handleCommand() on each provider → command mode
2. Otherwise, calls getResults(searchText) on all providers with handleSearch: true
3. Merges all results, sorts by _score, optionally boosted by usage frequency
4. Sets activeProvider (or null for default app search)
Launch flow (activate(), lines 408-432):
1. Tracks usage if enabled
2. If auto-paste supported → paste text and close
3. Otherwise calls item.onActivate() (defined by each provider)
Providers (8 total)
Each is a QML Item with a standard interface (init(), getResults(), handleSearch, handleCommand(), commands(), etc.):



Provider	File	Mode	What it does
ApplicationsProvider	ApplicationsProvider.qml (715 lines)	Default + search	Reads DesktopEntries.applications, fuzzy-searches name/comment/executable, resolves icons (with auto-fetch fallback), supports pinning + categories + usage tracking, launches via CompositorService.spawn()
ClipboardProvider	ClipboardProvider.qml (457 lines)	>clip	Talks to ClipboardService, shows clipboard history with category chips (images/links/files/code/colors), supports preview panel and auto-paste
EmojiProvider	EmojiProvider.qml (165 lines)	>emoji	Talks to EmojiService, shows emojis in grid view, supports category browsing (recent/people/animals/food/etc.), copies on activate
CommandProvider	CommandProvider.qml (51 lines)	>cmd	Executes shell commands via Quickshell.execDetached(["sh", "-c", expression])
CalculatorProvider	CalculatorProvider.qml (77 lines)	Inline	Detects math expressions (digits + operators), evaluates via AdvancedMath.js, shows result, copies to clipboard on activate
SettingsProvider	SettingsProvider.qml (161 lines)	>settings + inline	Searches Noctalia's own settings index (SettingsSearchService), opens settings panel on activate
SessionProvider	SessionProvider.qml (194 lines)	Inline (2+ chars)	Searches session actions (lock/suspend/reboot/shutdown/logout), executes via CompositorService
WindowsProvider	WindowsProvider.qml (159 lines)	>win + inline	Queries CompositorService.windows, fuzzy-searches titles, focuses window on activate



How ApplicationsProvider launches apps (lines 589-651):
1. Calls launcher.closeImmediately() first (so panel doesn't block focus)
2. Uses Qt.callLater() to defer launch
3. Priority: app.execute() (if quoted args) → custom launch prefix → terminal app → CompositorService.spawn(app.command) → app.execute() → fallback
4. Strips freedesktop placeholders (%U, %F, etc.) in CompositorService.spawn()
Icon resolution (ApplicationsProvider.resolveAppIcon, lines 543-577):
1. Try Quickshell.iconPath() with icon name
2. Try ThemeIcons.iconForAppId()
3. Try app ID as icon name
4. Fallback to "application-x-executable"
5. Auto-fetches missing icons via fetch-app-icon.sh (limited to 5 per reload)
UI: Two Display Modes
Normal mode (Launcher.qml):
- Wraps LauncherCore inside a SmartPanel (attached to bar, positioned via settings)
- Supports a preview panel (ClipboardPreview.qml) that slides out to the side
- Handles animation (panel open/close, category slide transitions)
Overlay mode (LauncherOverlayWindow.qml, 426 lines):
- Separate PanelWindow at WlrLayer.Overlay with exclusive keyboard focus
- Has a dimmer Rectangle that covers the full screen (click to close)
- Custom Shape with inverted corner rendering for the panel background
- Supports the same preview panel as sibling to avoid shadow bleed
- Entrance animation with transform origin calculation
List delegate (LauncherListDelegate.qml, 294 lines):
- Shows icon + name + description + action buttons (pin/unpin)
- Mouse hover with motion detection (only activates after 5px movement)
- Supports image preview (for clipboard), color swatches, emoji display strings, badge overlays
Grid delegate (LauncherGridDelegate.qml, 272 lines):
- Same capabilities but in compact grid layout
- Action buttons overlay in top-right corner
The "Command Mode" System
Typing > in the search bar activates command mode (lines 297-329). Each provider can register commands via a commands() function. Available commands:
- >cmd — shell commands
- >clip — clipboard history
- >emoji — emoji picker
- >win — window switcher
- >settings — settings search
These can also be triggered directly via IPC (ipc call launcher clipboard, ipc call launcher emoji, etc.).
What Would Need Fixing / Rewriting
Likely pain points:
- Complexity: 16 files, 3000+ lines for a search UI. Every provider reimplements the same result-entry pattern with ad-hoc dictionaries
- Fragile async: Qt.callLater() chains everywhere (launch, open, close, category swap)
- ApplicationsProvider icon resolution — the auto-fetch hack (line 367-388) is brittle (only 5 per reload, no retry)
- ClipboardProvider is stateful with isWaitingForData/gotResults flags — race conditions likely
- No error handling in providers — most try/catch are empty or just return empty arrays
- Keyboard navigation split across LauncherCore.qml (handler) and LauncherNavigation.js (math) — easy to break
- Two display modes (SmartPanel vs overlay) duplicate positioning, preview, shadow logic
























in shell theres a option to adding scripts for being idle, 





https://docs.noctalia.dev/v4/getting-started/keybinds/core-and-navigation/
in this there a quick command sepearte keyboard shortcut 
