import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import qs.theme

/**
 * A unified system status indicator for Audio (Pipewire) and Power (UPower).
 */
Rectangle {
    id: root

    required property var parentWindow

    // --- Layout Configuration ---
    implicitWidth: contentLayout.width + 30
    implicitHeight: contentLayout.height + 18
    color: Theme.surface_container
    radius: height / 2

    // --- Audio State Management ---
    readonly property var activeSink: Pipewire.defaultAudioSink
    readonly property bool isMuted: activeSink?.audio?.muted ?? true
    readonly property real volumeLevel: activeSink?.audio?.volume ?? 0.0

    /** Ensures Pipewire sink stays reactive to external system changes. */
    PwObjectTracker {
        objects: root.activeSink ? [root.activeSink] : []
    }

    Row {
        id: contentLayout
        anchors.centerIn: parent
        spacing: 16

        // --- Mango Icon ---
        Image {
            id: mangoIcon
            source: "../../mangowm.svg"
            sourceSize.width: 16
            sourceSize.height: 16
            anchors.verticalCenter: parent.verticalCenter

            TapHandler {
                cursorShape: Qt.PointingHandCursor
                onTapped: powerMenu.visible = !powerMenu.visible
            }
        }

        // --- Separator ---
        Rectangle {
            width: 1
            height: 16
            color: Theme.outline_variant
            anchors.verticalCenter: parent.verticalCenter
        }

        // --- Audio Module ---
        Row {
            id: volumeModule
            spacing: 8

            Text {
                id: volumeIcon
                anchors.verticalCenter: parent.verticalCenter
                font {
                    family: "JetBrainsMono Nerd Font"
                    pixelSize: 16
                }
                color: root.isMuted ? Theme.critical : Theme.primary

                text: {
                    if (!root.activeSink?.audio)
                        return ""; // No device
                    if (root.isMuted)
                        return "";           // Muted
                    if (root.volumeLevel >= 0.6)
                        return ""; // High
                    if (root.volumeLevel >= 0.3)
                        return ""; // Mid
                    return "";                              // Low
                }
            }

            Text {
                id: volumeLabel
                anchors.verticalCenter: parent.verticalCenter
                color: Theme.on_surface
                font {
                    family: "Google Sans Medium"
                    pixelSize: 16
                }
                text: root.activeSink?.audio ? Math.round(root.volumeLevel * 100) + "%" : "--%"
            }

            TapHandler {
                onTapped: if (root.activeSink?.audio)
                    root.activeSink.audio.muted = !root.isMuted
                cursorShape: Qt.PointingHandCursor
            }
        }
    }

        PopupWindow {
            id: powerMenu
            grabFocus: true
            anchor.window: root.parentWindow
        anchor.rect.x: mangoIcon.x
        anchor.rect.y: root.parentWindow.implicitHeight + 8
        implicitWidth: 200
        implicitHeight: powerColumn.height + 24
        color: "transparent"

        Rectangle {
            anchors.fill: parent
            color: Theme.surface_container_low
            radius: 16
            border.color: Theme.outline_variant
            border.width: 1

            Column {
                id: powerColumn
                anchors { left: parent.left; right: parent.right; top: parent.top; margins: 8 }
                spacing: 4

                Repeater {
                    model: [
                        { icon: "", label: "Lock", cmd: ["loginctl", "lock-session"] },
                        { icon: "", label: "Suspend", cmd: ["systemctl", "suspend"] },
                        { icon: "", label: "Hibernate", cmd: ["systemctl", "hibernate"] },
                        { icon: "", label: "Log Out", cmd: ["bash", "-c", "loginctl terminate-user $(whoami)"] },
                        { icon: "", label: "Reboot", cmd: ["systemctl", "reboot"] },
                        { icon: "", label: "Shut Down", cmd: ["systemctl", "poweroff"] },
                    ]

                    delegate: Item {
                        width: parent.width
                        height: 36

                        Rectangle {
                            anchors.fill: parent
                            radius: 10
                            color: mouseArea.containsMouse ? Theme.surface_variant : "transparent"

                            Row {
                                anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; leftMargin: 12; rightMargin: 12 }
                                spacing: 12

                                Text {
                                    text: modelData.icon
                                    anchors.verticalCenter: parent.verticalCenter
                                    font { family: "JetBrainsMono Nerd Font"; pixelSize: 16 }
                                    color: Theme.on_surface
                                }

                                Text {
                                    text: modelData.label
                                    anchors.verticalCenter: parent.verticalCenter
                                    font { family: "Google Sans Medium"; pixelSize: 14 }
                                    color: Theme.on_surface
                                }
                            }

                            TapHandler {
                                id: mouseArea
                                cursorShape: Qt.PointingHandCursor
                                onTapped: {
                                    powerMenu.visible = false
                                    Quickshell.execDetached({ command: modelData.cmd })
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
