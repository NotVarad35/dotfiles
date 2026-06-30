import QtQuick
import Quickshell
import Quickshell.Io
import qs.theme
import "../../services" as QsServices

Item {
    id: root

    readonly property var player: QsServices.Players.activePlayer
    readonly property bool hasPlayer: player !== null
    readonly property bool isPlaying: player?.isPlaying ?? false
    property real progress: 0
    property real duration: player?.length ?? 1
    property real progressPercent: duration > 0 ? progress / duration : 0

    implicitWidth: hasPlayer ? contentRow.implicitWidth + 24 : 70
    implicitHeight: 32
    visible: true

    Timer {
        interval: 1000
        running: hasPlayer && isPlaying
        repeat: true
        onTriggered: posPollProc.running = true
    }

    Process {
        id: posPollProc
        command: ["playerctl", "position"]
        stdout: StdioCollector {
            onStreamFinished: {
                var val = parseFloat(text.trim())
                if (!isNaN(val) && val >= 0)
                    root.progress = val * 1000000
            }
        }
    }

    Process {
        id: lenPollProc
        command: ["playerctl", "metadata", "mpris:length"]
        stdout: StdioCollector {
            onStreamFinished: {
                var val = parseFloat(text.trim())
                if (!isNaN(val) && val > 0)
                    root.duration = val
            }
        }
    }

    onPlayerChanged: lenPollProc.running = true

    onIsPlayingChanged: {
        if (isPlaying) {
            posPollProc.running = true
            lenPollProc.running = true
        } else {
            marqueeAnim.stop()
            titleText.x = titleText.needsScroll ? 0 : (80 - titleText.implicitWidth) / 2
        }
    }

    Row {
        id: noMediaRow
        anchors.centerIn: parent
        spacing: 6
        visible: !hasPlayer
        opacity: !hasPlayer ? 1 : 0

        Behavior on opacity { NumberAnimation { duration: 200 } }

        Text {
            text: "󰎇"
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 16
            color: Theme.on_surface
            opacity: 0.4
            anchors.verticalCenter: parent.verticalCenter
        }
        Text {
            text: "No media"
            font.family: "Minecraft"
            font.pixelSize: 14
            color: Theme.on_surface
            opacity: 0.4
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    MouseArea {
        id: noMediaMouse
        anchors.fill: parent
        visible: !hasPlayer
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
    }

    Row {
        id: contentRow
        anchors.centerIn: parent
        spacing: 8
        visible: hasPlayer
        opacity: hasPlayer ? 1 : 0

        Behavior on opacity { NumberAnimation { duration: 200 } }

        Item {
            width: 20
            height: 20
            anchors.verticalCenter: parent.verticalCenter

            Rectangle {
                visible: root.isPlaying
                anchors.centerIn: parent
                width: 22
                height: 22
                radius: 11
                color: "transparent"
                border.width: 1
                border.color: Theme.tertiary
                opacity: 0.3

                SequentialAnimation on opacity {
                    running: root.isPlaying
                    loops: Animation.Infinite
                    NumberAnimation { to: 0.3; duration: 1000 }
                    NumberAnimation { to: 1.0; duration: 1000 }
                }
            }

            Rectangle {
                id: vinyl
                anchors.centerIn: parent
                width: 16
                height: 16
                radius: 8
                color: Theme.surface_container_low

                RotationAnimation on rotation {
                    running: root.isPlaying
                    from: vinyl.rotation
                    to: vinyl.rotation + 360
                    duration: 2500
                    loops: Animation.Infinite
                }

                Repeater {
                    model: 2
                    Rectangle {
                        anchors.centerIn: parent
                        width: 10 - index * 3
                        height: width
                        radius: width / 2
                        color: "transparent"
                        border.width: 0.5
                        border.color: Theme.on_surface
                        opacity: 0.08
                    }
                }

                Rectangle {
                    anchors.centerIn: parent
                    width: 5
                    height: 5
                    radius: 2.5
                    color: Theme.tertiary
                    Rectangle {
                        anchors.centerIn: parent
                        width: 2
                        height: 2
                        radius: 1
                        color: Theme.surface
                    }
                }
            }
        }

            Item {
                width: 100
                height: parent.height
                anchors.verticalCenter: parent.verticalCenter
                clip: true

                MouseArea {
                    id: contentMouse
                    anchors.fill: parent
                    hoverEnabled: true
                }

                Text {
                    id: titleText
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.player?.trackTitle ?? "Unknown"
                    color: Theme.on_surface
                    font.family: "Minecraft"
                    font.pixelSize: 14

                    property bool needsScroll: implicitWidth > 100

                    x: needsScroll ? 0 : (100 - implicitWidth) / 2

                    Behavior on x {
                        enabled: !marqueeAnim.running
                        NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
                    }

                    SequentialAnimation {
                        id: marqueeAnim
                        running: titleText.needsScroll && root.isPlaying
                        loops: Animation.Infinite

                        PauseAnimation { duration: 2000 }
                        NumberAnimation {
                            target: titleText
                            property: "x"
                            to: -(titleText.implicitWidth + 20)
                            duration: titleText.implicitWidth * 30
                            easing.type: Easing.Linear
                        }
                        PropertyAction {
                            target: titleText
                            property: "x"
                            value: 100
                        }
                        NumberAnimation {
                            target: titleText
                            property: "x"
                            to: 0
                            duration: 300
                            easing.type: Easing.OutCubic
                        }
                    }
                }
        }

            Rectangle {
                width: 1
                height: 16
                anchors.verticalCenter: parent.verticalCenter
                radius: 0.5
                color: Theme.on_surface
                opacity: 0.18
            }

        Row {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2

            Rectangle {
                width: 24
                height: 24
                radius: 12
                color: prevArea.containsMouse ? Theme.tertiary : "transparent"
                opacity: prevArea.containsMouse ? 0.3 : 1

                Text {
                    anchors.centerIn: parent
                    text: "󰒮"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 15
                    color: prevArea.containsMouse ? Theme.tertiary : Theme.on_surface
                }

                MouseArea {
                    id: prevArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: QsServices.Players.previous()
                }
            }

            Rectangle {
                width: 24
                height: 24
                radius: 12
                color: playArea.containsMouse ? Theme.tertiary : Theme.surface_container_high

                Text {
                    anchors.centerIn: parent
                    anchors.horizontalCenterOffset: root.isPlaying ? 0 : 1
                    text: root.isPlaying ? "󰏤" : "󰐊"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 15
                    color: Theme.on_surface
                }

                MouseArea {
                    id: playArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: QsServices.Players.togglePlaying()
                }
            }

            Rectangle {
                width: 24
                height: 24
                radius: 12
                color: nextArea.containsMouse ? Theme.tertiary : "transparent"
                opacity: nextArea.containsMouse ? 0.3 : 1

                Text {
                    anchors.centerIn: parent
                    text: "󰒭"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 15
                    color: nextArea.containsMouse ? Theme.tertiary : Theme.on_surface
                }

                MouseArea {
                    id: nextArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: QsServices.Players.next()
                }
            }
        }

    }
}
