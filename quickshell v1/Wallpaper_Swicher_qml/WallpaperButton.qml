import Quickshell
import QtQuick
import "../"

Rectangle {
    id: wallpaperButton

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

    HoverHandler { id: wallHover; cursorShape: Qt.PointingHandCursor }
    TapHandler { onTapped: wallpaperPopup.active = !wallpaperPopup.active }

    scale: wallHover.hovered ? Style.growAnimateM : 1.0

    Behavior on scale {
        NumberAnimation { duration: Style.animateTime; easing.type: Easing.OutCubic }
    }
}
