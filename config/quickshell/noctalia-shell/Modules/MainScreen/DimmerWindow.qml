import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Commons
import qs.Services.UI

PanelWindow {
  id: root

  required property ShellScreen screen

  WlrLayershell.layer: WlrLayer.Bottom
  WlrLayershell.namespace: "noctalia-dimmer-" + (screen?.name || "unknown")
  WlrLayershell.exclusionMode: ExclusionMode.Ignore
  WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

  anchors {
    top: true
    bottom: true
    left: true
    right: true
  }

  color: "transparent"

  property real dimmerOpacity: Settings.data.general.dimmerOpacity ?? 0.8
  property bool isPanelOpen: (PanelService.openedPanel !== null) && (PanelService.openedPanel.screen === screen)
  property bool isPanelClosing: (PanelService.openedPanel !== null) && PanelService.openedPanel.isClosing

  Rectangle {
    anchors.fill: parent
    color: Qt.alpha(Color.mShadow, root.dimmerOpacity)
    opacity: root.isPanelOpen && !root.isPanelClosing ? 1 : 0

    Behavior on opacity {
      enabled: !PanelService.closedImmediately
      NumberAnimation {
        duration: root.isPanelClosing ? Style.animationFaster : Style.animationNormal
        easing.type: Easing.OutQuad
      }
    }

    onOpacityChanged: {
      if (PanelService.closedImmediately) {
        PanelService.closedImmediately = false;
      }
    }
  }
}
