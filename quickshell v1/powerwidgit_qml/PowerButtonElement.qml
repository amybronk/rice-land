import Quickshell
import QtQuick
import "../"

Rectangle { 
    id: powerButton

    visible: true
	radius: Style.radiusGrooteM
	width: Style.barHoogte
	color: Style.achtergrondKleur

	border {
		color: Style.borderKleur
		width: Style.barBorderSize
	}

	Text {
		anchors {
			centerIn: parent
			verticalCenterOffset: -powerButton.height * -0.04
			horizontalCenterOffset: -powerButton.width * 0.01
		}

		horizontalAlignment: Text.AlignHCenter
		verticalAlignment: Text.AlignVCenter

		text: "⏻"
		color: Style.colourPowerButton


		font{
        	family: Style.globalFontFamily 
			pixelSize: powerButton.height * 0.99
			bold: true
		}
	}

	HoverHandler {
		id: powerHover
		cursorShape: Qt.PointingHandCursor
		onHoveredChanged: {
			if (hovered) {
				if (powerwindow.item) powerwindow.item.stopSluiten()
			} else {
				if (powerwindow.active && powerwindow.item) powerwindow.item.startSluiten()
			}
		}
	}

	TapHandler { onTapped: powerwindow.active = true }

	scale: powerHover.hovered ? Style.growAnimateM : 1.0

	Behavior on scale {
		NumberAnimation { duration: Style.animateTime; easing.type: Easing.OutCubic }
	}
}