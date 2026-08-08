// PlayPauseButton.qml
import QtQuick
import "../"
import "."


Rectangle {

    Text {
        anchors.centerIn: parent
        text: MprisController.isPlaying ? "⏸" : "⏵"
        color: pause_buton.hovered ? Colors.on_tertiary : Colors.on_primary
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
        onTapped: MprisController.playPause()
    }
}