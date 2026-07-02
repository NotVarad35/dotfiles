import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Widgets

Rectangle {
  id: root

  property bool visibleAction: false
  property string actionLabel: "Refetch page"
  property string actionIcon: "refresh"
  property bool actionEnabled: true
  property bool busy: false
  property string busyLabel: "Fetching..."
  signal triggered()

  readonly property bool clickable: actionEnabled && !busy

  visible: visibleAction
  radius: Style.radiusS
  color: clickable && mouseArea.containsMouse ? Qt.alpha(Color.mHover, 0.82) : Qt.alpha(Color.mSurface, 0.9)
  border.width: 1
  border.color: Qt.alpha(Style.capsuleBorderColor, 0.7)
  opacity: actionEnabled ? 1 : 0.56
  implicitWidth: actionRow.implicitWidth + Style.marginS * 2
  implicitHeight: actionRow.implicitHeight + Style.marginXS * 2

  RowLayout {
    id: actionRow
    anchors.centerIn: parent
    spacing: Style.marginXS

    NIcon {
      icon: root.actionIcon
      pointSize: Style.fontSizeXS
      color: root.actionEnabled ? Color.mPrimary : Color.mOnSurfaceVariant
    }

    NText {
      text: root.busy ? root.busyLabel : root.actionLabel
      pointSize: Style.fontSizeXS
      color: root.actionEnabled ? Color.mOnSurface : Color.mOnSurfaceVariant
    }
  }

  MouseArea {
    id: mouseArea
    anchors.fill: parent
    enabled: root.clickable
    hoverEnabled: true
    cursorShape: root.clickable ? Qt.PointingHandCursor : Qt.ArrowCursor
    onClicked: {
      if (root.clickable) {
        root.triggered();
      }
    }
  }
}
