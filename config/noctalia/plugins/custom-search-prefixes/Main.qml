import QtQuick
import Quickshell.Io

Item {
  property var pluginApi: null

  IpcHandler {
    target: "plugin:custom-search-prefixes"
    function toggle() {
      pluginApi.withCurrentScreen(screen => {
        pluginApi.toggleLauncher(screen);
      });
    }
  }
}
