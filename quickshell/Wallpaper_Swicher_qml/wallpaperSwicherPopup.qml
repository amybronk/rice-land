import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import "../"

ShellRoot {
    id: rootWindow

    signal requestClose()

    // Model weer lokaal in de popup
    ListModel { id: wallpaperModel }
    

    Variants {
        model: Quickshell.screens

        PanelWindow {
            // In QS 0.3.0 moet modelData expliciet gedeclareerd worden
            property var modelData

            screen: modelData

            implicitHeight: 350

            anchors {
                bottom: true
                left: true
                right: true
            }


            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.namespace: "qs-wallpaper-switcher"
            WlrLayershell.exclusiveZone: 0

            color: "transparent"

            

            Rectangle {
                id: popupContainer

                anchors {
                    fill: parent
                    margins: Style.uiMarginsG
                }

            // Verschuift het hele blok zonder de anchors te verstoren
            transform: Translate {
                id: slideUp
                y: 0
            }

            NumberAnimation {
                id: openAnim
                target: slideUp
                property: "y"
                from: 350 // Start onder de rand van het venster (implicitHeight is 350)
                to: 0
                duration: Style.exitTimer
                easing.type: Easing.OutCubic
                running: !Style.disableMvAnimation
            }

                //height: parent.height - 20
                color: "transparent"
                radius: Style.radiusGrooteL

                Rectangle {
                    id: titleBar

                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                        

                        topMargin: Style.uiMarginsM
                        leftMargin: Style.uiMarginsM
                        rightMargin: Style.uiMarginsG
                        
                    }
                    height: Style.barHoogte
                    color: "transparent"

                    Rectangle {
                        id: titelContainer

                        color: Style.popupAchtergrondKleur
                        radius: Style.radiusGrooteM
                        width: 200

                        border {
                            color: Style.borderKleur
                            width: Style.borderSize
                        }

                        anchors {
                            top: parent.top
                            bottom: parent.bottom
                            horizontalCenter: parent.horizontalCenter
                        }

                        Text {
                            id: title
                            text: "Wallpaper kiezen"
                            color: Style.textKleur
                            font.family: Style.globalFontFamily
                            font.pixelSize: parent.height * 0.4
                            anchors {
                                verticalCenter: parent.verticalCenter
                                horizontalCenter: parent.horizontalCenter
                            }
                        }

                        HoverHandler { id: titleHover; cursorShape: Qt.PointingHandCursor }
                        TapHandler {
                            onTapped: {
                                diropenner.command = ["xdg-open", Style.wallpaperDir];
                                diropenner.running = true;

                            }
                        }
                    }

                    // Sluitknop
                    Rectangle {
                        id: closeButton
                        width: closeButton.height
                        radius: Style.radiusGrooteM
                        color: closeHover.hovered ? Style.accentKleur : Style.popupAchtergrondKleur
                        border.color: Style.borderKleur
                        border.width: Style.borderSize

                        anchors {
                            top: parent.top
                            bottom:parent.bottom

                            left: titelContainer.right
                            leftMargin: Style.uiMarginsM
                        }

                        Text {
                            text: "x"
                            color: Style.textKleur
                            font.pixelSize: closeButton.height * 0.7
                            font.family: Style.globalFontFamily
                            anchors {
                                centerIn: parent

                                verticalCenterOffset: -1
                                horizontalCenterOffset: 0
                            }
                        }

                        HoverHandler { id: closeHover; cursorShape: Qt.PointingHandCursor }
                        TapHandler { onTapped: rootWindow.requestClose() }

                        scale: closeHover.hovered ? Style.growAnimateM : 1
                            
                        Behavior on scale {
                            NumberAnimation { duration: Style.animateTime; easing.type: Easing.OutCubic }
                        }
                    }
                }

                // Horizontaal scrollbare lijst
                ListView {
                    id: wallpaperList

                    anchors {
                        top: titleBar.bottom
                        left: parent.left
                        right: parent.right
                        bottom: parent.bottom
                        margins: Style.uiMarginsG
                        topMargin: Style.uiMarginsL
                    }

                    orientation: ListView.Horizontal
                    spacing: Style.uiMarginsL
                    flickableDirection: Flickable.AutoFlickDirection
                    clip: true
                    cacheBuffer: 1000 // Houdt items buiten beeld alvast 'klaar' voor soepel scrollen

                    ScrollBar.horizontal: ScrollBar {
                        id: scrollBar
                        policy: ScrollBar.AsNeeded
                    }

                    // Verbeterde scroll-afhandeling voor muiswiel
                    MouseArea {
                        anchors.fill: parent
                        propagateComposedEvents: true
                        onWheel: (event) => {
                            wallpaperList.contentX = Math.max(0, Math.min(wallpaperList.contentWidth - wallpaperList.width, wallpaperList.contentX - event.angleDelta.y));
                        }
                        // Zorg dat we klik-events niet blokkeren voor de wallpapers
                        onPressed: (mouse) => mouse.accepted = false
                        onReleased: (mouse) => mouse.accepted = false
                    }

                    model: wallpaperModel

                    delegate: Item {
                        width: 300
                        height: wallpaperList.height

                        Item {
                            id: wallpaperItem
                            anchors.fill: parent
                            
                            scale: itemHover.hovered ? Style.shrinkAnimateS : 1
                            
                            Behavior on scale {
                                NumberAnimation { duration: Style.animateTime; easing.type: Easing.OutCubic }
                            }

                            // 1. De afbeelding met het masker (onderop)
                            Item {
                                id: imageContainer
                                anchors.fill: parent
                                layer.enabled: true
                                layer.effect: OpacityMask {
                                    maskSource: Rectangle {
                                        width: imageContainer.width
                                        height: imageContainer.height
                                        radius: Style.radiusGrooteM
                                    }
                                }

                            Image {
                                anchors.fill: parent
                                source: "file://" + model.filePath
                                fillMode: Image.PreserveAspectCrop
                                sourceSize.width: 300 // Beperk resolutie voor minder RAM-druk
                                sourceSize.height: 300
                                asynchronous: true
                                cache: true

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
                            }

                            // 2. De Border (bovenop de afbeelding)
                            Rectangle {
                                anchors.fill: parent
                                color: "transparent"
                                radius: Style.radiusGrooteM
                                border.color: itemHover.hovered ? Style.accentKleur : Style.borderKleur
                                border.width: Style.borderSize

                                Behavior on border.color {
                                    ColorAnimation { duration: Style.exitTimer / 2 }
                                }
                            }

                            Rectangle {
                                anchors {
                                    left: parent.left
                                    right: parent.right
                                    bottom: parent.bottom
                                }
                                height: Style.fontGrootteM + Style.uiMarginsM * 2
                                color: Qt.rgba(0, 0, 0, 0.5)
                                visible: itemHover.hovered
                            

                                Text {
                                    anchors {
                                        left: parent.left
                                        right: parent.right
                                        verticalCenter: parent.verticalCenter
                                        leftMargin: Style.uiMarginsL
                                        rightMargin: Style.uiMarginsS
                                    }
                                    text: model.fileName
                                    color: "white"
                                    font.family: Style.globalFontFamily
                                    font.pixelSize: Style.fontGrootteS
                                    elide: Text.ElideMiddle
                                }
                            }

                            HoverHandler { id: itemHover; cursorShape: Qt.PointingHandCursor }
                            
                            TapHandler {
                                onTapped: {
                                    wallpaperChanger.command = [
                                        "bash", "-c",
                                        "sh ~/.local/share/quickshell-dotfiles/scripts/backgroundSwicher/change_wallpaper.sh \"" + model.filePath + "\""
                                    ];
                                    wallpaperChanger.running = true;
                                }
                            }


                        }
                    }
                }
            }
        }
    }

    // De scanner is weer terug in de popup
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
        running: false
        stdout: StdioCollector {
            onStreamFinished: (text) => console.log(`Wallpaper change output: ${text}`)
        }
    }

    Process {
        id: diropenner
        running: false
        onStarted: console.log("Opening directory: " + Style.wallpaperDir)
        stdout: StdioCollector {
            onStreamFinished: (text) => {
                if (text) console.log("xdg-open output: " + text)
                rootWindow.requestClose()
            }
        }
    }
}