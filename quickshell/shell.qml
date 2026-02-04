import QtQuick
import Quickshell

ShellRoot {
    Variants {
        // This targets your 1080p monitor
        model: Quickshell.screens
        
        Panel {
            screen: modelData
            anchors { top: parent.top; left: parent.left; right: parent.right }
            height: 40
            color: "#1a1b26" // Dark theme to match your style

            Text {
                anchors.centerIn: parent
                text: "YAKU OS | ACTIVE"
                color: "#bb9af7" // Cyan/Purple accent
                font.pixelSize: 18
            }
        }
    }
}
