import QtQuick
import Quickshell
import Quickshell.Io

StatusItem {
    id: root
    icon: "󰍛"
    value: "0%"
    iconColor: "#9ece6a"

    Timer {
        interval: 5000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: ramProc.running = true
    }

    Process {
        id: ramProc
        command: ["bash", "-c", "free | grep Mem | awk '{print $3/$2 * 100.0}'"]
        stdout: StdioCollector { id: ramOut }
        onExited: root.value = Math.round(ramOut.text.trim()) + "%"
    }
}
