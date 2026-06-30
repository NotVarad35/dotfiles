import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.theme
import qs.services

Rectangle {
    id: root

    required property var parentWindow

    implicitWidth: contentLayout.width + 24
    implicitHeight: 32
    color: Theme.surface_container
    radius: height / 2

    Row {
        id: contentLayout
        anchors.centerIn: parent
        spacing: 12

        // WiFi Section
        Item {
            id: wifiSection
            width: wifiRow.implicitWidth
            height: wifiRow.implicitHeight
            anchors.verticalCenter: parent.verticalCenter

            readonly property bool isHovered: wifiMouse.containsMouse
            readonly property bool isConnected: Network.active !== null
            readonly property bool isEnabled: Network.wifiEnabled
            readonly property int signalStrength: isConnected ? Network.active.strength : 0

            Row {
                id: wifiRow
                spacing: 6
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    id: wifiIcon
                    anchors.verticalCenter: parent.verticalCenter
                    font {
                        family: "JetBrainsMono Nerd Font"
                        pixelSize: 14
                    }
                    text: {
                        if (!wifiSection.isEnabled) return "󰖪"
                        if (!wifiSection.isConnected) return "󰖪"
                        if (wifiSection.signalStrength >= 75) return "󰤨"
                        if (wifiSection.signalStrength >= 50) return "󰤥"
                        if (wifiSection.signalStrength >= 25) return "󰤢"
                        return "󰤟"
                    }
                    color: {
                        if (!wifiSection.isEnabled) return Qt.rgba(Theme.on_surface.r, Theme.on_surface.g, Theme.on_surface.b, 0.3)
                        if (!wifiSection.isConnected) return Qt.rgba(Theme.on_surface.r, Theme.on_surface.g, Theme.on_surface.b, 0.4)
                        if (wifiSection.isHovered) return Theme.primary
                        return Qt.rgba(Theme.on_surface.r, Theme.on_surface.g, Theme.on_surface.b, 0.8)
                    }
                    Behavior on color { ColorAnimation { duration: 150 } }
                }

                Text {
                    id: wifiLabel
                    anchors.verticalCenter: parent.verticalCenter
                    font {
                        family: "Inter"
                        pixelSize: 11
                        weight: wifiSection.isConnected ? Font.Medium : Font.Normal
                    }
                    elide: Text.ElideRight
                    width: Math.min(contentWidth, 75)
                    text: {
                        if (!wifiSection.isEnabled) return "Off"
                        if (!wifiSection.isConnected) return "No WiFi"
                        return Network.active.ssid ?? "Connected"
                    }
                    color: {
                        if (!wifiSection.isEnabled || !wifiSection.isConnected) return Qt.rgba(Theme.on_surface.r, Theme.on_surface.g, Theme.on_surface.b, 0.4)
                        if (wifiSection.isHovered) return Theme.on_surface
                        return Qt.rgba(Theme.on_surface.r, Theme.on_surface.g, Theme.on_surface.b, 0.75)
                    }
                    Behavior on color { ColorAnimation { duration: 150 } }
                }
            }

            MouseArea {
                id: wifiMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    wifiPopup.visible = !wifiPopup.visible
                    btPopup.visible = false
                }
            }
        }

        // Separator
        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: 1
            height: 14
            color: Theme.outline_variant
        }

        // Bluetooth Section
        Item {
            id: btSection
            width: btRow.implicitWidth
            height: btRow.implicitHeight
            anchors.verticalCenter: parent.verticalCenter

            readonly property bool isHovered: btMouse.containsMouse
            readonly property bool isEnabled: Bluetooth.adapter?.enabled ?? false
            readonly property bool isConnected: Bluetooth.connectedDevices.length > 0
            readonly property string deviceName: isConnected ? (Bluetooth.connectedDevices[0]?.name ?? "Device") : ""

            Row {
                id: btRow
                spacing: 6
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    id: btIcon
                    anchors.verticalCenter: parent.verticalCenter
                    font {
                        family: "JetBrainsMono Nerd Font"
                        pixelSize: 14
                    }
                    text: {
                        if (!btSection.isEnabled) return "󰂲"
                        if (btSection.isConnected) return "󰂱"
                        return "󰂯"
                    }
                    color: {
                        if (!btSection.isEnabled) return Qt.rgba(Theme.on_surface.r, Theme.on_surface.g, Theme.on_surface.b, 0.3)
                        if (btSection.isHovered) return Theme.primary
                        if (btSection.isConnected) return Qt.rgba(Theme.on_surface.r, Theme.on_surface.g, Theme.on_surface.b, 0.8)
                        return Qt.rgba(Theme.on_surface.r, Theme.on_surface.g, Theme.on_surface.b, 0.5)
                    }
                    Behavior on color { ColorAnimation { duration: 150 } }
                }

                Text {
                    id: btLabel
                    anchors.verticalCenter: parent.verticalCenter
                    font {
                        family: "Inter"
                        pixelSize: 11
                        weight: btSection.isConnected ? Font.Medium : Font.Normal
                    }
                    elide: Text.ElideRight
                    width: Math.min(contentWidth, 75)
                    text: {
                        if (!btSection.isEnabled) return "Off"
                        if (!btSection.isConnected) return "No Device"
                        return btSection.deviceName
                    }
                    color: {
                        if (!btSection.isEnabled || !btSection.isConnected) return Qt.rgba(Theme.on_surface.r, Theme.on_surface.g, Theme.on_surface.b, 0.4)
                        if (btSection.isHovered) return Theme.on_surface
                        return Qt.rgba(Theme.on_surface.r, Theme.on_surface.g, Theme.on_surface.b, 0.75)
                    }
                    Behavior on color { ColorAnimation { duration: 150 } }
                }
            }

            MouseArea {
                id: btMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    btPopup.visible = !btPopup.visible
                    wifiPopup.visible = false
                }
            }
        }
    }

    // WiFi Popup
    PopupWindow {
        id: wifiPopup
        visible: false
        grabFocus: true
        anchor.window: root.parentWindow
        anchor.rect.x: {
            if (!root.parentWindow) return 0
            const desiredX = root.mapToItem(root.parentWindow.contentItem, 0, 0).x - netPanel.implicitWidth / 2 + root.width / 2
            const minX = 10
            const maxX = root.parentWindow.width - netPanel.implicitWidth - 10
            return Math.max(minX, Math.min(maxX, desiredX))
        }
        anchor.rect.y: root.parentWindow ? root.parentWindow.implicitHeight + 6 : 0
        implicitWidth: netPanel.implicitWidth
        implicitHeight: netPanel.implicitHeight
        color: "transparent"

        NetworkPanel {
            id: netPanel
            anchors.fill: parent
            shouldShow: wifiPopup.visible
            onCloseRequested: wifiPopup.visible = false
        }
    }

    // Bluetooth Popup
    PopupWindow {
        id: btPopup
        visible: false
        grabFocus: true
        anchor.window: root.parentWindow
        anchor.rect.x: {
            if (!root.parentWindow) return 0
            const desiredX = root.mapToItem(root.parentWindow.contentItem, 0, 0).x - btPanel.implicitWidth / 2 + root.width / 2
            const minX = 10
            const maxX = root.parentWindow.width - btPanel.implicitWidth - 10
            return Math.max(minX, Math.min(maxX, desiredX))
        }
        anchor.rect.y: root.parentWindow ? root.parentWindow.implicitHeight + 6 : 0
        implicitWidth: btPanel.implicitWidth
        implicitHeight: btPanel.implicitHeight
        color: "transparent"

        BluetoothPanel {
            id: btPanel
            anchors.fill: parent
            shouldShow: btPopup.visible
            onCloseRequested: btPopup.visible = false
        }
    }
}
