import QtQuick
import Quickshell
// Import the local components directory
import "./components"

PanelWindow {
    id: root
    anchors { top: true; left: true; right: true }
    implicitHeight: 30
    color: "#1a1b26"

    // --- LEFT UI (Widgets) ---
    Row {
        id: leftUI
        anchors.left: parent.left; anchors.leftMargin: 15
        height: parent.height
        spacing: 25

        CpuWidget { height: parent.height }
        RamWidget { height: parent.height }
        NetworkWidget { height: parent.height }
    }

    // --- CENTER UI (Clock) ---
    ClockWidget {
        anchors.centerIn: parent
    }
}
