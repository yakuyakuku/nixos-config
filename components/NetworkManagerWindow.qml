import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick.Controls
import QtQuick.Layouts

PanelWindow {
    id: managerRoot
    // Fullscreen overlay to center the dialog
    anchors { top: true; bottom: true; left: true; right: true }
    color: "#80000000" // Semi-transparent dim background
    visible: false

    // Exclusive Focus Grab - use separate enum types
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    
    // Prevent interaction with background
    MouseArea { anchors.fill: parent; onClicked: managerRoot.visible = false }

    property var anchorItem: null // Ignored in PanelWindow mode
    property string currentTab: "saved"

    // Main Dialog Window
    Rectangle {
        width: 500
        height: 450
        anchors.centerIn: parent
        color: "#1a1b26"
        radius: 12
        border.color: "#7aa2f7"
        border.width: 1
        
        // Trap clicks so they don't close the window
        MouseArea { anchors.fill: parent }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15

            // Header
            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: "Network Manager"
                    color: "#7aa2f7"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 20
                    font.bold: true
                }
                Item { Layout.fillWidth: true }
                // Close button
                Text {
                    text: "󰅖"
                    color: "#f7768e"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 20
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: managerRoot.visible = false
                    }
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: "#414868" }

            // Tabs (Saved vs Add) - Simple implementation
            // property string currentTab moved to root
            
            RowLayout {
                spacing: 20
                Layout.alignment: Qt.AlignHCenter
                
                Rectangle {
                    width: 120; height: 35; radius: 6
                    color: managerRoot.currentTab === "saved" ? "#7aa2f7" : "#24283b"
                    Text { anchors.centerIn: parent; text: "Saved Networks"; color: managerRoot.currentTab === "saved" ? "#1a1b26" : "#c0caf5"; font.family: "JetBrainsMono Nerd Font"; font.bold: true }
                    MouseArea { anchors.fill: parent; onClicked: managerRoot.currentTab = "saved" }
                }

                Rectangle {
                    width: 120; height: 35; radius: 6
                    color: managerRoot.currentTab === "add" ? "#7aa2f7" : "#24283b"
                    Text { anchors.centerIn: parent; text: "Add Network"; color: managerRoot.currentTab === "add" ? "#1a1b26" : "#c0caf5"; font.family: "JetBrainsMono Nerd Font"; font.bold: true }
                    MouseArea { anchors.fill: parent; onClicked: managerRoot.currentTab = "add" }
                }
            }

            // --- SAVED NETWORKS VIEW ---
            Item {
                Layout.fillWidth: true; Layout.fillHeight: true
                visible: managerRoot.currentTab === "saved"
                clip: true

                ListView {
                    id: savedList
                    anchors.fill: parent
                    model: savedNetworksModel
                    spacing: 8
                    delegate: Rectangle {
                        width: savedList.width
                        height: 40
                        color: "#24283b"
                        radius: 6

                        RowLayout {
                            anchors.fill: parent; anchors.margins: 10
                            Text { 
                                text: modelData.name
                                color: "#c0caf5" 
                                font.family: "JetBrainsMono Nerd Font"
                                Layout.fillWidth: true
                            }
                            Text {
                                text: "󰆴" // Trash icon
                                color: "#f7768e"
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 16
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: deleteProc.uuid = modelData.uuid
                                }
                            }
                        }
                    }
                }
                
                Text {
                     anchors.centerIn: parent
                     text: "Loading saved networks..."
                     color: "#565f89"
                     font.family: "JetBrainsMono Nerd Font"
                     visible: savedNetworksModel.length === 0
                }
            }

            // --- ADD NETWORK VIEW ---
            ColumnLayout {
                Layout.fillWidth: true; Layout.fillHeight: true
                visible: managerRoot.currentTab === "add"
                spacing: 15
                
                Text { text: "SSID (Network Name)"; color: "#bb9af7"; font.family: "JetBrainsMono Nerd Font" }
                Rectangle {
                    Layout.fillWidth: true; height: 35
                    color: "#24283b"; radius: 4; border.color: "#414868"
                    TextInput { 
                        id: ssidInput
                        anchors.fill: parent; anchors.margins: 8
                        color: "white"; font.family: "JetBrainsMono Nerd Font"; clip: true
                        // Ensure we grab focus when the tab is switched
                        onVisibleChanged: if (visible) forceActiveFocus()
                    }
                }

                Text { text: "Password"; color: "#bb9af7"; font.family: "JetBrainsMono Nerd Font" }
                Rectangle {
                    Layout.fillWidth: true; height: 35
                    color: "#24283b"; radius: 4; border.color: "#414868"
                    TextInput { id: passInput; anchors.fill: parent; anchors.margins: 8; color: "white"; font.family: "JetBrainsMono Nerd Font"; echoMode: TextInput.Password; clip: true }
                }

                Item { Layout.fillHeight: true } // Spacer

                Rectangle {
                    Layout.fillWidth: true; height: 40
                    color: "#9ece6a"; radius: 6
                    Text { anchors.centerIn: parent; text: "Connect & Save"; color: "#1a1b26"; font.bold: true; font.family: "JetBrainsMono Nerd Font" }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            addProc.ssid = ssidInput.text
                            addProc.pass = passInput.text
                            addProc.running = true
                        }
                    }
                }
            }
        }
    }

    // --- LOGIC ---
    property var savedNetworksModel: []

    Timer {
        interval: 5000; running: visible; repeat: true; triggeredOnStart: true
        onTriggered: savedProc.running = true
    }

    Process {
        id: savedProc
        command: ["bash", "-c", "nmcli -t -f UUID,NAME,TYPE connection show | grep ':802-11-wireless'"]
        stdout: StdioCollector { id: savedOut }
        onExited: {
            let lines = savedOut.text.trim().split("\n");
            let list = [];
            for (let line of lines) {
                if (!line) continue;
                let p = line.split(":");
                list.push({ uuid: p[0], name: p[1] });
            }
            savedNetworksModel = list;
        }
    }
    
    Process {
        id: deleteProc
        property string uuid: ""
        onUuidChanged: if (uuid !== "") running = true
        command: ["nmcli", "connection", "delete", uuid]
        onExited: savedProc.running = true // rescan
    }

    Process {
        id: addProc
        property string ssid: ""
        property string pass: ""
        command: ["bash", "-c", `nmcli dev wifi connect "${ssid}" password "${pass}"`]
        onExited: {
            managerRoot.visible = false
            // Clear inputs
            ssidInput.text = ""
            passInput.text = ""
        }
    }
}
