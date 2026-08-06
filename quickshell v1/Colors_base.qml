pragma Singleton
import QtQuick

QtObject {
    //base colours
    //  Default Background
    readonly property color base00: "({base16.base00.dark.hex})"

    //  Lighter Background (Status bars)
    readonly property color base01: "({base16.base01.hex})"

    //  Selection Background
    readonly property color base02: "({colors.base02.default.hex})"

    //  Comments, Invisibles
    readonly property color base03: "({colors.base03.default.hex})"

    //  Dark Foreground (Used for status bars)
    readonly property color base04: "({colors.base04.default.hex})"

    //  Default Foreground, Caret, Delimiters
    readonly property color base05: "({colors.base05.default.hex})"

    //  Light Foreground
    readonly property color base06: "({colors.base06.default.hex})"

    //  Light Background
    readonly property color base07: "({colors.base07.default.hex})"

    //  Variables, XML Tags, Red
    readonly property color base08: "({colors.base08.default.hex})"

    //  Integers, Boolean, Constants, Orange
    readonly property color base09: "({colors.base09.default.hex})"

    //  Classes, Strings, Functions, Yellow
    readonly property color base0a: "({colors.base0a.default.hex})"

    //  Strings, Inherited Class, Green
    readonly property color base0b: "({colors.base0b.default.hex})"

    //  Support, Regex, Escape Characters, Cyan
    readonly property color base0c: "({colors.base0c.default.hex})"

    //  Functions, Methods, Attribute IDs, Blue
    readonly property color base0d: "({colors.base0d.default.hex})"

    //  Keywords, Storage, Selector, Magenta
    readonly property color base0e: "({colors.base0e.default.hex})"

    //  Deprecated, Opening/Closing Embedded Tags, Brown
    readonly property color base0f: "({colors.base0f.default.hex})"
}