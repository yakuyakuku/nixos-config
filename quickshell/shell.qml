import QtQuick
import Quickshell
import Quickshell.Io
import QtQuick.Controls
import QtQuick.Layouts

PanelWindow {
    id: root
    anchors { top: true; left: true; right: true }
    implicitHeight: 30
    color: "#1a1b26"

    property string cpuUsage: "0%"
    property string ramUsage: "0%"
    property var lastCpu: ({total: 0, idle: 0})

    property string lanName: "Offline"
    property bool lanActive: false
    property string wlanName: "Offline"
    property bool wlanActive: false
    property var wifiNetworks: []
    
    property string selectedSSID: ""
    property bool showPasswordInput: false

    // --- REFRESH LOGIC ---
    Timer {
        interval: 5000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: {
            cpuProc.running = true
            ramProc.running = true
            netProc.running = true
        }
    }

    // CPU Logic
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
                if (totalDiff > 0) cpuUsage = Math.round((totalDiff - idleDiff) * 100 / totalDiff) + "%";
            }
            lastCpu = {total: total, idle: idle};
        }
    }

    // RAM Logic
    Process {
        id: ramProc
        command: ["bash", "-c", "free | grep Mem | awk '{print $3/$2 * 100.0}'"]
        stdout: StdioCollector { id: ramOut }
        onExited: ramUsage = Math.round(ramOut.text.trim()) + "%"
    }

    // Network Status (LAN & WLAN)
    Process {
        id: netProc
        command: ["bash", "-c", "nmcli -t -f TYPE,STATE,CONNECTION dev | grep ':connected'"]
        stdout: StdioCollector { id: netOut }
        onExited: {
            let lines = netOut.text.trim().split("\n");
            let lanFound = false;
            let wlanFound = false;
            
            for (let line of lines) {
                if (!line) continue;
                let parts = line.split(":");
                let type = parts[0];
                let name = parts[2];
                
                if (type === "ethernet") {
                    lanName = "Connected";
                    lanActive = true;
                    lanFound = true;
                } else if (type === "wifi") {
                    wlanName = name;
                    wlanActive = true;
                    wlanFound = true;
                }
            }
            
            if (!lanFound) { lanName = "Offline"; lanActive = false; }
            if (!wlanFound) { wlanName = "Offline"; wlanActive = false; }
        }
    }

    // WiFi List Scanner
    Process {
        id: wifiListProc
        command: ["bash", "-c", "nmcli -t -f IN-USE,SSID,BARS,SECURITY dev wifi list --rescan yes | head -n 8"]
        stdout: StdioCollector { id: wifiOut }
        onExited: {
            let lines = wifiOut.text.trim().split("\n");
            let list = [];
            for (let line of lines) {
                if (!line) continue;
                let p = line.split(":");
                list.push({ active: p[0] === "*", ssid: p[1], bars: p[2], secured: p[3] !== "" });
            }
            wifiNetworks = list;
        }
    }

    // Connect Logic
    Process {
        id: connectProc
        property string psk: ""
        command: ["bash", "-c", `nmcli dev wifi connect "${selectedSSID}" password "${psk}"`]
        onExited: {
            showPasswordInput = false;
            netProc.running = true;
        }
    }

    // Popup Window
    PopupWindow {
        id: netPopup
        
        anchor { 
            item: netWrapper
            edges: Edges.Bottom | Edges.Left
            gravity: Edges.Bottom | Edges.Right
        }

        implicitWidth: 320
        // Fix Protocol Error: Ensure size is never 0
        implicitHeight: Math.max(1, contentItem.height)
        color: "transparent"
        visible: false

        // Scroll Animation Wrapper
        Rectangle {
            id: contentItem
            width: parent.width
            // Start at 0, animate to full size
            height: 0 
            color: "#1f2335"
            border.color: "#414868"
            border.width: 1
            radius: 8
            clip: true

            Behavior on height {
                NumberAnimation { duration: 300; easing.type: Easing.OutQuart }
            }

            Column {
                id: contentCol
                width: parent.width
                anchors.top: parent.top
                anchors.margins: 15
                anchors.topMargin: 15
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 12
                opacity: contentItem.height > 20 ? 1 : 0
                
                Behavior on opacity { NumberAnimation { duration: 200 } }

                // LAN Section
                RowLayout {
                    spacing: 12
                    Text { text: "󰈀"; color: lanActive ? "#9ece6a" : "#565f89"; font.pixelSize: 18; font.family: "JetBrainsMono Nerd Font" }
                    Column {
                        Text { text: "Wired (LAN)"; color: "#7aa2f7"; font.bold: true; font.pixelSize: 14; font.family: "JetBrainsMono Nerd Font" }
                        Text { text: lanName; color: "#c0caf5"; font.pixelSize: 12; font.family: "JetBrainsMono Nerd Font" }
                    }
                }

                Rectangle { width: parent.width; height: 1; color: "#414868" }

                // WLAN Section
                Text {
                    text: "Wireless (WLAN)"
                    color: "#7aa2f7"
                    font.bold: true; font.pixelSize: 14; font.family: "JetBrainsMono Nerd Font"
                }

                // WiFi List
                Column {
                    width: parent.width
                    spacing: 8
                    visible: !showPasswordInput

                    Repeater {
                        model: wifiNetworks
                        delegate: Rectangle {
                            width: parent.width
                            height: 35
                            color: modelData.active ? "#24283b" : "transparent"
                            radius: 4

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 8
                                spacing: 12
                                
                                Text { 
                                    text: modelData.secured ? "󰌾" : "󰤨"; color: "#565f89"; font.pixelSize: 14 
                                    font.family: "JetBrainsMono Nerd Font"
                                    Layout.alignment: Qt.AlignVCenter
                                }

                                Text { 
                                    text: modelData.ssid; color: modelData.active ? "#9ece6a" : "#c0caf5"
                                    font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 13
                                    Layout.preferredWidth: 170
                                    elide: Text.ElideRight 
                                    Layout.alignment: Qt.AlignVCenter
                                }
                                Text { 
                                    text: modelData.bars; color: "#bb9af7"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12 
                                    Layout.alignment: Qt.AlignVCenter
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: if (!modelData.active) parent.color = "#24283b"
                                onExited: if (!modelData.active) parent.color = "transparent"
                                onClicked: {
                                    if (modelData.active) return;
                                    selectedSSID = modelData.ssid;
                                    if (modelData.secured) showPasswordInput = true;
                                    else {
                                        connectProc.psk = "";
                                        connectProc.running = true;
                                    }
                                }
                            }
                        }
                    }
                }

                // Password Input Container
                Column {
                    width: parent.width
                    spacing: 15
                    visible: showPasswordInput

                    Text { text: "Connect to: " + selectedSSID; color: "#bb9af7"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 13 }

                    Rectangle {
                        width: parent.width; height: 35
                        color: "#24283b"; border.color: "#414868"; radius: 4
                        TextInput {
                            id: passInput
                            anchors.fill: parent; anchors.margins: 8
                            color: "#c0caf5"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 13
                            echoMode: TextInput.Password; focus: showPasswordInput
                            onAccepted: {
                                connectProc.psk = passInput.text;
                                connectProc.running = true;
                            }
                        }
                    }

                    Row {
                        spacing: 10; anchors.horizontalCenter: parent.horizontalCenter
                        
                        Rectangle {
                            width: 100; height: 30; radius: 4; color: "#f7768e"
                            Text { anchors.centerIn: parent; text: "Cancel"; color: "white"; font.family: "JetBrainsMono Nerd Font" }
                            MouseArea { anchors.fill: parent; onClicked: showPasswordInput = false }
                        }

                        Rectangle {
                            width: 100; height: 30; radius: 4; color: "#9ece6a"
                            Text { anchors.centerIn: parent; text: "Connect"; color: "#1a1b26"; font.bold: true; font.family: "JetBrainsMono Nerd Font" }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    connectProc.psk = passInput.text;
                                    connectProc.running = true;
                                }
                            }
                        }
                    }
                }

                Rectangle { width: parent.width; height: 1; color: "#414868" }

                Row {
                    spacing: 12
                    Text { text: "󰑐"; color: "#7aa2f7"; font.pixelSize: 16; font.family: "JetBrainsMono Nerd Font" }
                    Text { text: "Rescan Networks"; color: "#7aa2f7"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 13 }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: wifiListProc.running = true
                    }
                }
            }
        }
    }

    // --- UI LAYOUT ---
    Row {
        id: leftUI
        anchors.left: parent.left; anchors.leftMargin: 15
        height: parent.height
        spacing: 25

        // Status Item Component
        component StatusItem : RowLayout {
            property string icon: ""
            property string value: ""
            property color iconColor: "#ffffff"
            spacing: 8
            
            Text { 
                text: icon; color: iconColor; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 16 
                Layout.alignment: Qt.AlignVCenter
            }
            Text { 
                text: value; color: "#c0caf5"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 13; font.bold: true 
                Layout.alignment: Qt.AlignVCenter
            }
        }

        StatusItem { icon: "󰻠"; value: cpuUsage; iconColor: "#ff9e64" }
        StatusItem { icon: "󰍛"; value: ramUsage; iconColor: "#9ece6a" }

        // Clickable Network Items WRAPPER
        Item {
            id: netWrapper
            width: netContainer.implicitWidth
            height: parent.height

            RowLayout {
                id: netContainer
                spacing: 15
                height: parent.height
                
                // LAN Bar Info
                RowLayout {
                    visible: lanActive
                    spacing: 6
                    Text { text: "󰈀"; color: "#9ece6a"; font.pixelSize: 16; font.family: "JetBrainsMono Nerd Font"; Layout.alignment: Qt.AlignVCenter }
                    Text { text: "LAN"; color: "#c0caf5"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 13; Layout.alignment: Qt.AlignVCenter }
                }

                // WLAN Bar Info
                RowLayout {
                    spacing: 6
                    Text { text: "󰖩"; color: wlanActive ? "#7aa2f7" : "#565f89"; font.pixelSize: 16; font.family: "JetBrainsMono Nerd Font"; Layout.alignment: Qt.AlignVCenter }
                    Text { text: wlanName; color: "#c0caf5"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 13; Layout.preferredWidth: 100; elide: Text.ElideRight; Layout.alignment: Qt.AlignVCenter }
                }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: netContainer.opacity = 0.7
                onExited: netContainer.opacity = 1.0
                onClicked: {
                    wifiListProc.running = true;
                    // Trigger animation
                    if (!netPopup.visible) {
                        contentItem.height = 0; // Prepare for animation
                        netPopup.visible = true;
                        contentItem.height = contentCol.implicitHeight + 40;
                    } else {
                        contentItem.height = 0;
                        closeTimer.start()
                    }
                }
            }
            
            Timer {
                id: closeTimer
                interval: 300
                onTriggered: netPopup.visible = false
            }
        }
    }

    // Middle: Clock
    Text {
        anchors.centerIn: parent
        text: "00:00:00"
        color: "#bb9af7"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 15; font.bold: true
        
        Timer {
            interval: 1000; running: true; repeat: true; triggeredOnStart: true
            onTriggered: parent.text = Qt.formatDateTime(new Date(), "HH:mm:ss")
        }
    }
}
