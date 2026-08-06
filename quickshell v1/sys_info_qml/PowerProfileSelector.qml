import Quickshell
import Quickshell.Io
import QtQuick
import "../"

Item {
    id: root
    height: Style.barHoogte
    width: parent.width

    // Zorgt dat de dropdown boven de andere elementen in de PowerWidgit komt
    z: dropdownOpen ? 100 : 0

    property string huidigProfiel: ""
    property var profielen: ["power-saver", "balanced", "performance"]
    property bool dropdownOpen: false

    // Huidig profiel ophalen
    Process {
        id: getProfielProc
        command: ["powerprofilesctl", "get"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                const t = data.trim()
                if (t !== "") root.huidigProfiel = t
            }
        }
    }

    // Profiel instellen
    Process {
        id: setProfielProc
        property string doel: ""
        command: ["powerprofilesctl", "set", doel]
        onExited: (code, _) => {
            if (code === 0) root.huidigProfiel = doel
        }
    }

    Rectangle {
        id: selectorButton
        anchors.fill: parent
        border {
            color: Style.borderKleur
            width: Style.borderSize
        }
        color: "transparent"
        radius: Style.radiusGrooteM

        Row {
            anchors.centerIn: parent
            spacing: 8

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: root.huidigProfiel !== "" ? root.huidigProfiel : "laden…"
                color: Style.textKleur
                font {
                    family: Style.globalFontFamily
                    pixelSize: parent.height * 0.5
                    bold: true
                }
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "▾"
                color: Style.textKleur
                font.pixelSize: 14
            }
        }

        HoverHandler { id: profilleHover; cursorShape: Qt.PointingHandCursor }
        MouseArea {
            anchors.fill: parent
            onClicked: root.dropdownOpen = !root.dropdownOpen
        }

        scale: profilleHover.hovered ? Style.growAnimateS : 1.0
        Behavior on scale {
            NumberAnimation { duration: Style.animateTime; easing.type: Easing.OutCubic }
        }
    }

    // De Dropdown Overlay
    Rectangle {
        id: profielDropdown
        visible: root.dropdownOpen
        z: 100

        // MouseArea blokkeert events fysiek voor alles wat erachter ligt.
        MouseArea { anchors.fill: parent }

        anchors {
            top: selectorButton.bottom
            topMargin: Style.uiMarginsM / 2
            horizontalCenter: parent.horizontalCenter
        }
        width: parent.width
        height: root.profielen.length * (Style.barHoogte + Style.uiMarginsM) + Style.uiMarginsM

        color: Style.popupAchtergrondKleur
        radius: Style.radiusGrooteM
        border {
            color: Style.borderKleur
            width: Style.borderSize
        }

        Column {
            anchors.fill: parent
            anchors.margins: Style.uiMarginsM
            spacing: Style.uiMarginsM / 2

            Repeater {
                model: root.profielen
                Rectangle {
                    width: parent.width
                    height: Style.barHoogte
                    color: "transparent"
                    radius: Style.radiusGrooteM
                    border {
                        color: modelData === root.huidigProfiel ? Style.textKleur : Style.borderKleur
                        width: Style.borderSize
                    }

                    Text {
                        anchors.centerIn: parent
                        text: modelData
                        color: Style.textKleur
                        font {
                            family: Style.globalFontFamily
                            pixelSize: parent.height * 0.5
                            bold: modelData === root.huidigProfiel
                        }
                    }

                    HoverHandler { id: itemHover; cursorShape: Qt.PointingHandCursor }
                    TapHandler {
                        onTapped: {
                            setProfielProc.doel = modelData
                            setProfielProc.running = true
                            root.dropdownOpen = false
                        }
                    }
                }
            }
        }
    }
}
