pragma Singleton

import QtQml
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    property bool active: false
    property bool fullscreenOnFocused: false

    Process {
        id: fullscreenCheck
        command: ["bash", "-c", "mmsg get focusing-client 2>/dev/null || echo '{}'"]
        stdout: StdioSplitParser {
            splitMarker: "\n"
            onLineProduced: {
                try {
                    var data = JSON.parse(line)
                    root.fullscreenOnFocused = data.is_fullscreen === true
                } catch(e) {
                    root.fullscreenOnFocused = false
                }
            }
        }
        running: root.active
    }

    Timer {
        id: pollTimer
        interval: 500
        running: root.active
        repeat: true
        onTriggered: fullscreenCheck.running = true
    }

    property bool isFullscreen: fullscreenOnFocused
}
