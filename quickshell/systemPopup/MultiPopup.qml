// systemPopup/MyPopup.qml
import Quickshell
import QtQuick
import QtQuick.Controls
import "../"


Item {
    id: root
    required property bool isCurrentScreen
    required property string screenName

    readonly property bool isOpen: PopupManager.isOpen && isCurrentScreen

    width: 900
    height: 200

    scale: root.isOpen ? 1.0 : 0.2
    y: root.isOpen ? 0 : -200

    Behavior on scale {
        NumberAnimation { duration: 200; easing.type: Easing.OutBack; easing.overshoot: 1.1 }
    }
    Behavior on y {
        NumberAnimation { duration: 120; easing.type: Easing.OutCubic}
    }

    // Snijdt de onderkant van de uitrollende popup af
    clip: true

    Rectangle {
        anchors.fill: parent
        color: Colors.background
        bottomLeftRadius: 24
        bottomRightRadius: 24

        HoverHandler {
            onHoveredChanged: {
                PopupManager.setHovered(root.screenName, hovered)
            }
        }

        // --- HIER ZIT DE FIX VOOR DE INHOUD ---
        Item {
            id: contentWrapper
            width: 900
            height: 200
            
            // Zet het element strak bovenaan vast (verschuift NIET mee als de hoogte animeert)
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter

            // VOORKOMT FLIKKEREN: Rendert de inhoud als een statische GPU layer.
            // Qt hoeft nu de tekst/layout niet 144x per seconde te herberekenen.
            layer.enabled: true
            layer.smooth: true

            Text {
                anchors.centerIn: parent
                color: "white"
                text: "Popup on: " + root.screenName
                
                // Optioneel: Forceer strakke tekst-rendering zonder sub-pixel drift
                renderType: Text.QtRendering
            }
        }
    }
}