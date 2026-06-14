import Quickshell
import QtQuick
import "../"

Rectangle {
    id: klokButton 

	visible: true
	radius: Style.radiusGrooteM
	implicitWidth: klok_column.width + 20
	color: Style.achtergrondKleur
	border {
		color: Style.borderKleur
		width: Style.barBorderSize
	}

	HoverHandler {
		id: klokHover
		cursorShape: Qt.PointingHandCursor
		onHoveredChanged: {
			if (hovered) {
				if (klokwidget.item) klokwidget.item.stopSluiten()
			} else {
				if (klokwidget.active && klokwidget.item) klokwidget.item.startSluiten()
			}
		}
	}

	TapHandler { onTapped: klokwidget.active = true }

	scale: klokHover.hovered ? Style.growAnimateS : 1.0

	Behavior on scale {
		NumberAnimation { duration: Style.animateTime; easing.type: Easing.OutCubic }
	}

	Column {
		id: klok_column
		spacing: -4
		anchors.centerIn: parent

		Text {
			id: klok_text
			color: Style.textKleur
			anchors.horizontalCenter: parent.horizontalCenter
			font.pixelSize: Style.fontKlokgrote
			text: Qt.formatDateTime(new Date(), "HH:mm:ss")
		}

		Text {
			id: date_text
			color: Style.textKleur
			anchors.horizontalCenter: parent.horizontalCenter
			font.pixelSize: Style.fontKlokgrote
			text: Qt.formatDateTime(new Date(), "dddd, dd MMMM yyyy")
		}

		Timer {
			interval: 1000
			running: true
			repeat: true
			onTriggered: {
				var date = new Date()
				klok_text.text = Qt.formatDateTime(date, "HH:mm:ss")
				date_text.text = Qt.formatDateTime(date, "dddd, dd MMMM yyyy")
			}
		}	
	}
}