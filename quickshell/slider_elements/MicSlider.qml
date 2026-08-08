import QtQuick
import QtQuick.Layouts
import "../"

ColumnLayout {
    id: root
    spacing: 12

    property real dragVolume: 0
    readonly property real currentVolume: sliderHandler.active ? dragVolume : Audio.micVolume

    // Mouse wheel scrolling
    WheelHandler {
        onWheel: (event) => {
            let step = event.angleDelta.y > 0 ? 5 : -5;
            Audio.setMicVolume(Audio.micVolume + step);
        }
    }

    // Slider Track
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

            height: (parent.height / 100) * (Audio.micMuted ? 0 : root.currentVolume)
            color: Colors.on_primary
            radius: 2

            Behavior on height {
                enabled: !sliderHandler.active
                NumberAnimation {
                    duration: 150
                    easing.type: Easing.OutQuad
                }
            }
        }

        // Efficient C++ based point tracking instead of MouseArea
        PointHandler {
            id: sliderHandler
            
            function updateVolume(mouseY) {
                let percent = 1.0 - (mouseY / sliderBackground.height);
                percent = Math.max(0.0, Math.min(1.0, percent));
                let val = percent * 100;
                root.dragVolume = val;
                Audio.setMicVolume(val);
            }

            // Trigger on initial tap
            onActiveChanged: {
                if (active) updateVolume(point.position.y);
            }

            // Trigger on dragging
            property real activeY: point.position.y
            onActiveYChanged: {
                if (active) updateVolume(activeY);
            }
        }
    }

    // Mute Button
    Rectangle {
        Layout.preferredWidth: 30
        Layout.preferredHeight: 30
        Layout.alignment: Qt.AlignHCenter
        color: muteButton.hovered ? Colors.tertiary : Colors.primary
        radius: 4

        Text {
            anchors.centerIn: parent
            topPadding: 2

            text: "🎙️"
            color: muteButton.hovered ? Colors.on_tertiary : Colors.on_primary

            font {
                pixelSize: 28
                family: "hack"
            }
        }

        Text {
            anchors.centerIn: parent
            topPadding: -1

            text: Audio.micMuted ? "/" : " "
            color: "red"

            font {
                pixelSize: 36
                family: "hack"
                weight: Font.ExtraLight
            }
        }

        HoverHandler { id: muteButton }
        TapHandler { onTapped: Audio.toggleMicMute() }

        scale: muteButton.hovered ? 1.2 : 1.0
        Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
    }
}