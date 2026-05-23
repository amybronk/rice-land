pragma Singleton
import QtQuick

QtObject {
    // Basis achtergronden
    readonly property color background: "#191114"
    readonly property color surface: "#191114"
    readonly property color surface_variant: "#504348"

    // Randen & Accenten
    readonly property color outline: "#9d8c91"
    readonly property color primary: "#ffb0d0"
    readonly property color primary_container: "#6e334e"
    
    // Extra accentgroepen
    readonly property color secondary: "#e1bdc9"
    readonly property color secondary_container: "#593f49"
    readonly property color tertiary: "#f1bb97"

    // Tekst rollen
    readonly property color on_background: "#eedfe2"
    readonly property color on_primary: "#531d37"

    // Foutmeldingen / Power buttons
    readonly property color error: "#ffb4ab"
}