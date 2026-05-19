pragma Singleton
import QtQuick 2.15

QtObject {
    readonly property string background: "{{colors.surface.default.hex}}"
    readonly property string foreground: "{{colors.on_surface.default.hex}}"
    readonly property string primary: "{{colors.primary.default.hex}}"
    readonly property string secondary: "{{colors.secondary.default.hex}}"
    readonly property string accent: "{{colors.accent.default.hex}}"
}