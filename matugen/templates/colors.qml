pragma Singleton
import QtQuick 2.15

QtObject {
    readonly property string background: "#{{colors.surface.default.hex_stripped}}"
    readonly property string foreground: "#{{colors.on_surface.default.hex_stripped}}"
    readonly property string primary:    "#{{colors.primary.default.hex_stripped}}"
    readonly property string secondary:  "#{{colors.secondary.default.hex_stripped}}"
    readonly property string accent:     "#{{colors.tertiary.default.hex_stripped}}" 
}