// media/PlayerSelector.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../"
import "."

Rectangle {
    id: root

    // Default implicit sizing so it adapts smoothly to Layouts
    implicitWidth: 160
    implicitHeight: 36

    // Styling integrated with your color palette and hover state
    color: dropdown_hover.hovered ? Colors.tertiary : Colors.primary
    radius: 20

    // Smooth hover animation
    scale: dropdown_hover.hovered ? 1.05 : 1.0

    Behavior on scale {
        NumberAnimation {
            duration: 150
            easing.type: Easing.OutCubic
        }
    }

    Behavior on color {
        ColorAnimation {
            duration: 150
        }
    }

    HoverHandler {
        id: dropdown_hover
    }

    TapHandler {
        // Cycle to the next available media player on tap
        onTapped: root.cycleToNextPlayer()
    }

    Text {
        id: playerText

        anchors {
            fill: parent
            leftMargin: 12
            rightMargin: 12
        }

        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        // Prevent text overflow on small containers
        elide: Text.ElideRight

        // Display current player identity or fallback to Auto
        text: {
            if (MprisController.manualPlayer && MprisController.manualPlayer.identity !== "") {
                return MprisController.manualPlayer.identity;
            }
            return "Auto (Default)";
        }

        color: dropdown_hover.hovered ? Colors.on_tertiary : Colors.on_primary

        font {
            // Scale font size according to widget height, bounded between 10px and 14px
            pixelSize: Math.max(10, Math.min(parent.height * 0.35, 14))
            bold: true
        }
    }

    // Cycling logic through available MPRIS players
    function cycleToNextPlayer() {
        let players = MprisController.availablePlayers || [];
        if (players.length === 0) return;

        // Create player list starting with "Auto"
        let playerList = ["Auto"];
        for (let i = 0; i < players.length; i++) {
            if (players[i] && players[i].identity) {
                playerList.push(players[i].identity);
            }
        }

        // Determine current active index
        let currentIndex = 0;
        if (MprisController.manualPlayer) {
            let foundIndex = playerList.indexOf(MprisController.manualPlayer.identity);
            if (foundIndex !== -1) currentIndex = foundIndex;
        }

        // Calculate next index (loops back to 0)
        let nextIndex = (currentIndex + 1) % playerList.length;

        if (nextIndex === 0) {
            MprisController.clearPlayerSelection();
        } else {
            MprisController.selectPlayerByName(playerList[nextIndex]);
        }
    }
}