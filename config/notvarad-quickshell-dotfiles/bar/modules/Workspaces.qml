import QtQuick
import Quickshell
import Quickshell.Io
import qs.theme

Item {
    id: root
    property string targetMonitor: ""

    readonly property var kanji: ["一","二","三","四","五","六","七","八","九"]

    property var allTags: ([])
    property var activeTags: ([])
    property string monitorName: ""

    property var visibleTags: {
        if (!root.allTags || root.allTags.length === 0) return [];
        return root.allTags.filter(t => (t.client_count ?? 0) > 0 || root.activeTags.includes(t.index));
    }

    visible: root.visibleTags.length > 0
    implicitWidth: visible ? tagRow.width + 16 : 0
    implicitHeight: visible ? tagRow.height + 16 : 0

    Behavior on implicitWidth {
        NumberAnimation { duration: 150; easing.type: Easing.OutQuad }
    }

    Process {
        id: discoverProc
        command: ["sh", "-c", "mmsg get all-monitors 2>/dev/null | python3 -c \"import sys,json; d=json.load(sys.stdin); m=d.get('monitors',[]); print(m[0]['name'] if m else '')\""]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                let name = text.trim();
                if (name.length > 0) {
                    root.monitorName = root.targetMonitor.length > 0 ? root.targetMonitor : name;
                }
            }
        }
    }

    Process {
        id: watchProc
        command: ["mmsg", "watch", "tags", root.monitorName]
        running: false
        stdout: SplitParser {
            onRead: (line) => {
                if (!line || line.trim().length === 0) return;
                try {
                    let data = JSON.parse(line.trim());
                    root.allTags = data.tags ?? [];
                    root.activeTags = data.active_tags ?? [];
                } catch (e) {}
            }
        }
    }

    onMonitorNameChanged: {
        if (monitorName.length > 0) {
            watchProc.running = true;
        }
    }

    onTargetMonitorChanged: {
        if (targetMonitor.length > 0) {
            root.monitorName = targetMonitor;
        }
    }

    function switchTag(index) {
        Quickshell.execDetached({
            command: ["mmsg", "dispatch", "view," + index]
        });
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.surface_container
        radius: height / 2
    }

    Row {
        id: tagRow
        x: 8
        y: 8
        spacing: 4

        Repeater {
            model: root.visibleTags

            delegate: Rectangle {
                id: tagDot
                width: 26
                height: 26
                radius: 6

                required property var modelData
                readonly property int tagIndex: modelData.index
                readonly property bool isActive: root.activeTags.includes(tagIndex)

                color: tagDot.isActive ? "#00aaff" : "#2a2a5a"
                opacity: tagDot.isActive ? 0.9 : 0.7

                Behavior on color {
                    ColorAnimation { duration: 150; easing.type: Easing.OutQuad }
                }

                Text {
                    anchors.centerIn: parent
                    text: root.kanji[tagIndex - 1]
                    color: tagDot.isActive ? "#ffffff" : "#8888bb"
                    font.pixelSize: 13
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: root.switchTag(tagDot.tagIndex)
                }
            }
        }
    }
}
