 WEBAPP MAKER — Plan
What it does
Creates Brave-based webapps (standalone chromeless windows) with a Walker-driven wizard flow.
Flow
1. Trigger: Desktop entry at ~/.local/share/applications/webapp-maker.desktop → appears in Noctalia app launcher as "WEBAPP MAKER"
2. Input method: Sequential walker -d (dmenu) calls for each field
3. Fields: Name → Description → URL → Icon source (Auto/File/URL/Skip) → Keybind (optional)
4. Icon options:
- Auto: fetch-app-icon.sh "WebApp-<name>" (Iconify API)
- File: zenity --file-selection for local image
- URL: Walker prompt → curl download
- Skip: generic icon
Generated files (per webapp)
File	Purpose
~/.local/bin/webapp-<name>.sh	Launch wrapper
~/.local/share/applications/WebApp-<name>.desktop	App launcher entry
~/.local/share/icons/.../WebApp-<name>.svg	Custom icon
Mango config	Optional keybind: bind=SUPER,<key>,spawn,webapp-<name>
The wrapper script (key part)
#!/bin/bash
# Config (editable by WEBAPP MANAGER later)
NAME="animepahe"
URL="https://animepahe.pw"
EXTRA_FLAGS=""
# --- END CONFIG ---

# Clean session files (no kiosk, just hygiene)
brave-origin --app="$URL" --no-first-run --class "WebApp-$NAME"
Uses Brave's --app=URL flag — creates a standalone chromeless window with no navigation, no tabs, no session leakage. Works while regular Brave is open. Alt+F4 to close. No cleanup needed.
The maker script (webapp-maker.sh)
- Walker prompts for each field
- Escapes special chars before embedding
- Checks for existing webapp with same name (overwrite prompt)
- Generates wrapper + desktop entry + icon + optional keybind
- Notifies on success
WEBAPP MANAGER (next phase)
- Scans ~/.local/bin/webapp-*.sh for installed webapps
- Walker list → select → actions: Delete, Change Icon, Edit URL/Name/Keybind
- Reads config by parsing lines between --- END CONFIG ---
- Rewrites the wrapper script
Key differences from Firefox approach
- No --kiosk flag → no session persistence problem
- No profile sharing → no state leakage to main browser
- Brave handles app isolation natively
- The wrapper is simpler (no cleanup loops, no inotifywait)
