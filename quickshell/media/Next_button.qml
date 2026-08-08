// Next_button.qml
import QtQuick
import "../"
import "."

Rectangle {

    Text {
        anchors.centerIn: parent
        text: "⏭"
        color: next_buton.hovered ? Colors.on_tertiary : Colors.on_primary
        leftPadding: 0
        topPadding: 0

        font {
            family: "hack"
            pixelSize: 32
        }
    }

    TapHandler {
        id: tapHandler
        // Call the singleton method on tap
        onTapped: MprisController.next()
    }
}