// bar/Bar.qml
import Quickshell
import Quickshell.Io
import QtQuick
import "../systemPopup"
import "../widgets"
import "../"
import "."

PanelWindow {
  id: barWindow

  

  // Dit is verplicht voor Quickshell Variants zodat hij per scherm weet welke data bij hoort
  required property var modelData
  screen: modelData

  anchors {
      top: true
      left: true
      right: true
  }
    
  implicitHeight: 40
  color: Colors.background

  Clock {
        id: clock_center
        anchors.centerIn: parent

        // Text color stays inverted as long as the popup is open on this screen
        isHovered: PopupManager.isOpen && PopupManager.activeScreen === barWindow.screen.name

        HoverHandler {
            id: clock_hover_Handler
            onHoveredChanged: {
                PopupManager.setHovered(barWindow.screen.name, hovered)
            }
        }
    }


}



