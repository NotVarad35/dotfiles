import QtQuick
import qs.services
import qs.theme

Item {
    id: root

    implicitWidth: timeLabel.implicitWidth + 32
    implicitHeight: timeLabel.implicitHeight + 16

    Rectangle {
        anchors.centerIn: parent
        width: root.implicitWidth
        height: root.implicitHeight
        radius: height / 2
        color: Theme.surface_container

        Text {
            id: timeLabel
            anchors.centerIn: parent
            text: Time.time
            color: Theme.on_surface
            font {
                family: "Google Sans"
                pointSize: 14
                weight: Font.Medium
            }
        }
    }
}
