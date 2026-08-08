// Thumbnail.qml
import QtQuick
import "../"
import "."

Image {
    fillMode: Image.PreserveAspectCrop
    
    // Bind directly to the singleton
    source: MprisController.trackArtUrl
    visible: status === Image.Ready

    Rectangle {
        anchors.fill: parent
        color: "grey" // Fallback color
        visible: parent.status !== Image.Ready
    }
}