// widgets/Clock.qml
import QtQuick
import QtQuick.Layouts
import "../"
import ".."

ColumnLayout {
    id: clockLayout

    // Updated automatically via Bar.qml binding with PopupManager
    property bool isHovered: false

    // Smoothly animate layout spacing to 0 when hovered
    spacing: isHovered ? 0 : -4

    Behavior on spacing {
        NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
    }

    // Top: Time
    Text {
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        text: Time.timeString 
        color: Colors.on_background
        
        property real currentFontSize: clockLayout.isHovered ? 36 : 16
        font.pixelSize: currentFontSize
        font.bold: true

        Behavior on currentFontSize {
            NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
        }
    }

    // Bottom: Date
    Text {
        id: dateText
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        text: Time.dateString 
        color: clockLayout.isHovered ? Colors.background : Colors.on_background
        font.pixelSize: 12

        // Fade out and collapse height on hover
        opacity: clockLayout.isHovered ? 0 : 1
        Layout.preferredHeight: clockLayout.isHovered ? 0 : implicitHeight

        Behavior on opacity {
            NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
        }


        Behavior on color {
            ColorAnimation { duration: 150 }
        }
    }
}