pragma Singleton
import QtQuick

QtObject {
    //  Main brand color
    readonly property color primary: "#ffb0d0"

    //  Text/Icons on top of primary
    readonly property color on_primary: "#531d38"

    //  Subtle background for primary elements
    readonly property color primary_container: "#6e334e"

    //  Less prominent accent color
    readonly property color secondary: "#e1bdc9"

    //  Text/Icons on top of secondary
    readonly property color on_secondary: "#412a33"

    //  Subtle background for secondary elements
    readonly property color secondary_container: "#593f4a"

    //  Text on top of secondary container
    readonly property color on_secondary_container: "#fed9e5"

    //  Contrasting accent color for balance
    readonly property color tertiary: "#f1bb97"

    //  Text/Icons on top of tertiary
    readonly property color on_tertiary: "#49280f"

    //  Subtle background for tertiary elements
    readonly property color tertiary_container: "#633e23"

    //  Text on top of tertiary container
    readonly property color on_tertiary_container: "#ffdcc6"

    //  Color used for errors/warnings
    readonly property color error: "#ffb4ab"

    //  Text/Icons on top of error color
    readonly property color on_error: "#690005"

    //  Main background for components (cards, sheets)
    readonly property color surface: "#191114"

    //  Primary text color on surfaces
    readonly property color on_surface: "#eedfe2"

    //  Secondary background for components
    readonly property color surface_variant: "#504348"

    //  Secondary text color on surfaces
    readonly property color on_surface_variant: "#d5c2c7"

    //  Color for borders and dividers
    readonly property color outline: "#9d8c91"

    //  Subtle divider/border color
    readonly property color outline_variant: "#504348"

    //  The absolute background of the app/screen
    readonly property color background: "#191114"

    //  Text on the main background
    readonly property color on_background: "#eedfe2"

    //  Color used for elevation shadows
    readonly property color shadow: "#000000"

    //  Overlay color for modal backdrops
    readonly property color scrim: "#000000"

}