// widgets/Clock.qml
import QtQuick
import QtQuick.Layouts
import "../"
import ".."

ColumnLayout {
    id: clockLayout
    spacing: -4

    // Updated automatically via Bar.qml binding with PopupManager
    property bool isHovered: false

    // Top: Time
    Text {
        Layout.alignment: Qt.AlignHCenter
        text: Time.timeString 
        color: clockLayout.isHovered ? Colors.background : Colors.on_background
        font.pixelSize: 16
        font.bold: true

        Behavior on color {
            ColorAnimation { duration: 150 }
        }
    }

    // Bottom: Date
    Text {
        Layout.alignment: Qt.AlignHCenter
        text: Time.dateString 
        color: clockLayout.isHovered ? Colors.background : Colors.on_background
        font.pixelSize: 12

        Behavior on color {
            ColorAnimation { duration: 150 }
        }
    }
}