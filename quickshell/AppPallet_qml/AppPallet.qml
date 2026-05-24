import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import "../"

//AppPallet.qml


PopupWindow {
    id: appletWindow
    visible: true
    color: "transparent"

    property var recentIds: []

    implicitHeight: 663
    implicitWidth: 575

    anchor {
        window: barWindow
        rect: Qt.rect(
            barWindow.apppalletX + barWindow.apppalletWidth / 2 - implicitWidth / 2,
            barWindow.height,
            implicitWidth,
            implicitHeight
        )
    }

    


    HoverHandler {
        id: popupHover
        onHoveredChanged: {
            if (hovered) {
                closeTimer.stop()
                if (closeAnim.running) {
                    closeAnim.stop()
                    openAnim.from = slideDouwn.y
                    openAnim.start()
                } else if (slideDouwn.y < 0 && !openAnim.running) {
                    openAnim.from = -appletWindow.height
                    openAnim.start()
                }
            } else {
                closeTimer.start()
            }
        }
    }

    Timer {
        id: closeTimer
        interval: Style.exitTimer
        onTriggered: {
            if (!Style.disableMvAnimation) {
                closeAnim.start()
            } else {
                applet.active = false
            }
        }
    }

    function stopSluiten() { closeTimer.stop() }
    function startSluiten() { closeTimer.start() }

    Item {
        id: slideWrapper
        anchors.fill: parent

        transform: Translate {
            id: slideDouwn
            y: 0
        }

        NumberAnimation {
            id: openAnim
            target: slideDouwn
            property: "y"
            from: -appletWindow.height
            to: 0
            duration: Style.animateTimePopup
            easing.type: Easing.OutCubic
            running: !Style.disableMvAnimation
        }

        NumberAnimation {
            id: closeAnim
            target: slideDouwn
            property: "y"
            from: 0
            to: -appletWindow.height
            duration: Style.animateTimePopup
            easing.type: Easing.InCubic
            onStopped: if (slideDouwn.y <= -appletWindow.height + 1) applet.active = false
        }

        // --- UI ---
        Rectangle {
            id: searchContainer
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }

            focus: true
            Component.onCompleted: searchInput.forceActiveFocus()

            TapHandler {
                onTapped: (mouse) => {
                    searchInput.forceActiveFocus()
                    mouse.accepted = false
                }
            }

            height: 40
            color: Style.popupAchtergrondKleur
            radius: Style.radiusGrooteM

            border {
                color: searchInput.activeFocus ? Style.accentKleur : Style.borderKleur
                width: Style.borderSize
            }

            TextField {
                id: searchInput
                anchors.fill: parent
                anchors.margins: Style.uiMarginsS

                placeholderText: "Zoek apps..."
                placeholderTextColor: Qt.rgba(255, 255, 255, 0.4)
                color: "white"

                background: Item {}
                verticalAlignment: TextInput.AlignVCenter

                onTextChanged: {
                    console.log("Zoeken naar: " + text)
                }
            }
        }

        // --- top app box --- open apps
        Rectangle {
            id: openApps
            anchors {
                top: searchContainer.bottom
                left: parent.left
                right: parent.right
                topMargin: Style.uiMarginsM
            }

            height: 197.5
            color: Style.popupAchtergrondKleur
            radius: Style.radiusGrooteM
            border { color: Style.borderKleur; width: Style.borderSize }

            GridView {
                anchors.fill: parent
                cellWidth: appletWindow.width / 8
                cellHeight: parent.height / Style.appletDrawrAmount
                clip: true

                model: Hyprland.clients

                delegate: OpenAppButton {
                    required property var modelData
                    width: GridView.view.cellWidth
                    height: GridView.view.cellHeight
                    client: modelData
                }
            }
        }

        // --- center app box --- recente apps
        Rectangle {
            id: recentApps
            anchors {
                top: openApps.bottom
                left: parent.left
                right: parent.right
                topMargin: Style.uiMarginsM
            }

            height: 197.5
            color: Style.popupAchtergrondKleur
            radius: Style.radiusGrooteM
            border { color: Style.borderKleur; width: Style.borderSize }

            GridView {
                anchors.fill: parent
                cellWidth: appletWindow.width / 8
                cellHeight: parent.height / Style.appletDrawrAmount
                clip: true

                model: RecentApps.recentList

                delegate: AppButton {
                    width: GridView.view.cellWidth
                    height: GridView.view.cellHeight
                    appData: modelData
                }
            }
        }

        // --- bottom app box --- favorieten
        Rectangle {
            id: favoritApps
            anchors {
                top: recentApps.bottom
                left: parent.left
                right: parent.right
                topMargin: Style.uiMarginsM
            }

            height: 197.5
            color: Style.popupAchtergrondKleur
            radius: Style.radiusGrooteM
            border { color: Style.borderKleur; width: Style.borderSize }

            GridView {
                anchors.fill: parent
                cellWidth: appletWindow.width / 8
                cellHeight: parent.height / Style.appletDrawrAmount
                clip: true

                model: Favorites.apps

                delegate: AppButton {
                    width: GridView.view.cellWidth
                    height: GridView.view.cellHeight
                    appData: modelData
                }
            }
        }
    }
}