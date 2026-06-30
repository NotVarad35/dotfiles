pragma Singleton

import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import QtQuick

Singleton {
    id: root

    readonly property var list: Mpris.players.values
    property bool active: true
    property var activePlayer: null

    Connections {
        target: Mpris.players
        function onValuesChanged() { root.updateActivePlayer() }
    }

    function updateActivePlayer() {
        var newActive = null
        for (var i = 0; i < list.length; i++) {
            if (list[i]?.isPlaying) {
                newActive = list[i]
                break
            }
        }
        if (activePlayer !== newActive)
            activePlayer = newActive
    }

    Component.onCompleted: updateActivePlayer()

    Timer {
        interval: 2000
        running: root.active && list.length > 0
        repeat: true
        triggeredOnStart: true
        onTriggered: root.updateActivePlayer()
    }

    function togglePlaying(name = "") {
        if (name) ctrlProc.exec(["playerctl", "--player", name, "play-pause"])
        else ctrlProc.exec(["playerctl", "play-pause"])
    }

    function next(name = "") {
        if (name) ctrlProc.exec(["playerctl", "--player", name, "next"])
        else ctrlProc.exec(["playerctl", "next"])
    }

    function previous(name = "") {
        if (name) ctrlProc.exec(["playerctl", "--player", name, "previous"])
        else ctrlProc.exec(["playerctl", "previous"])
    }

    Process { id: ctrlProc }
}
