import QtQuick

Text {
    text: "00:00:00"
    color: "#bb9af7"
    font.family: "JetBrainsMono Nerd Font"
    font.pixelSize: 15
    font.bold: true
    
    Timer {
        interval: 1000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: parent.text = Qt.formatDateTime(new Date(), "HH:mm:ss")
    }
}
