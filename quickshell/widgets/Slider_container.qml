import Quickshell
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../slider_elements"
import "../"
import "."

Rectangle {
    id: volume_slider_container

    anchors {
        top: contentWrapper.top
        bottom: contentWrapper.bottom
        left: contentWrapper.left
        topMargin: 0
        margins: 16
    }

    width: 220
    radius: 24
    color: Colors.secondary_container

    RowLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 12

        MicSlider {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

        SpeakerSlider {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

        MediaSlider {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

        BrightnessSlider {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }
}