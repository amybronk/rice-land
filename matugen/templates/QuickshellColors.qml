pragma Singleton
import QtQuick

QtObject {
    //  Main brand color
    readonly property color primary: "{{colors.primary.default.hex}}"

    //  Text/Icons on top of primary
    readonly property color on_primary: "{{colors.on_primary.default.hex}}"

    //  Subtle background for primary elements
    readonly property color primary_container: "{{colors.primary_container.default.hex}}"

    //  Text on top of primary container
    //readonly property color on_primary_container: "({colors.on_primary_container.default.hex})"

    //  Primary color for opposite theme
    //readonly property color inverse_primary: "({colors.inverse_primary.default.hex})"

    //  Less prominent accent color
    readonly property color secondary: "{{colors.secondary.default.hex}}"

    //  Text/Icons on top of secondary
    readonly property color on_secondary: "{{colors.on_secondary.default.hex}}"

    //  Subtle background for secondary elements
    readonly property color secondary_container: "{{colors.secondary_container.default.hex}}"

    //  Text on top of secondary container
    readonly property color on_secondary_container: "{{colors.on_secondary_container.default.hex}}"

    //  Contrasting accent color for balance
    readonly property color tertiary: "{{colors.tertiary.default.hex}}"

    //  Text/Icons on top of tertiary
    readonly property color on_tertiary: "{{colors.on_tertiary.default.hex}}"

    //  Subtle background for tertiary elements
    readonly property color tertiary_container: "{{colors.tertiary_container.default.hex}}"

    //  Text on top of tertiary container
    readonly property color on_tertiary_container: "{{colors.on_tertiary_container.default.hex}}"

    //  Color used for errors/warnings
    readonly property color error: "{{colors.error.default.hex}}"

    //  Text/Icons on top of error color
    readonly property color on_error: "{{colors.on_error.default.hex}}"

    //  Main background for components (cards, sheets)
    readonly property color surface: "{{colors.surface.default.hex}}"

    //  Primary text color on surfaces
    readonly property color on_surface: "{{colors.on_surface.default.hex}}"

    //  Secondary background for components
    readonly property color surface_variant: "{{colors.surface_variant.default.hex}}"

    //  Secondary text color on surfaces
    readonly property color on_surface_variant: "{{colors.on_surface_variant.default.hex}}"

    //  Color for borders and dividers
    readonly property color outline: "{{colors.outline.default.hex}}"

    //  Subtle divider/border color
    readonly property color outline_variant: "{{colors.outline_variant.default.hex}}"

    //  The absolute background of the app/screen
    readonly property color background: "{{colors.background.default.hex}}"

    //  Text on the main background
    readonly property color on_background: "{{colors.on_background.default.hex}}"

    //  Color used for elevation shadows
    readonly property color shadow: "{{colors.shadow.default.hex}}"

    //  Overlay color for modal backdrops
    readonly property color scrim: "{{colors.scrim.default.hex}}"

}