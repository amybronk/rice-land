// PopupManager.qml
pragma Singleton
import Quickshell
import QtQuick

Singleton {
    id: root

    property string activeScreen: ""
    property bool isOpen: false

    Timer {
        id: closeTimer
        interval: 300
        repeat: false
        onTriggered: {
            // Pas als de timer écht afloopt sluiten we de popup en wissen we het scherm
            root.isOpen = false
            root.activeScreen = ""
        }
    }

    function setHovered(screenName, hovered) {
        if (hovered) {
            // Muis komt op bar of popup: stop de sluit-timer direct!
            closeTimer.stop()
            root.activeScreen = screenName
            root.isOpen = true
        } else {
            // Muis verlaat bar of popup:
            // Check of het signaal wel komt van het scherm dat nu open staat
            if (root.activeScreen === screenName) {
                // Laat activeScreen nog even staan zolang de timer loopt!
                closeTimer.restart()
            }
        }
    }
}