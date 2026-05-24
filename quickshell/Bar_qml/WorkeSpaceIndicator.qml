import Quickshell
import QtQuick
import Quickshell.Hyprland
import "../"

Rectangle {
    id: tab
	visible: true
	radius: Style.radiusGrooteM
	width: row_workspace.width + 20
	color: Style.achtergrondKleur
	border {
		color: Style.borderKleur
		width: Style.barBorderSize
	}
	Row {
		id: row_workspace
		spacing: 10
		anchors.centerIn: parent

		Repeater {
			model: 9
			delegate: Text {
				property var ws: Hyprland.workspaces.values.find(w => w.id === index + 1)
				property bool isActive: Hyprland.focusedWorkspace?.id === (index + 1)
				font.pixelSize: Style.iconGrooteM
				text: {
					if (isActive) return "⍟" //⍟ | 🞊
					if (ws) return "⬤"
					return "⭘"
				}

				color: {
					if (isActive) return Style.actiefWerkbaldKleur
					if (ws) return Style.volleWerkbaldKleur
					return Style.legeWerkbaldKleur
				}

				HoverHandler { id: wsHover; cursorShape: Qt.PointingHandCursor }
				TapHandler { onTapped: Hyprland.dispatch("workspace " + (index + 1)) }

				scale: wsHover.hovered ? Style.growAnimateL : 1.0

				Behavior on scale {
					NumberAnimation { duration: Style.animateTime; easing.type: Easing.OutCubic }
				}
			}
		}
	}
}