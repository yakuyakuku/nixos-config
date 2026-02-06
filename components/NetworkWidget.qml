import QtQuick
import Quickshell
import Quickshell.Io
import QtQuick.Controls
import QtQuick.Layouts
import "."

// Simple widget that shows network icon and opens the separate popup
Item {
    id: root
    width: netContainer.implicitWidth
    height: 30
    
    // The popup is a separate PanelWindow (not a child!)
    NetworkPopup {
        id: networkPopup
    }

    property string lanName: "Offline"
    property bool lanActive: false
    property string wlanName: "Offline"
    property bool wlanActive: false

    // --- REFRESH LOGIC ---
    Timer {
        interval: 5000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: netProc.running = true
    }

    Process {
        id: netProc
        command: ["bash", "-c", "nmcli -t -f TYPE,STATE,CONNECTION dev | grep ':connected'"]
        stdout: StdioCollector { id: netOut }
        onExited: {
            let lines = netOut.text.trim().split("\n");
            lanActive = false; wlanActive = false;
            lanName = "Offline"; wlanName = "Offline";
            for (let line of lines) {
                let parts = line.split(":");
                if (parts[0] === "ethernet") { lanActive = true; lanName = parts[2] || "Connected"; }
                if (parts[0] === "wifi") { wlanActive = true; wlanName = parts[2] || "Connected"; }
            }
        }
    }

    // --- BAR DISPLAY ---
    RowLayout {
        id: netContainer
        anchors.fill: parent
        spacing: 4

        Rectangle {
            Layout.preferredWidth: 30
            Layout.preferredHeight: 30
            color: netMouse.containsMouse ? "#24283b" : "transparent"
            radius: 6

            Text {
                anchors.centerIn: parent
                text: wlanActive ? "󰤨" : (lanActive ? "�" : "�")
                color: (wlanActive || lanActive) ? "#9ece6a" : "#f7768e"
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 16
            }

            MouseArea {
                id: netMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    networkPopup.isOpen = !networkPopup.isOpen
                }
            }
        }
    }
}
