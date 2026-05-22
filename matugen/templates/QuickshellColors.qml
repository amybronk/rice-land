// quickshell/Kleuren.qml.template
pragma Singleton
import QtQuick

QtObject {
    // Basis achtergronden
    readonly property color background: "{{colors.background.default.hex}}" !== "{{colors.background.default.hex}}" ? "{{colors.background.default.hex}}" : "#1f1f1f"
    readonly property color surface: "{{colors.surface.default.hex}}" !== "{{colors.surface.default.hex}}" ? "{{colors.surface.default.hex}}" : "#2b2b2b"
    readonly property color surface_variant: "{{colors.surface_variant.default.hex}}" !== "{{colors.surface_variant.default.hex}}" ? "{{colors.surface_variant.default.hex}}" : "#3d3d3d"

    // Randen & Accenten
    readonly property color outline: "{{colors.outline.default.hex}}" !== "{{colors.outline.default.hex}}" ? "{{colors.outline.default.hex}}" : "#aa00a4"
    readonly property color primary: "{{colors.primary.default.hex}}" !== "{{colors.primary.default.hex}}" ? "{{colors.primary.default.hex}}" : "#520050"
    readonly property color primary_container: "{{colors.primary_container.default.hex}}" !== "{{colors.primary_container.default.hex}}" ? "{{colors.primary_container.default.hex}}" : "#3d0000"
    
    // Extra accentgroepen (perfect voor apppalets en links)
    readonly property color secondary: "{{colors.secondary.default.hex}}" !== "{{colors.secondary.default.hex}}" ? "{{colors.secondary.default.hex}}" : "#70e2ff"
    readonly property color secondary_container: "{{colors.secondary_container.default.hex}}" !== "{{colors.secondary_container.default.hex}}" ? "{{colors.secondary_container.default.hex}}" : "#6cff67"
    readonly property color tertiary: "{{colors.tertiary.default.hex}}" !== "{{colors.tertiary.default.hex}}" ? "{{colors.tertiary.default.hex}}" : "#ff00d0"

    // Tekst rollen
    readonly property color on_background: "{{colors.on_background.default.hex}}" !== "{{colors.on_background.default.hex}}" ? "{{colors.on_background.default.hex}}" : "#ffffff"
    readonly property color on_primary: "{{colors.on_primary.default.hex}}" !== "{{colors.on_primary.default.hex}}" ? "{{colors.on_primary.default.hex}}" : "#000000"

    // Foutmeldingen / Power buttons (Rood/Oranje tinten)
    readonly property color error: "{{colors.error.default.hex}}" !== "{{colors.error.default.hex}}" ? "{{colors.error.default.hex}}" : "#ff6cf5"
}