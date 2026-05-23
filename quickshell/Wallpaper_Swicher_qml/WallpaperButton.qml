import Quickshell
import QtQuick
import "../"

Rectangle {
    id: wallpaperButton

    width: Style.barbuttonlengt
    radius: Style.radiusGrooteM
    color: Style.achtergrondKleur

    // Wallpaper icoon — pas aan naar jouw nerd-font glyph als gewenst
    Text {
        anchors.centerIn: parent
        text: "\uF03E"        // nf-fa-picture_o  (Nerd Fonts)
        // text: "🖼"         // fallback zonder nerd-font
        font.family: Style.globalFontFamily
        font.pixelSize: Style.iconGrooteM
        color: Style.textKleur
    }

    // Border (zelfde als MusicButtonElement)
    Rectangle {
        anchors.fill: parent
        color: "transparent"
        radius: parent.radius
        border {
            color: Style.borderKleur
            width: Style.barBorderSize
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            wallpaperPopup.active = !wallpaperPopup.active
        }
    }
}
