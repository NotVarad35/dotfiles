import QtQuick
import Quickshell
import Quickshell.Io
import qs.theme

Rectangle {
    id: root

    required property var parentWindow

    implicitWidth: Math.min(contentLayout.width + 30, 400)
    implicitHeight: contentLayout.height + 18
    color: Theme.surface_container
    radius: height / 2
    clip: true
    visible: false

    property string playerTitle: ""
    property string playerArtist: ""

    Process {
        id: watcher
        command: [
            "bash", "/home/notvarad/.config/quickshell/scripts/playerctl-watcher.sh"
        ]
        running: true
    }

    Process {
        id: reader
        command: ["cat", "/tmp/playerctl-status"]
        running: true
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: (data) => {
                var line = data.trim()
                if (!line) return
                var parts = line.split("|")
                var status = parts[0] || ""
                root.playerTitle = parts[1] || ""
                root.playerArtist = parts[2] || ""
                root.visible = status === "Playing" || status === "Paused"
            }
        }
    }

    Timer {
        interval: 1000
        repeat: true
        running: true
        onTriggered: {
            if (!reader.running) {
                reader.running = true
            }
        }
    }

    property real hoverScale: 1.0
    Behavior on hoverScale {
        NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
    }

    transform: Scale {
        origin.x: root.width / 2
        origin.y: root.height / 2
        xScale: root.hoverScale
        yScale: root.hoverScale
    }

    HoverHandler {
        cursorShape: Qt.PointingHandCursor
        onHoveredChanged: root.hoverScale = hovered ? 1.08 : 1.0
    }

    Row {
        id: contentLayout
        anchors.centerIn: parent
        spacing: 8

        Text {
            anchors.verticalCenter: parent.verticalCenter
                font { family: "JetBrainsMono Nerd Font"; pixelSize: 18 }
            color: Theme.tertiary
            text: ""
        }

        Rectangle {
            id: textClip
            width: Math.min(textContent.implicitWidth, 250)
            height: textContent.implicitHeight
            color: "transparent"
            anchors.verticalCenter: parent.verticalCenter
            clip: true

            Text {
                id: textContent
                color: Theme.on_surface
                font { family: "Minecraft"; pixelSize: 18 }
                text: root.playerTitle + (root.playerArtist ? "  •  " + root.playerArtist : "")
                x: 0
            }

            Timer {
                id: scrollTimer
                interval: 30
                repeat: true
                running: textContent.implicitWidth > textClip.width
                property real pos: 0

                onTriggered: {
                    pos -= 2
                    if (pos < -(textContent.implicitWidth + 40)) {
                        pos = textClip.width
                    }
                    textContent.x = pos
                }

                onRunningChanged: {
                    if (running) {
                        pos = textClip.width
                        textContent.x = textClip.width
                    } else {
                        pos = 0
                        textContent.x = 0
                    }
                }
            }

            Connections {
                target: textContent
                function onTextChanged() {
                    scrollTimer.pos = textClip.width
                    textContent.x = textClip.width
                }
            }
        }
    }

    TapHandler {
        cursorShape: Qt.PointingHandCursor
        onTapped: Quickshell.execDetached({ command: ["playerctl", "play-pause"] })
    }
}
