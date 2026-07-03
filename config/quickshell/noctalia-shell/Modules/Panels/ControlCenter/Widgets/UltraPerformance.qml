import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Services.Power
import qs.Widgets

NIconButtonHot {
  property ShellScreen screen

  icon: PowerProfileService.noctaliaPerformanceMode ? "rocket" : "rocket-off"
  tooltipText: "Ultra Performance Mode"
  hot: PowerProfileService.noctaliaPerformanceMode
  onClicked: {
    PowerProfileService.toggleNoctaliaPerformance();
    Quickshell.execDetachable(["/home/notvarad/.local/bin/toggle-perf-mode.sh", "on"]);
  }
}
