import Quickshell
import Quickshell.Wayland
import QtQuick
import "modules"
import qs.theme

Variants {
    id: root
    model: Quickshell.screens
    delegate: PanelWindow {
        id: mainBar
        required property var modelData
        screen: modelData

        // --- Layer Shell Configuration ---
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "quickshell-topbar"
        visible: true

        // --- Geometry & Positioning ---
        anchors {
            top: true
            left: true
            right: true
        }
        color: "transparent"
        implicitHeight: Layout.topBarHeight

        // --- Core Modules ---
        SystemStats {
            id: statusModule
            parentWindow: mainBar
            anchors {
                left: parent.left
                leftMargin: 15
                verticalCenter: parent.verticalCenter
            }
        }
        Calendar {
            id: calendarModule
            parentWindow: mainBar
            anchors {
                left: statusModule.right
                leftMargin: 8
                verticalCenter: parent.verticalCenter
            }
        }
        NowPlaying {
            id: nowPlayingModule
            parentWindow: mainBar
            anchors {
                horizontalCenter: parent.horizontalCenter
                verticalCenter: parent.verticalCenter
            }
        }
        SinkSwitcher {
            id: sinkModule
            parentWindow: mainBar
            anchors {
                right: workspaceModule.left
                rightMargin: 8
                verticalCenter: parent.verticalCenter
            }
        }
        Workspaces {
            id: workspaceModule
            targetMonitor: modelData.name
            anchors {
                right: parent.right
                rightMargin: 15
                verticalCenter: parent.verticalCenter
            }
        }
    }
}
