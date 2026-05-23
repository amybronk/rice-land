import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Controls
import "../"

ShellRoot {
    id: rootWindow

    signal requestClose()

    // Model op ShellRoot-niveau zodat de Process er bij kan
    ListModel {
        id: wallpaperModel
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            // In QS 0.3.0 moet modelData expliciet gedeclareerd worden
            property var modelData

            screen: modelData

            anchors {
                bottom: true
                left: true
                right: true
            }

            implicitHeight: 280

            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.namespace: "qs-wallpaper-switcher"
            WlrLayershell.exclusiveZone: 0

            color: "transparent"

            Rectangle {
                id: popupContainer

                anchors {
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                    leftMargin: Style.uiMarginsG
                    rightMargin: Style.uiMarginsG
                    bottomMargin: Style.uiMarginsG
                }

                height: 260
                color: Style.popupAchtergrondKleur
                radius: Style.radiusGrooteL
                border.color: Style.borderKleur
                border.width: Style.borderSize

                // Titel
                Text {
                    id: titleLabel
                    text: "Wallpaper kiezen"
                    color: Style.textKleur
                    font.family: Style.globalFontFamily
                    font.pixelSize: Style.fontGrootteM
                    anchors {
                        top: parent.top
                        left: parent.left
                        topMargin: Style.uiMarginsM
                        leftMargin: Style.uiMarginsG
                    }
                }

                // Sluitknop
                Rectangle {
                    width: 22
                    height: 22
                    radius: 11
                    color: closeArea.containsMouse ? Style.accentKleur : "transparent"
                    border.color: Style.borderKleur
                    border.width: Style.borderSize

                    anchors {
                        top: parent.top
                        right: parent.right
                        topMargin: Style.uiMarginsM
                        rightMargin: Style.uiMarginsG
                    }

                    Text {
                        text: "✕"
                        color: Style.textKleur
                        font.pixelSize: Style.fontGrootteS
                        anchors.centerIn: parent
                    }

                    MouseArea {
                        id: closeArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: rootWindow.requestClose()
                    }
                }

                // Horizontaal scrollbare lijst
                ListView {
                    id: wallpaperList

                    anchors {
                        top: titleLabel.bottom
                        left: parent.left
                        right: parent.right
                        bottom: parent.bottom
                        margins: Style.uiMarginsG
                        topMargin: Style.uiMarginsM
                    }

                    orientation: ListView.Horizontal
                    spacing: Style.uiMarginsM
                    clip: true

                    ScrollBar.horizontal: ScrollBar {
                        policy: ScrollBar.AsNeeded
                    }

                    model: wallpaperModel

                    delegate: Item {
                        width: 200
                        height: wallpaperList.height

                        Rectangle {
                            anchors.fill: parent
                            radius: Style.radiusGrooteM
                            color: Style.basisAchtergrondKleur
                            border.color: itemHover.containsMouse ? Style.accentKleur : Style.borderKleur
                            border.width: Style.borderSize
                            clip: true

                            Image {
                                anchors.fill: parent
                                anchors.margins: itemHover.containsMouse ? Style.borderSize : 0
                                source: "file://" + model.filePath
                                fillMode: Image.PreserveAspectCrop
                                sourceSize.width: 200
                                sourceSize.height: 200
                                asynchronous: true

                                Rectangle {
                                    anchors.fill: parent
                                    color: Style.popupAchtergrondKleur
                                    visible: parent.status !== Image.Ready
                                    Text {
                                        anchors.centerIn: parent
                                        text: "⏳"
                                        font.pixelSize: Style.fontGrootteG
                                    }
                                }
                            }

                            Rectangle {
                                anchors {
                                    left: parent.left
                                    right: parent.right
                                    bottom: parent.bottom
                                }
                                height: Style.fontGrootteM + Style.uiMarginsM * 2
                                color: Qt.rgba(0, 0, 0, 0.6)
                                visible: itemHover.containsMouse

                                Text {
                                    anchors {
                                        left: parent.left
                                        right: parent.right
                                        verticalCenter: parent.verticalCenter
                                        leftMargin: Style.uiMarginsS
                                        rightMargin: Style.uiMarginsS
                                    }
                                    text: model.fileName
                                    color: "white"
                                    font.family: Style.globalFontFamily
                                    font.pixelSize: Style.fontGrootteS
                                    elide: Text.ElideMiddle
                                }
                            }

                            MouseArea {
                                id: itemHover
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    // 1. Haal het pad op en strip 'file://' er direct vanaf
                                    let rawPath = Style.rootConfigDir.replace("file://", "");
                                    let scriptPath = rawPath + "scripts/backgroundSwicher/change_wallpaper.sh";

                                    // 2. We dwingen bash om eerst exact te loggen welke paden QML doorgeeft
                                    wallpaperChanger.command = [
                                        "bash", "-c",
                                        "echo '--- QML KLIK GEREGISTREERD ---' >> /tmp/quickshell_debug.log; " +
                                        "echo 'Geconstrueerd scriptpad: '\"$1\" >> /tmp/quickshell_debug.log; " +
                                        "echo 'Gekozen wallpaperpad:    '\"$2\" >> /tmp/quickshell_debug.log; " +
                                        "sh \"$1\" \"$2\"", 
                                        "--", scriptPath, model.filePath
                                    ];

                                    // 3. Reset en start de actie
                                    wallpaperChanger.running = false;
                                    wallpaperChanger.running = true;
                                    
                                    rootWindow.requestClose();
                                }
                            }

                            Behavior on border.color {
                                ColorAnimation { duration: Style.exitTimer / 2 }
                            }
                        }
                    }
                }
            }

            NumberAnimation {
                target: popupContainer
                property: "anchors.bottomMargin"
                from: -popupContainer.height
                to: Style.uiMarginsG
                duration: Style.exitTimer
                easing.type: Easing.OutCubic
                running: true
            }
        }
    }

    Process {
        id: wallpaperScanner
        command: [
            "bash", "-c",
            "find ~/Pictures/wallpapers/ -type f \\( " +
            "-name '*.jpg' -o -name '*.jpeg' -o -name '*.png' -o " +
            "-name '*.webp' -o -name '*.gif' -o -name '*.bmp' -o " +
            "-name '*.tiff' -o -name '*.qoi' -o -name '*.ico' \\) | sort"
        ]
        running: true
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: (line) => {
                const pad = line.trim()
                if (pad !== "") {
                    const delen = pad.split("/")
                    wallpaperModel.append({
                        "filePath": pad,
                        "fileName": delen[delen.length - 1]
                    })
                }
            }
        }
    }

    Process {
        id: wallpaperChanger
        // command wordt nu dynamisch gevuld vanuit de onClicked hierboven

        // Dit print weergaven van je script (zoals "Wallpaper succesvol veranderd") naar je Quickshell terminal
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: (line) => console.log("[Wallpaper Script]:", line.trim())
        }

        // Dit vangt fouten op (zoals "sh: file not found" of Matugen errors)
        stderr: SplitParser {
            splitMarker: "\n"
            onRead: (line) => console.warn("[Wallpaper Script ERROR]:", line.trim())
        }
    }
}
