import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.Commons
import qs.Widgets

ColumnLayout {
    id: root

    property var pluginApi: null
    property var cfg: pluginApi?.pluginSettings || ({})
    property var defaults: pluginApi?.manifest?.metadata?.defaultSettings || ({})

    property var prefixes: JSON.parse(JSON.stringify(cfg.prefixes ?? defaults.prefixes ?? []))

    spacing: Style.marginL

    function saveSettings() {
        if (!pluginApi) return;
        pluginApi.pluginSettings.prefixes = root.prefixes;
        pluginApi.saveSettings();
    }

    function openDialog(index) {
        var data = index >= 0 ? root.prefixes[index] : { prefix: "", name: "", url: "", icon: "world", enabled: true };
        var isNew = index < 0;

        dialog.prefix = data.prefix;
        dialog.name = data.name;
        dialog.url = data.url;
        dialog.icon = data.icon;
        dialog.index = index;
        dialog.isNew = isNew;
        dialog.open();
    }

    NText {
        text: pluginApi?.tr("settings.prefixes.label")
        font.pointSize: Style.fontSizeL
        font.weight: Font.Medium
        color: Color.mOnSurface
    }

    NText {
        text: pluginApi?.tr("settings.prefixes.description")
        font.pointSize: Style.fontSizeS
        color: Color.mOnSurfaceVariant
        wrapMode: Text.WordWrap
        Layout.fillWidth: true
        Layout.maximumWidth: 400
    }

    Repeater {
        model: root.prefixes

        delegate: Rectangle {
            id: row
            required property int index
            required property var modelData

            Layout.fillWidth: true
            height: 48
            radius: Style.radiusM
            color: Color.mSurfaceContainer

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Style.marginM
                anchors.rightMargin: Style.marginM
                spacing: Style.marginM

                NToggle {
                    checked: modelData.enabled !== false
                    onToggled: {
                        root.prefixes[index].enabled = checked;
                        root.saveSettings();
                    }
                }

                NText {
                    text: ">" + modelData.prefix
                    font.pointSize: Style.fontSizeM
                    font.weight: Font.Medium
                    font.family: "monospace"
                    color: Color.mOnSurface
                }

                NText {
                    text: modelData.name
                    font.pointSize: Style.fontSizeM
                    color: Color.mOnSurfaceVariant
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }

                NButton {
                    text: pluginApi?.tr("settings.prefixes.editDialog")
                    icon: "edit"
                    flat: true
                    onClicked: root.openDialog(index)
                }

                NButton {
                    icon: "trash"
                    flat: true
                    destructive: true
                    onClicked: {
                        root.prefixes.splice(index, 1);
                        root.saveSettings();
                    }
                }
            }
        }
    }

    NButton {
        text: pluginApi?.tr("settings.prefixes.add")
        icon: "plus"
        Layout.fillWidth: true
        onClicked: root.openDialog(-1)
    }

    Dialog {
        id: dialog
        property string prefix: ""
        property string name: ""
        property string url: ""
        property string icon: "world"
        property int index: -1
        property bool isNew: true

        title: isNew ? pluginApi?.tr("settings.prefixes.addDialog") : pluginApi?.tr("settings.prefixes.editDialog")

        standardButtons: Dialog.Ok | Dialog.Cancel

        modal: true
        closePolicy: Popup.CloseOnEscape

        onAccepted: {
            if (!dialog.prefix || !dialog.name || !dialog.url) return;

            var entry = {
                prefix: dialog.prefix.trim(),
                name: dialog.name.trim(),
                url: dialog.url.trim(),
                icon: dialog.icon.trim() || "world",
                enabled: true
            };

            if (dialog.isNew) {
                root.prefixes.push(entry);
            } else {
                root.prefixes[dialog.index] = entry;
            }
            root.saveSettings();
        }

        contentItem: ColumnLayout {
            spacing: Style.marginM
            implicitWidth: 400

            NTextInput {
                label: "Prefix"
                placeholderText: pluginApi?.tr("settings.prefixes.prefixPlaceholder")
                text: dialog.prefix
                onTextChanged: dialog.prefix = text
            }

            NTextInput {
                label: "Name"
                placeholderText: pluginApi?.tr("settings.prefixes.namePlaceholder")
                text: dialog.name
                onTextChanged: dialog.name = text
            }

            NTextInput {
                label: "Search URL"
                placeholderText: pluginApi?.tr("settings.prefixes.urlPlaceholder")
                text: dialog.url
                onTextChanged: dialog.url = text
            }

            NTextInput {
                label: "Icon"
                placeholderText: pluginApi?.tr("settings.prefixes.iconPlaceholder")
                text: dialog.icon
                onTextChanged: dialog.icon = text
            }
        }
    }
}
