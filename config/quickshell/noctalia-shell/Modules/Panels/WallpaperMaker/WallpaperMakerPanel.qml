import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Commons
import qs.Modules.MainScreen
import qs.Services.UI
import qs.Widgets

SmartPanel {
  id: root

  readonly property string wallpaperDir: Settings.preprocessPath(Settings.data.wallpaper.directory)

  preferredWidth: 600 * Style.uiScaleRatio
  preferredHeight: 500 * Style.uiScaleRatio
  preferredWidthRatio: 0.45
  preferredHeightRatio: 0.45

  property int currentTab: 0
  property string lastSavedPath: ""

  function timestampName(prefix) {
    var d = new Date();
    var pad = n => String(n).padStart(2, "0");
    return prefix + "-" + d.getFullYear() + pad(d.getMonth() + 1) + pad(d.getDate()) + "-" + pad(d.getHours()) + pad(d.getMinutes()) + pad(d.getSeconds()) + ".png";
  }

  function applyWallpaper(path) {
    WallpaperService.changeWallpaper(path);
    lastSavedPath = path;
  }

  function saveAndNotify(path) {
    ToastService.showNotice("Wallpaper Maker", "Saved: " + path.split('/').pop());
  }

  panelContent: Rectangle {
    id: panelContent
    color: "transparent"

    ColumnLayout {
      anchors.fill: parent
      anchors.margins: Style.marginL
      spacing: Style.marginM

      // Header
      NBox {
        Layout.fillWidth: true
        Layout.preferredHeight: headerRow.implicitHeight + Style.margin2L
        color: Color.mSurfaceVariant

        RowLayout {
          id: headerRow
          anchors.fill: parent
          anchors.margins: Style.marginL
          spacing: Style.marginM

          NIcon {
            icon: "image"
            pointSize: Style.fontSizeXXL
            color: Color.mPrimary
          }

          NText {
            text: "Wallpaper Maker"
            pointSize: Style.fontSizeL
            font.weight: Style.fontWeightBold
            color: Color.mOnSurface
            Layout.fillWidth: true
          }

          NIconButton {
            icon: "close"
            tooltipText: I18n.tr("common.close")
            baseSize: Style.baseWidgetSize * 0.8
            onClicked: root.close()
          }
        }
      }

      // Tab bar
      NTabBar {
        id: tabBar
        Layout.fillWidth: true
        currentIndex: root.currentTab
        spacing: Style.marginM
        distributeEvenly: true

        onCurrentIndexChanged: root.currentTab = currentIndex

        NTabButton {
          text: "Screenshot"
          tabIndex: 0
          checked: tabBar.currentIndex === 0
        }
        NTabButton {
          text: "From URL"
          tabIndex: 1
          checked: tabBar.currentIndex === 1
        }
        NTabButton {
          text: "From Reddit"
          tabIndex: 2
          checked: tabBar.currentIndex === 2
        }
      }

      // Content
      NBox {
        Layout.fillWidth: true
        Layout.fillHeight: true
        color: Color.mSurfaceVariant

        StackLayout {
          anchors.fill: parent
          anchors.margins: Style.marginL
          currentIndex: root.currentTab

          // Tab 0: Screenshot
          ColumnLayout {
            spacing: Style.marginL

            NIcon {
              icon: "camera"
              pointSize: Style.fontSizeXXXL * 2
              color: Color.mPrimary
              Layout.alignment: Qt.AlignHCenter
            }

            NText {
              text: "Capture your screen and save it as wallpaper"
              pointSize: Style.fontSizeM
              color: Color.mOnSurfaceVariant
              Layout.alignment: Qt.AlignHCenter
              horizontalAlignment: Text.AlignHCenter
              Layout.fillWidth: true
            }

            Item { Layout.fillHeight: true }

            RowLayout {
              Layout.fillWidth: true
              spacing: Style.marginL
              Layout.alignment: Qt.AlignHCenter

              NButton {
                icon: "video-display"
                text: "Fullscreen"
                fontSize: Style.fontSizeL
                implicitWidth: 180 * Style.uiScaleRatio
                onClicked: {
                  var p = root.wallpaperDir + "/" + root.timestampName("screenshot");
                  var cmd = "grim -o " + Quickshell.screens[0].name + " " + p;
                  var processString = `
                  import QtQuick
                  import Quickshell.Io
                  Process {
                    command: ${JSON.stringify(["sh", "-c", cmd])}
                  }
                  `;
                  var proc = Qt.createQmlObject(processString, root, "screenshotProc");
                  proc.exited.connect(function (exitCode) {
                    if (exitCode === 0) {
                      root.applyWallpaper(p);
                      root.saveAndNotify(p);
                    }
                    proc.destroy();
                  });
                }
              }

              NButton {
                icon: "image-crop"
                text: "Region"
                fontSize: Style.fontSizeL
                implicitWidth: 180 * Style.uiScaleRatio
                onClicked: {
                  var p = root.wallpaperDir + "/" + root.timestampName("screenshot");
                  var cmd = "grim -g \"$(slurp)\" " + p;
                  var processString = `
                  import QtQuick
                  import Quickshell.Io
                  Process {
                    command: ${JSON.stringify(["sh", "-c", cmd])}
                  }
                  `;
                  var proc = Qt.createQmlObject(processString, root, "screenshotRegionProc");
                  proc.exited.connect(function (exitCode) {
                    if (exitCode === 0) {
                      root.applyWallpaper(p);
                      root.saveAndNotify(p);
                    }
                    proc.destroy();
                  });
                }
              }
            }

            Item { Layout.fillHeight: true }
          }

          // Tab 1: URL
          ColumnLayout {
            spacing: Style.marginL

            NIcon {
              icon: "link"
              pointSize: Style.fontSizeXXXL * 2
              color: Color.mPrimary
              Layout.alignment: Qt.AlignHCenter
            }

            NText {
              text: "Download an image from a URL and save it as wallpaper"
              pointSize: Style.fontSizeM
              color: Color.mOnSurfaceVariant
              Layout.alignment: Qt.AlignHCenter
              horizontalAlignment: Text.AlignHCenter
              Layout.fillWidth: true
            }

            NTextInput {
              id: urlInput
              Layout.fillWidth: true
              placeholderText: "https://example.com/image.png"
              label: "Image URL"
            }

            NTextInput {
              id: urlFilenameInput
              Layout.fillWidth: true
              placeholderText: "image-name.png"
              label: "Filename"
            }

            Item { Layout.fillHeight: true }

            RowLayout {
              Layout.alignment: Qt.AlignHCenter
              spacing: Style.marginL

              NButton {
                icon: "download"
                text: "Download & Apply"
                fontSize: Style.fontSizeL
                enabled: urlInput.text.trim().length > 0
                implicitWidth: 220 * Style.uiScaleRatio
                onClicked: {
                  var url = urlInput.text.trim();
                  var filename = urlFilenameInput.text.trim();
                  if (!filename) {
                    var parts = url.split('/').filter(s => s.length > 0);
                    filename = parts[parts.length - 1] || "wallpaper.png";
                  }
                  var p = root.wallpaperDir + "/" + filename;
                  var cmd = "curl -L -o \"" + p + "\" \"" + url + "\"";
                  var processString = `
                  import QtQuick
                  import Quickshell.Io
                  Process {
                    command: ${JSON.stringify(["sh", "-c", cmd])}
                  }
                  `;
                  var proc = Qt.createQmlObject(processString, root, "urlDownloadProc");
                  proc.exited.connect(function (exitCode) {
                    if (exitCode === 0) {
                      root.applyWallpaper(p);
                      root.saveAndNotify(p);
                    } else {
                      ToastService.showError("Download failed");
                    }
                    proc.destroy();
                  });
                }
              }
            }

            Item { Layout.fillHeight: true }
          }

          // Tab 2: Reddit
          ColumnLayout {
            spacing: Style.marginL

            NIcon {
              icon: "reddit"
              pointSize: Style.fontSizeXXXL * 2
              color: Color.mPrimary
              Layout.alignment: Qt.AlignHCenter
            }

            NText {
              text: "Import an image from Reddit"
              pointSize: Style.fontSizeM
              color: Color.mOnSurfaceVariant
              Layout.alignment: Qt.AlignHCenter
              horizontalAlignment: Text.AlignHCenter
              Layout.fillWidth: true
            }

            NText {
              text: "Paste the direct image URL (right-click → copy image link on Reddit)"
              pointSize: Style.fontSizeS
              color: Color.mOnSurface
              Layout.alignment: Qt.AlignHCenter
              horizontalAlignment: Text.AlignHCenter
              Layout.fillWidth: true
              wrapMode: Text.WordWrap
            }

            NTextInput {
              id: redditUrlInput
              Layout.fillWidth: true
              placeholderText: "https://i.redd.it/..."
              label: "Image URL"
            }

            NTextInput {
              id: redditFilenameInput
              Layout.fillWidth: true
              placeholderText: "reddit-wallpaper.png"
              label: "Filename"
            }

            Item { Layout.fillHeight: true }

            RowLayout {
              Layout.alignment: Qt.AlignHCenter
              spacing: Style.marginL

              NButton {
                icon: "download"
                text: "Import & Apply"
                fontSize: Style.fontSizeL
                enabled: redditUrlInput.text.trim().length > 0
                implicitWidth: 220 * Style.uiScaleRatio
                onClicked: {
                  var url = redditUrlInput.text.trim();
                  var filename = redditFilenameInput.text.trim();
                  if (!filename) {
                    var parts = url.split('/').filter(s => s.length > 0);
                    filename = parts[parts.length - 1] || "reddit-wallpaper.png";
                  }
                  var p = root.wallpaperDir + "/" + filename;
                  var cmd = "curl -L -o \"" + p + "\" \"" + url + "\"";
                  var processString = `
                  import QtQuick
                  import Quickshell.Io
                  Process {
                    command: ${JSON.stringify(["sh", "-c", cmd])}
                  }
                  `;
                  var proc = Qt.createQmlObject(processString, root, "redditDownloadProc");
                  proc.exited.connect(function (exitCode) {
                    if (exitCode === 0) {
                      root.applyWallpaper(p);
                      root.saveAndNotify(p);
                    } else {
                      ToastService.showError("Download failed");
                    }
                    proc.destroy();
                  });
                }
              }
            }

            Item { Layout.fillHeight: true }
          }
        }
      }
    }
  }
}
