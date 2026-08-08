// media/Mediaprogresbar.qml
import QtQuick
import "../"

Rectangle {
    id: progresbar

    implicitWidth: 200
    implicitHeight: 12
    color: Colors.primary
    radius: 6

    // Koppel direct aan de visualProgress uit de controller
    // Geen timer meer nodig in de UI zelf, de controller doet het werk
    property real currentWidth: MprisController.visualProgress * width

    Rectangle {
        id: on_progresbar
        anchors {
            top: parent.top
            left: parent.left
            bottom: parent.bottom
        }
        
        // Directe binding
        width: MprisController.visualProgress * progresbar.width
        color: Colors.on_primary
        radius: parent.radius - 1
        
        // Omdat de timer in de controller snel genoeg tikt (10fps), 
        // heb je hier eigenlijk geen zware animatie meer nodig.
        // Dit voorkomt het "springende" effect.
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: (mouse) => {
            let ratio = mouse.x / width;
            MprisController.seekToRatio(ratio);
        }
    }
}