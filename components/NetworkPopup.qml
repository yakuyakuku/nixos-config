import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick.Controls
import QtQuick.Layouts

// Separate PanelWindow - not a child of shell.qml
// This allows us to use WlrLayershell without breaking the bar!
PanelWindow {
    id: networkPopup
    
    // Position at top-left
    anchors { top: true; left: true }
    
    implicitWidth: viewMode === "add" ? 400 : 320
    implicitHeight: contentCol.implicitHeight + 40
    
    color: "transparent"
    visible: false
    
    // Above windows
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    WlrLayershell.exclusiveZone: 0
    
    property string viewMode: "list"  // "list" or "add"
    property string selectedSSID: ""
    property bool showPasswordInput: false
    
    property string lanName: "Offline"
    property bool lanActive: false
    property string wlanName: "Offline"
    property bool wlanActive: false
    property var wifiNetworks: []
    
    // --- PROCESSES ---
    Process {
        id: netProc
        command: ["bash", "-c", "nmcli -t -f DEVICE,TYPE,STATE,CONNECTION device status"]
        stdout: StdioCollector { id: netOut }
        onExited: {
            let lines = netOut.text.trim().split("\n");
            for (let line of lines) {
                let parts = line.split(":");
                if (parts[1] === "ethernet") {
                    networkPopup.lanActive = parts[2] === "connected";
                    networkPopup.lanName = networkPopup.lanActive ? parts[3] : "Offline";
                } else if (parts[1] === "wifi") {
                    networkPopup.wlanActive = parts[2] === "connected";
                    networkPopup.wlanName = networkPopup.wlanActive ? parts[3] : "Offline";
                }
            }
        }
    }
    
    Process {
        id: wifiListProc
        command: ["bash", "-c", "nmcli -t -f SSID,SIGNAL,SECURITY device wifi list 2>/dev/null | head -20"]
        stdout: StdioCollector { id: wifiOut }
        onExited: {
            let lines = wifiOut.text.trim().split("\n");
            let networks = [];
            for (let line of lines) {
                if (!line) continue;
                let parts = line.split(":");
                if (parts[0]) {
                    networks.push({ ssid: parts[0], signal: parseInt(parts[1]) || 0, security: parts[2] || "Open" });
                }
            }
            networkPopup.wifiNetworks = networks;
        }
    }
    
    Process {
        id: connectProc
        property string psk: ""
        command: ["bash", "-c", `nmcli dev wifi connect "${selectedSSID}" password "${psk}"`]
        onExited: {
            showPasswordInput = false;
            netProc.running = true;
        }
    }
    
    Timer {
        interval: 5000; running: networkPopup.visible; repeat: true; triggeredOnStart: true
        onTriggered: netProc.running = true
    }
    
    Timer {
        id: scanTimer
        interval: 50
        onTriggered: wifiListProc.running = true
    }
    
    onVisibleChanged: {
        if (visible) {
            viewMode = "list";
            scanTimer.start();
        }
    }

    Timer {
        id: closeTimer
        interval: 300 // slightly longer than animation to ensure it finishes
        onTriggered: networkPopup.visible = false
    }
    
    // Control open/close state logic
    property bool isOpen: false
    onIsOpenChanged: {
        if (isOpen) {
            closeTimer.stop();
            visible = true;
            viewMode = "list";
            scanTimer.start();
        } else {
            closeTimer.restart();
        }
    }
    
    // Slide-down animation - smooth and sleek
    property real slideProgress: isOpen ? 1 : 0
    Behavior on slideProgress { 
        NumberAnimation { 
            duration: 280
            easing.type: Easing.OutCubic
        } 
    }
    
    // Full width container
    property real fullWidth: viewMode === "add" ? 400 : 320
    Behavior on fullWidth { NumberAnimation { duration: 280; easing.type: Easing.OutCubic } }
    
    property real fullHeight: Math.max(10, contentCol.implicitHeight + 40)
    Behavior on fullHeight { NumberAnimation { duration: 280; easing.type: Easing.OutCubic } }
    
    // --- UI ---
    // Outer clip container - maintains full width, clips height
    Item {
        id: clipContainer
        width: fullWidth
        height: fullHeight * slideProgress
        clip: true
        
        // Inner content - always full size, slides into view
        Rectangle {
            id: contentItem
            width: parent.width
            height: fullHeight
            // Anchored to BOTTOM so it slides down from top
            anchors.bottom: parent.bottom
            color: "#1a1b26"
            radius: 12
            border.color: "#7aa2f7"
            border.width: 1
            
            // Top mask to hide top border and radius (seamless with bar)
            Rectangle {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: 14
                color: "#1a1b26"
            }
            
            // Left side border extension (over mask)
            Rectangle {
                anchors.top: parent.top
                anchors.left: parent.left
                width: 1
                height: 14
                color: "#7aa2f7"
            }
            // Right side border extension (over mask)
            Rectangle {
                anchors.top: parent.top
                anchors.right: parent.right
                width: 1
                height: 14
                color: "#7aa2f7"
            }
            
            FocusScope {
                anchors.fill: parent
                anchors.margins: 20
            
                Column {
                    id: contentCol
                    width: parent.width
                    spacing: 12
                
                    // --- VIEW: LIST ---
                    Column {
                        width: parent.width
                        visible: viewMode === "list"
                        spacing: 12
                    
                        // LAN Section
                        Row {
                            spacing: 10
                            Text { text: lanActive ? "󰈀" : "󰈂"; color: lanActive ? "#9ece6a" : "#565f89"; font.pixelSize: 18; font.family: "JetBrainsMono Nerd Font" }
                            Column {
                                Text { text: "Ethernet (LAN)"; color: "#7aa2f7"; font.bold: true; font.pixelSize: 12; font.family: "JetBrainsMono Nerd Font" }
                                Text { text: lanName; color: "#c0caf5"; font.pixelSize: 12; font.family: "JetBrainsMono Nerd Font" }
                            }
                        }
                    
                        Rectangle { width: parent.width; height: 1; color: "#414868" }
                    
                        // WLAN Header with +
                        RowLayout {
                            spacing: 8
                            Text { text: "Wireless (WLAN)"; color: "#7aa2f7"; font.bold: true; font.pixelSize: 14; font.family: "JetBrainsMono Nerd Font" }
                        
                            Rectangle {
                                width: 20; height: 20; color: "transparent"; radius: 4
                                border.color: addMouse.containsMouse ? "#7aa2f7" : "transparent"
                                Text { anchors.centerIn: parent; text: "+"; color: addMouse.containsMouse ? "#ffffff" : "#7aa2f7"; font.bold: true; font.family: "JetBrainsMono Nerd Font" }
                                MouseArea {
                                    id: addMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: viewMode = "add"
                                }
                            }
                        }
                    
                        // WiFi List
                        Column {
                            width: parent.width
                            spacing: 8
                            visible: !showPasswordInput
                        
                            Repeater {
                                model: wifiNetworks
                                delegate: Rectangle {
                                    width: parent.width; height: 40; radius: 6
                                    color: wifiMouse.containsMouse ? "#24283b" : "transparent"
                                
                                    RowLayout {
                                        anchors.fill: parent; anchors.margins: 8; spacing: 10
                                        Text {
                                            text: modelData.signal > 75 ? "󰤨" : modelData.signal > 50 ? "󰤥" : modelData.signal > 25 ? "󰤢" : "󰤟"
                                            color: wlanName === modelData.ssid ? "#9ece6a" : "#7aa2f7"
                                            font.pixelSize: 16; font.family: "JetBrainsMono Nerd Font"
                                        }
                                        Column {
                                            Layout.fillWidth: true
                                            Text { text: modelData.ssid; color: "#c0caf5"; font.pixelSize: 12; font.family: "JetBrainsMono Nerd Font" }
                                            Text { text: modelData.security + " • " + modelData.signal + "%"; color: "#565f89"; font.pixelSize: 10; font.family: "JetBrainsMono Nerd Font" }
                                        }
                                        Text {
                                            text: wlanName === modelData.ssid ? "󰄬" : ""
                                            color: "#9ece6a"; font.pixelSize: 14; font.family: "JetBrainsMono Nerd Font"
                                        }
                                    }
                                
                                    MouseArea {
                                        id: wifiMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            selectedSSID = modelData.ssid;
                                            showPasswordInput = true;
                                        }
                                    }
                                }
                            }
                        }
                    
                        // Password Input
                        Column {
                            width: parent.width
                            spacing: 8
                            visible: showPasswordInput
                        
                            Text { text: "Password for " + selectedSSID; color: "#bb9af7"; font.bold: true; font.family: "JetBrainsMono Nerd Font" }
                            Rectangle {
                                width: parent.width; height: 35; color: "#24283b"; radius: 4; border.color: "#414868"
                                TextInput {
                                    id: passInput
                                    anchors.fill: parent; anchors.margins: 8
                                    color: "white"; font.family: "JetBrainsMono Nerd Font"
                                    echoMode: TextInput.Password
                                    onVisibleChanged: if (visible) forceActiveFocus()
                                    onAccepted: {
                                        connectProc.psk = text;
                                        connectProc.running = true;
                                    }
                                }
                            }
                            Row {
                                spacing: 10
                                Rectangle {
                                    width: 80; height: 30; radius: 4; color: "#f7768e"
                                    Text { anchors.centerIn: parent; text: "Cancel"; color: "#1a1b26"; font.bold: true; font.family: "JetBrainsMono Nerd Font" }
                                    MouseArea { anchors.fill: parent; onClicked: showPasswordInput = false }
                                }
                                Rectangle {
                                    width: 80; height: 30; radius: 4; color: "#9ece6a"
                                    Text { anchors.centerIn: parent; text: "Connect"; color: "#1a1b26"; font.bold: true; font.family: "JetBrainsMono Nerd Font" }
                                    MouseArea { anchors.fill: parent; onClicked: { connectProc.psk = passInput.text; connectProc.running = true; } }
                                }
                            }
                        }
                    
                        // Rescan Button
                        Rectangle {
                            width: parent.width; height: 35; radius: 6
                            color: scanMouse.containsMouse ? "#24283b" : "#1f2335"
                            border.color: "#414868"
                            Row {
                                anchors.centerIn: parent; spacing: 8
                                Text { text: "󰑓"; color: "#bb9af7"; font.pixelSize: 14; font.family: "JetBrainsMono Nerd Font" }
                                Text { text: "Rescan"; color: "#c0caf5"; font.pixelSize: 12; font.family: "JetBrainsMono Nerd Font" }
                            }
                            MouseArea { id: scanMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: wifiListProc.running = true }
                        }
                    }
                
                    // --- VIEW: ADD NETWORK ---
                    Column {
                        width: parent.width
                        visible: viewMode === "add"
                        spacing: 14
                    
                        // Header
                        Row {
                            spacing: 10
                            Rectangle {
                                width: 28; height: 28; radius: 6
                                color: backMouse.containsMouse ? "#f7768e" : "transparent"
                                Text { anchors.centerIn: parent; text: "󰁍"; color: backMouse.containsMouse ? "#1a1b26" : "#f7768e"; font.pixelSize: 16; font.family: "JetBrainsMono Nerd Font" }
                                MouseArea { id: backMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: viewMode = "list" }
                            }
                            Text { anchors.verticalCenter: parent.verticalCenter; text: "Add Hidden Network"; color: "#bb9af7"; font.bold: true; font.pixelSize: 14; font.family: "JetBrainsMono Nerd Font" }
                        }
                    
                        Rectangle { width: parent.width; height: 1; color: "#414868" }
                    
                        // SSID
                        Column {
                            width: parent.width; spacing: 4
                            Row {
                                spacing: 6
                                Text { text: "󰖟"; color: "#7aa2f7"; font.pixelSize: 12; font.family: "JetBrainsMono Nerd Font" }
                                Text { text: "Network Name"; color: "#a9b1d6"; font.pixelSize: 11; font.family: "JetBrainsMono Nerd Font" }
                            }
                            Rectangle {
                                width: parent.width; height: 36; color: "#24283b"; radius: 6; border.color: manualSsid.activeFocus ? "#7aa2f7" : "#414868"
                                TextInput { id: manualSsid; anchors.fill: parent; anchors.margins: 10; color: "#c0caf5"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 13; clip: true; onVisibleChanged: if (visible) forceActiveFocus() }
                            }
                        }
                    
                        // Password
                        Column {
                            width: parent.width; spacing: 4
                            Row {
                                spacing: 6
                                Text { text: "󰌾"; color: "#7aa2f7"; font.pixelSize: 12; font.family: "JetBrainsMono Nerd Font" }
                                Text { text: "Password"; color: "#a9b1d6"; font.pixelSize: 11; font.family: "JetBrainsMono Nerd Font" }
                            }
                            Rectangle {
                                width: parent.width; height: 36; color: "#24283b"; radius: 6; border.color: manualPass.activeFocus ? "#7aa2f7" : "#414868"
                                TextInput {
                                    id: manualPass; anchors.fill: parent; anchors.margins: 10; color: "#c0caf5"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 13; echoMode: TextInput.Password; clip: true
                                    onAccepted: { selectedSSID = manualSsid.text; connectProc.psk = manualPass.text; connectProc.running = true; viewMode = "list"; }
                                }
                            }
                        }
                    
                        // Connect Button
                        Rectangle {
                            width: parent.width; height: 38; radius: 6; color: connectBtn.containsMouse ? "#73daca" : "#9ece6a"
                            Row {
                                anchors.centerIn: parent
                                spacing: 8
                                Text { text: "󰤨"; color: "#1a1b26"; font.pixelSize: 14; font.family: "JetBrainsMono Nerd Font" }
                                Text { text: "Connect"; color: "#1a1b26"; font.bold: true; font.family: "JetBrainsMono Nerd Font" }
                            }
                            MouseArea { id: connectBtn; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: { selectedSSID = manualSsid.text; connectProc.psk = manualPass.text; connectProc.running = true; viewMode = "list"; } }
                        }
                    }
                }
            }
        }
    }
}
