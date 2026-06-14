import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import "../"

Item {
    id: batteryRoot
    width: hasBattery ? Style.barbuttonlengt : 0 
    height: parent.height
    visible: hasBattery 


    property int percentage: 0
    property string status: "Discharging"
    property bool hasBattery: false
    property string currentProfile: ""

    // Hulpproperty voor de kleur van de tekst (op basis van profiel)
    readonly property color textColorByProfile: {
        if (currentProfile === "power-saver") return "#a3be8c"; // Groen
        if (currentProfile === "balanced") return '#ff8400';    // oranje
        if (currentProfile === "performance") return '#ae0011'; // rood
        return Style.textKleur;
    }

    // Hulpproperty voor de achtergrondkleur van de widget (op basis van status)
    readonly property color widgetBackgroundColor: {
        if (status === "Charging") return Qt.rgba(1.0, 0.8, 0.4, 0.2); // Licht oranje
        if (percentage < 20) return Qt.rgba(1, 0.23, 0.23, 0.15); // Licht rood
        return Style.achtergrondKleur;
    }

    Process {
        id: detectBattery
        command: ["bash", "-c", "ls /sys/class/power_supply/BAT* >/dev/null 2>&1 && echo 1 || echo 0"]
        stdout: SplitParser {
            onRead: (data) => batteryRoot.hasBattery = (data.trim() === "1")
        }
    }

    Component.onCompleted: {
        detectBattery.running = true
        getProfileProc.running = true
    }

    Timer {
        interval: 10000 // Update elke 10 seconden
        running: true // Altijd draaien voor profiel updates
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (hasBattery) {
                batCheck.running = true
                statusCheck.running = true
            }
            getProfileProc.running = true
        }
    }

    Process {
        id: getProfileProc
        command: ["powerprofilesctl", "get"]
        stdout: SplitParser {
            onRead: (data) => batteryRoot.currentProfile = data.trim()
        }
    }

    Process {
        id: batCheck
        command: ["bash", "-c", "cat /sys/class/power_supply/BAT*/capacity | head -n 1"]
        stdout: SplitParser {
            onRead: (data) => {
                const p = parseInt(data.trim())
                batteryRoot.percentage = p
                
                // Automatisch schakelen naar power-saver
                if (p <= Style.batPsProcent && batteryRoot.status === "Discharging") {
                    setPowerSaver.running = true
                }
            }
        }
    }

    Process {
        id: setPowerSaver
        command: ["powerprofilesctl", "set", "power-saver"]
        onExited: {
            getProfileProc.running = true
        }
    }

    Process {
        id: statusCheck
        command: ["bash", "-c", "cat /sys/class/power_supply/BAT*/status | head -n 1"]
        stdout: SplitParser {
            onRead: (data) => batteryRoot.status = data.trim()
        }
    }

    Rectangle {
        id: rootui
        height: parent.height
        color: widgetBackgroundColor // Gebruik de nieuwe property voor de achtergrond
        radius: Style.radiusGrooteM
        anchors {
            fill: parent
        }

        Row {
            id: row
            anchors.centerIn: parent
            spacing: Style.uiMarginsS

            Text {
                id: icon
                text: {
                    if (batteryRoot.status === "Charging") return "⚡";
                    if (batteryRoot.percentage < 20) return "🪫";
                    return "🔋";
                }
                font.pixelSize: batteryRoot.height * 0.5
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                color: textColorByProfile // Tekstkleur op basis van profiel
            }

            Text {
                id: batText
                text: batteryRoot.percentage + "%"
                font.pixelSize: batteryRoot.height * 0.5
                font.family: Style.globalFontFamily
                color: textColorByProfile // Tekstkleur op basis van profiel
            }
        }
    }

    HoverHandler {
        id: batHover
        cursorShape: Qt.PointingHandCursor
    }

    scale: batHover.hovered ? Style.growAnimateM : 1.0

	Behavior on scale {
		NumberAnimation { duration: Style.animateTime; easing.type: Easing.OutCubic }
	}
}