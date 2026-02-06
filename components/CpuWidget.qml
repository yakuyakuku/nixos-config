import QtQuick
import Quickshell
import Quickshell.Io

StatusItem {
    id: root
    icon: "󰻠"
    value: "0%"
    iconColor: "#ff9e64"

    property var lastCpu: ({total: 0, idle: 0})

    Timer {
        interval: 2000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: cpuProc.running = true
    }

    Process {
        id: cpuProc
        command: ["bash", "-c", "grep 'cpu ' /proc/stat | awk '{print $2+$3+$4+$5+$6+$7+$8+$9, $5+$6}'"]
        stdout: StdioCollector { id: cpuOut }
        onExited: {
            let output = cpuOut.text.trim().split(/\s+/);
            if (output.length < 2) return;
            let total = parseInt(output[0]);
            let idle = parseInt(output[1]);
            if (lastCpu.total !== 0) {
                let totalDiff = total - lastCpu.total;
                let idleDiff = idle - lastCpu.idle;
                if (totalDiff > 0) root.value = Math.round((totalDiff - idleDiff) * 100 / totalDiff) + "%";
            }
            lastCpu = {total: total, idle: idle};
        }
    }
}
