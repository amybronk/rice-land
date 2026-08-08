// shell.qml
import Quickshell
import QtCore
import QtQuick
import "."
import "bar"
import "widgets"
import "systemPopup"

ShellRoot {
    id: shellRoot

    Variants {
        model: Quickshell.screens
        
        // Quickshell stuurt de schermen automatisch naar de modelData property in Bar.qml
        delegate: Bar {}
    }
    Variants {
        model: Quickshell.screens
        delegate: PanelWindow {
            id: popupWindow
            required property var modelData
            screen: modelData

            color: "transparent"

            exclusionMode: ExclusionMode.Ignore
            aboveWindows: true

            anchors {
                top: true
            }
            
            margins {
                top: 40
            }

            implicitWidth: popupContent.width
            implicitHeight: popupContent.height

            // Unmaps surface from Wayland completely when false
            visible: popupContent.shouldBeVisible

            Multi {
                id: popupContent
                screenName: popupWindow.screen.name
                isCurrentScreen: PopupManager.activeScreen === popupWindow.screen.name
            }
        }
    }
}
