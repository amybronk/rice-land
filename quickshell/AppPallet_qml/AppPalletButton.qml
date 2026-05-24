import Quickshell
import QtQuick
import "../"

Rectangle {
    id: apppallet

	visible: true
	radius: Style.radiusGrooteM
	width: root.height
	color: Style.achtergrondKleur

	border {
		color: Style.borderKleur
		width: Style.barBorderSize
	}

	Text {
		anchors {
			centerIn: parent
			verticalCenterOffset: -apppallet.height * 0.03
			horizontalCenterOffset: -apppallet.width * 0.01
		}

		horizontalAlignment: Text.AlignHCenter
		verticalAlignment: Text.AlignVCenter

		text: "⌂"
		color: Style.colourAppPalet

		font {
        	family: Style.globalFontFamily
			pixelSize: apppallet.height * 0.9
			bold: true
		}
	}

	HoverHandler {
		id: paletHover
		cursorShape: Qt.PointingHandCursor
		onHoveredChanged: {
			if (hovered) {
				if (applet.item) applet.item.stopSluiten()
			} else {
				if (applet.active && applet.item) applet.item.startSluiten()
			}
		}
	}

	TapHandler { onTapped: applet.active = true }

	scale: paletHover.hovered ? Style.growAnimateM : 1.0

	Behavior on scale {
		NumberAnimation { duration: Style.animateTime; easing.type: Easing.OutCubic }
	}
}