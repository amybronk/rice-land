import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../"

PopupWindow {
    id: klokwindow
    visible: true
    color: "transparent"

    

	implicitHeight: 300
    implicitWidth: 125

    anchor {
        window: barWindow
        rect: Qt.rect(
            barWindow.klokX + barWindow.klokWidth / 2 - implicitWidth / 2,
            barWindow.height,
            implicitWidth,
            implicitHeight
        )
    }

    // --- mouse detection ---
    HoverHandler {
        id: popupHover
        onHoveredChanged: {
            if (hovered) {
                closeTimer.stop()
            } else {
                closeTimer.start()
            }
        }
    }

    Timer {
        id: closeTimer
        interval: Style.exitTimer
        onTriggered: klokwidget.active = false
    }
    
    function stopSluiten() { closeTimer.stop() }
    function startSluiten() { closeTimer.start() }

    Item {
        id: rootui
        Rectangle {
            id: timeui

            height: (Style.barHoogte * 7) + (Style.uiMarginsG * 2)

            anchors {
                top: parent
                left: parent
                right: parent

            }

            
            Rectangle {
                id: timetext

                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right

                    leftMargin:  Style.uiMarginsM
                    rightMargin: Style.uiMarginsM
                }

                height: Style.barHoogte

                Text {
                    id: klok_text
                    color: Style.textKleur
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: Style.fontKlokgrote
                    text: Qt.formatDateTime(new Date(), "HH:mm:ss")
                }
            }

            Rectangle {
                id: analogklok

                anchors {
                    top: timetext.bottom
                    left: parent.left
                    right: parent.right

                    topMargin:   Style.uiMarginsG
                    leftMargin:  Style.uiMarginsM
                    rightMargin: Style.uiMarginsM
                    
                }

                height: Style.barHoogte * 6
            }
        }
        Rectangle {
            id: dateui

            anchors {
                top: timeui.bottom
                right: parent
                left: parent
                bottom: parent
            }
            
            Rectangle {
                id: datetext

                height: Style.barHoogte

                Text {
                    id: date_text
                    color: Style.textKleur
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: Style.fontKlokgrote
                    text: Qt.formatDateTime(new Date(), "dddd, dd MMMM yyyy")
                }
            }

            Rectangle {
                id: buttonui

                Rectangle {
                    id: lastmonth
                }

                Rectangle {
                    id: thismonth
                }

                Rectangle {
                    id: nextmonth
                }
            }
            Row {
                id: dayindecator
            }

            Grid {
                id: monthblok
            }
        }

        Timer {
			interval: 1000
			running: true
			repeat: true
			onTriggered: {
				var date = new Date()
				klok_text.text = Qt.formatDateTime(date, "HH:mm:ss")
				date_text.text = Qt.formatDateTime(date, "dddd, dd MMMM yyyy")
			}
		}
    }
}
