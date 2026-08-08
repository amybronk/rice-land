import QtQuick
import QtQuick.Layouts
import Quickshell
import "../media"
import "../"

ColumnLayout {
    id: root
    spacing: 12

    // --- REACTIVE STATE ---
    readonly property real backendVolume: (typeof MprisController !== "undefined" && MprisController) ? (MprisController.volume * 100) : 0

    property real dragVolume: 0
    readonly property real currentVolume: sliderMouseArea.pressed ? dragVolume : backendVolume

    // --- ACTIONS ---
    function setVolume(percentage) {
        if (typeof MprisController !== "undefined" && MprisController) {
            let clamped = Math.max(0, Math.min(100, percentage));
            MprisController.volume = clamped / 100.0;
        }
    }

    // --- SLIDER TRACK ---
    Rectangle {
        id: sliderBackground
        Layout.preferredWidth: 15
        Layout.fillHeight: true
        Layout.alignment: Qt.AlignHCenter
        color: Colors.primary
        radius: 4

        Rectangle {
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }

            height: (parent.height / 100) * root.currentVolume
            color: Colors.on_primary
            radius: 2

            Behavior on height {
                enabled: !sliderMouseArea.pressed
                NumberAnimation {
                    duration: 150
                    easing.type: Easing.OutQuad
                }
            }
        }

        MouseArea {
            id: sliderMouseArea
            anchors.fill: parent

            function updateSlider(mouseY) {
                let percent = 1.0 - (mouseY / height);
                percent = Math.max(0.0, Math.min(1.0, percent));
                let val = percent * 100;
                root.dragVolume = val;
                root.setVolume(val);
            }

            onPressed: (mouse) => updateSlider(mouse.y)
            onPositionChanged: (mouse) => updateSlider(mouse.y)
        }
    }

    // --- ICON ---
    Rectangle {
        Layout.preferredWidth: 30
        Layout.preferredHeight: 30
        Layout.alignment: Qt.AlignHCenter
        color: Colors.primary
        radius: 4

        Text {
            anchors.centerIn: parent
            topPadding: 2
            text: "🎵"
            color: Colors.on_primary

            font {
                pixelSize: 20
                family: "hack"
            }
        }
    }
}