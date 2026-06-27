import QtQuick
import Quickshell
import qs.theme

PopupWindow {
    id: root

    required property var parentWindow
    implicitWidth: 380
    implicitHeight: 460
    color: "transparent"

    grabFocus: true
    anchor.window: parentWindow
    anchor.rect.x: (parentWindow.width - width) / 2
    anchor.rect.y: parentWindow.implicitHeight + 8

    Rectangle {
        anchors.fill: parent
        color: Theme.surface_container_low
        radius: 32

        border.color: Theme.outline_variant
        border.width: 1

        CalendarGrid {
            anchors { fill: parent; topMargin: 20; leftMargin: 24; rightMargin: 24; bottomMargin: 20 }
            isWindowVisible: root.visible
            onRequestClose: root.visible = false
        }
    }
}
