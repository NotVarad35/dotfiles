import QtQuick
import Quickshell
import Quickshell.Io
import qs.theme

Rectangle {
    id: root

    required property var parentWindow

    implicitWidth: contentLayout.width + 20
    implicitHeight: contentLayout.height + 18
    color: Theme.surface_container
    radius: height / 2
    visible: true

    property string currentLayout: ""

    Process {
        id: layoutReader
        command: ["bash", "-c", "fcitx5-remote -n 2>/dev/null || echo ''"]
        running: true
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: (data) => {
                var name = data.trim()
                if (!name) return
                root.currentLayout = name
            }
        }
    }

    Timer {
        id: pollTimer
        interval: 2000
        repeat: true
        running: true
        onTriggered: {
            if (!layoutReader.running) {
                layoutReader.running = true
            }
        }
    }

    Row {
        id: contentLayout
        anchors.centerIn: parent
        spacing: 6

        Text {
            anchors.verticalCenter: parent.verticalCenter
            font { family: "JetBrainsMono Nerd Font"; pixelSize: 14 }
            color: Theme.primary
            text: ""
        }

        Text {
            id: layoutLabel
            anchors.verticalCenter: parent.verticalCenter
            color: Theme.on_surface
            font { family: "Minecraft"; pixelSize: 14 }
            text: root.currentLayout === "mozc" ? "JP" : "EN"
        }
    }

    TapHandler {
        cursorShape: Qt.PointingHandCursor
        onTapped: {
            Quickshell.execDetached({
                command: ["bash", "/home/notvarad/.config/quickshell/scripts/toggle-jp.sh"]
            })
        }
    }
}
