//media/Mediaplayer.qml
import Quickshell
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../"
import "."

Rectangle {
    id: mediaplayer

    color: Colors.secondary_container

    Thumbnail {
        id: media_thumbnail

        anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.top
            topMargin: 24
        }

        width: 150
        height: 150
        //radius: 20
    }

    Text {
        id: songname
        text: MprisController.trackTitle
        color: Colors.on_background

        anchors {
            top: media_thumbnail.bottom
            left: parent.left
            right:parent.right
            topMargin: 12
            margins: 5
        }

        horizontalAlignment: Text.AlignHCenter

        wrapMode: Text.Wrap
        elide: Text.ElideRight
        maximumLineCount: 2

        font {
            pixelSize: 12
        }
    }

    Text {
        id: artistname
        text: MprisController.trackArtist
        color: Colors.on_background

        anchors {
            top: songname.bottom
            topMargin: 10
            horizontalCenter: parent.horizontalCenter
        }

        elide: Text.ElideRight
        maximumLineCount: 1

        font {
            pixelSize: 16
            bold: true
        }
    }

    Progresbar {
        id: progresbar

        anchors {
            top: artistname.bottom
            left: parent.left
            right: parent.right
            topMargin: 10
            margins: 16
        }

        height: 15
        radius: 5
    }


    RowLayout {
        id: button_bar
        anchors {
            left: parent.left
            right: parent.right
            top: progresbar.bottom

            topMargin: 16
        }

        Item { Layout.fillWidth: true }

        Peff_buton {
            width: 30
            height: 30
            color: peff_buton.hovered ? Colors.tertiary : Colors.primary
            radius: 6

            HoverHandler {
                id: peff_buton
            }

            scale: peff_buton.hovered ? 1.2 : 1.0

            Behavior on scale { 
                NumberAnimation { 
                    duration: 150
                    easing.type: Easing.OutCubic 
                } 
            }
        }

        Item { Layout.fillWidth: true }

        Pause_button {
            width: 30
            height: 30
            color: pause_buton.hovered ? Colors.tertiary : Colors.primary
            radius: 6

            HoverHandler {
                id: pause_buton
            }

            scale: pause_buton.hovered ? 1.2 : 1.0

            Behavior on scale { 
                NumberAnimation { 
                    duration: 150
                    easing.type: Easing.OutCubic 
                } 
            }
        }

        Item { Layout.fillWidth: true }

        Next_button {
            width: 30
            height: 30
            color: next_buton.hovered ? Colors.tertiary : Colors.primary
            radius: 6

            HoverHandler {
                id: next_buton
            }

            scale: next_buton.hovered ? 1.2 : 1.0

            Behavior on scale { 
                NumberAnimation { 
                    duration: 150
                    easing.type: Easing.OutCubic 
                } 
            }
        }

        Item { Layout.fillWidth: true }
    }

    PlayerSelector {
        anchors {
            top: button_bar.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            margins: 10
            topMargin: 16
            bottomMargin: 16
        }
        
    }
}

