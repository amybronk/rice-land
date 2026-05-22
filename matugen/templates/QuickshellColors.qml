pragma Singleton
import QtQuick

QtObject {
    // Basis achtergronden
    readonly property color background: "{{colors.background.hex}}"
    readonly property color surface: "{{colors.surface.hex}}"
    readonly property color surface_variant: "{{colors.surface_variant.hex}}"

    // Randen & Accenten
    readonly property color outline: "{{colors.outline.hex}}"
    readonly property color primary: "{{colors.primary.hex}}"
    readonly property color primary_container: "{{colors.primary_container.hex}}"
    
    // Extra accentgroepen
    readonly property color secondary: "{{colors.secondary.hex}}"
    readonly property color secondary_container: "{{colors.secondary_container.hex}}"
    readonly property color tertiary: "{{colors.tertiary.hex}}"

    // Tekst rollen
    readonly property color on_background: "{{colors.on_background.hex}}"
    readonly property color on_primary: "{{colors.on_primary.hex}}"

    // Foutmeldingen / Power buttons
    readonly property color error: "{{colors.error.hex}}"
}