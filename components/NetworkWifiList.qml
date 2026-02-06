import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Column {
    id: root
    spacing: 12
    width: 320 // Default width

    property var networks: []
    property string lanState: "Offline"
    property bool lanActive: false
    
    // Signals to communicate with parent
    signal requestAddNetwork()
    signal connectToNetwork(string ssid, bool secured)
    signal requestRescan()

    // LAN Section
    RowLayout {
        spacing: 12
        Text { text: "󰈀"; color: lanActive ? "#9ece6a" : "#565f89"; font.pixelSize: 18; font.family: "JetBrainsMono Nerd Font" }
        Column {
            Text { text: "Wired (LAN)"; color: "#7aa2f7"; font.bold: true; font.pixelSize: 14; font.family: "JetBrainsMono Nerd Font" }
            Text { text: lanState; color: "#c0caf5"; font.pixelSize: 12; font.family: "JetBrainsMono Nerd Font" }
        }
    }

    Rectangle { width: parent.width; height: 1; color: "#414868" }

    // FLOW CONTROL HEADER
    RowLayout {
        spacing: 8
        Text {
            text: "Wireless (WLAN)"
            color: "#7aa2f7"
            font.bold: true; font.pixelSize: 14; font.family: "JetBrainsMono Nerd Font"
        }
        
        Rectangle {
            id: addBtn
            width: 20; height: 20
            color: "transparent"
            radius: 4
            border.color: addMouse.containsMouse ? "#7aa2f7" : "transparent"
            
            Text {
                anchors.centerIn: parent
                text: "+"
                color: addMouse.containsMouse ? "#ffffff" : "#7aa2f7"
                font.bold: true
                font.family: "JetBrainsMono Nerd Font"
            }

            MouseArea {
                id: addMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.requestAddNetwork()
            }
        }
    }

    // NETWORK LIST REPEATER
    Column {
        width: parent.width
        spacing: 8
        
        Repeater {
            model: networks
            delegate: Rectangle {
                width: parent.width
                height: 35
                color: modelData.active ? "#24283b" : "transparent"
                radius: 4

                RowLayout {
                    anchors.fill: parent; anchors.leftMargin: 8; spacing: 12
                    
                    Text { 
                        text: modelData.secured ? "󰌾" : "󰤨"
                        color: "#565f89"
                        font.pixelSize: 14 
                        font.family: "JetBrainsMono Nerd Font"
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Text { 
                        text: modelData.ssid
                        color: modelData.active ? "#9ece6a" : "#c0caf5"
                        textFormat: Text.PlainText
                        font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 13
                        Layout.preferredWidth: 170
                        elide: Text.ElideRight 
                        Layout.alignment: Qt.AlignVCenter
                    }
                    
                    Text { 
                        text: modelData.bars
                        color: "#bb9af7"
                        font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12 
                        Layout.alignment: Qt.AlignVCenter
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: if (!modelData.active) parent.color = "#24283b"
                    onExited: if (!modelData.active) parent.color = "transparent"
                    onClicked: {
                        if (!modelData.active) {
                            root.connectToNetwork(modelData.ssid, modelData.secured)
                        }
                    }
                }
            }
        }
    }
    
    Rectangle { width: parent.width; height: 1; color: "#414868" }
    
    // RESCAN BUTTON
    Rectangle {
         id: scanBtn
         width: parent.width; height: 40; color: "transparent"; radius: 8; border.width: 1; border.color: "transparent"
         
         RowLayout {
             anchors.centerIn: parent; spacing: 12
             Text { id: scanIcon; text: "󰑐"; color: "#7aa2f7"; font.pixelSize: 16; font.family: "JetBrainsMono Nerd Font"; Layout.alignment: Qt.AlignVCenter }
             Text { id: scanText; text: "Rescan Networks"; color: "#7aa2f7"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 13; font.weight: Font.DemiBold; Layout.alignment: Qt.AlignVCenter }
         }
         
         MouseArea {
             id: rescanMouse; anchors.fill: parent; hoverEnabled: true
             onClicked: root.requestRescan()
         }
         
         states: [
             State { 
                 name: "hovered"; when: rescanMouse.containsMouse && !rescanMouse.pressed
                 PropertyChanges { target: scanBtn; color: "#24283b"; border.color: "#3b4261" }
                 PropertyChanges { target: scanIcon; color: "#bb9af7" }
                 PropertyChanges { target: scanText; color: "#c0caf5" }
             }
         ]
         transitions: Transition { ColorAnimation { duration: 200 } }
    }
}
