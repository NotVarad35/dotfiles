import QtQuick
import Quickshell
import qs.theme

PopupWindow {
    id: root

    required property var parentWindow
    implicitWidth: 700
    implicitHeight: 480
    color: "transparent"

    grabFocus: true
    anchor.window: parentWindow
    anchor.rect.x: 15
    anchor.rect.y: parentWindow.implicitHeight + 8

    Rectangle {
        anchors.fill: parent
        color: Theme.surface_container_low
        radius: 32

        border.color: Theme.outline_variant
        border.width: 1

        CalendarGrid {
            anchors.fill: parent
            isWindowVisible: root.visible
            onRequestClose: root.visible = false
        }
    }
}
