import QtQuick
import QtQuick.Layouts

RowLayout {
    property string icon: ""
    property string value: ""
    property color iconColor: "#ffffff"
    spacing: 8
    
    Text { 
        text: icon
        color: iconColor
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 16 
        Layout.alignment: Qt.AlignVCenter
    }
    Text { 
        text: value
        color: "#c0caf5"
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 13
        font.bold: true 
        Layout.alignment: Qt.AlignVCenter
    }
}
