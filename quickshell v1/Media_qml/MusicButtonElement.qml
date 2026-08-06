import Quickshell
import QtQuick
import Qt5Compat.GraphicalEffects
import "../"

Rectangle {
    id: musicButton

	width: Style.barbuttonlengt
	radius: Style.radiusGrooteM
	color: Style.achtergrondKleur

	layer.enabled: true
	layer.effect: OpacityMask {
		maskSource: Rectangle {
			width: musicButton.width
			height: musicButton.height
			radius: musicButton.radius
		}
	}


	ThumbnailArt {
		anchors.fill: parent
		artUrl: MprisService.activePlayer?.metadata["mpris:artUrl"] ?? ""
	}

	Rectangle {
		anchors.fill: parent
		color: "transparent"
		radius: parent.radius
		border {
			color: Style.borderKleur
			width: Style.barBorderSize
		}
	}

	HoverHandler {
		id: musicHover
		cursorShape: Qt.PointingHandCursor
		onHoveredChanged: {
			if (hovered) {
				if (musiccontrol.item) musiccontrol.item.stopSluiten()
			} else {
				if (musiccontrol.active && musiccontrol.item) musiccontrol.item.startSluiten()
			}
		}
	}

	TapHandler { onTapped: musiccontrol.active = true }

	scale: musicHover.hovered ? Style.growAnimateM : 1.0

	Behavior on scale {
		NumberAnimation { duration: Style.animateTime; easing.type: Easing.OutCubic }
	}
}