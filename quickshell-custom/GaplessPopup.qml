import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick.Controls
import QtQuick.Layouts

// GaplessPopup.qml
// A reusable component for creating popups that perfectly align with a widget
// and feature a "slide down/extend" animation with click-outside dismissal.

PanelWindow {
    id: root
    
    // --- POSITIONING ---
    // The absolute coordinates where the CONTENT should appear.
    // Usually calculated via mapToItem(null, 0, 0) from the source widget.
    property real popupX: 0
    property real popupY: 0
    property real widgetWidth: 0 // Optional, for alignment logic if needed

    // --- CONTENT ---
    // The content item to display inside the popup.
    // Users should define children inside GaplessPopup, which will be parenting to contentItem.
    default property alias content: innerContent.data

    // --- FULLSCREEN OVERLAY ---
    // Covers the entire screen to catch clicks outside the popup
    anchors.fill: parent
    color: "transparent"
    visible: false

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    WlrLayershell.exclusiveZone: -1 // Overlay mode

    // --- BEHAVIOR ---
    property bool isOpen: false

    function open() {
        isOpen = true;
    }

    function close() {
        isOpen = false;
    }

    // Click Outside Handler
    MouseArea {
        anchors.fill: parent
        onClicked: close()
    }

    // --- ANIMATION ---
    // Logic: Slide content DOWN from y=popupY.
    // We achieve this by animating the HEIGHT of a clipping container.
    
    property real slideProgress: isOpen ? 1 : 0
    Behavior on slideProgress { 
        NumberAnimation { 
            duration: 300
            easing.type: Easing.OutQuart
        } 
    }

    onIsOpenChanged: {
        if (isOpen) {
            visible = true;
            closeTimer.stop();
        } else {
            closeTimer.restart();
        }
    }

    Timer {
        id: closeTimer
        interval: 300
        onTriggered: root.visible = false
    }

    // --- VISUAL CONTAINER ---
    Item {
        id: clipper
        
        x: popupX
        y: popupY
        width: innerContent.implicitWidth
        height: innerContent.implicitHeight * slideProgress
        clip: true

        // Trap clicks inside the popup
        MouseArea { anchors.fill: parent; hoverEnabled: true }

        // The actual content container
        Rectangle {
            id: innerContent
            width: childrenRect.width
            height: childrenRect.height
            
            // Visual Design matching the reference Bar
            color: "#1a1b26"
            border.color: "#414868" // Or match bar border
            border.width: 1
            radius: 8

            // To make it look like it slides OUT of the bar:
            // Anchor bottom to parent bottom? No, top to top is standard slide down.
            // If we want "Extension", it usually means the interface grows from the edge.
            // Standard slide down: Top is fixed, Height grows.
            
            // Extension Lines (Optional - to merge with bar visually)
            // If popupY is exactly at bar bottom, and we want to hide the top border:
            Rectangle {
                id: topMask
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - 16 // Leave rounded corners visible? Or mask fully?
                height: 2
                color: "#1a1b26"
                visible: true
            }
        }
    }
}
