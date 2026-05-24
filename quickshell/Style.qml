pragma Singleton
import QtCore
import QtQuick

Item {
    id: root
    
    readonly property string homePath: StandardPaths.standardLocations(StandardPaths.HomeLocation)[0].toString().replace("file://", "")
    readonly property string rootConfigDir: homePath + "/.config/quickshell/"

    Settings {
        id: styleSettings
        category: "Theme"
        // ~/.config/UserConfig/Quickshell.conf
    }

    property var settingsWinInstance: null

    function openSettings() {
        if (settingsWinInstance !== null && typeof settingsWinInstance !== "undefined" && settingsWinInstance.toString() !== "null") {
            try {
                settingsWinInstance.raise()
                settingsWinInstance.requestActivate()
                return
            } catch (e) {
                settingsWinInstance = null
            }
        }

        let component = Qt.createComponent(Qt.resolvedUrl("Settings_qml/SettingsMenu.qml"))
        
        if (component.status === Component.Ready) {
            let obj = component.createObject(null)
            
            if (obj !== null) {
                settingsWinInstance = obj
                settingsWinInstance.destroyed.connect(function() {
                    settingsWinInstance = null
                })
            } else {
                console.error("Fout: SettingsMenu kon niet worden aangemaakt. Error:", component.errorString())
            }
        } else if (component.status === Component.Error) {
            console.error("Fout bij laden SettingsMenu component:", component.errorString())
        }
    }

    function getSetting(key, defaultValue) {
        return styleSettings.value(key, defaultValue)
    }

    function setSetting(key, value) {
        root[key] = value
        styleSettings.setValue(key, value)
    }

    // --- COLOUR & MATUGEN INTEGRATION---
    property color basisAchtergrondKleur: getSetting("basisAchtergrondKleur", Kleuren.background)
    property color achtergrondKleur: Qt.rgba(basisAchtergrondKleur.r, basisAchtergrondKleur.g, basisAchtergrondKleur.b, (achtergrondTransparantie / 100.0))

    property color popupAchtergrondKleur: getSetting("popupAchtergrondKleur", Kleuren.surface)
    property color borderKleur: getSetting("borderKleur", Kleuren.outline)
    property color accentKleur: getSetting("accentKleur", Kleuren.primary)

    property color textKleur: getSetting("textKleur", Kleuren.on_background)
    property color textColourLink: getSetting("textColourLink", Kleuren.tertiary)      // Handig voor linkjes
    property color negatiefTextKleur: getSetting("negatiefTextKleur", Kleuren.on_primary) // Donkere tekst voor op lichte vlakken

    // Werkbladen (Workspaces)
    property color actiefWerkbaldKleur: getSetting("actiefWerkbaldKleur", Kleuren.primary)
    property color volleWerkbaldKleur: getSetting("volleWerkbaldKleur", Kleuren.primary_container)
    property color legeWerkbaldKleur: getSetting("legeWerkbaldKleur", Kleuren.surface_variant)

    // Specifieke Knoppen
    property color colourPowerButton: getSetting("colourPowerButton", Kleuren.error) // Gebruikt de Matugen 'error' (rood/roze) tint
    property color colourAppPalet: getSetting("colourAppPalet", Kleuren.secondary)
    property color colourSettingsButton: getSetting("colourSettingsButton", Kleuren.secondary_container)

    // --- INT & TRANSPARENCY ---
    // Instelling voor de achtergrond: 0 = onzichtbaar, 100 = volledig effen
    property int achtergrondTransparantie: getSetting("achtergrondTransparantie", 85)

    property int barHoogte: getSetting("barHoogte", 35)
    property int barbuttonlengt: getSetting("barbuttonlengt", 60)
    property int mediaBorderSize: getSetting("mediaBorderSize", 0)
    property int barBorderSize: getSetting("barBorderSize", 0)
    property int borderSize: getSetting("borderSize", 2)
    property int topBarMargins: getSetting("topBarMargins", 2)
    property int bottomBarMargins: getSetting("bottomBarMargins", 4)

    property int uiMarginsS: getSetting("uiMarginsS", 2)
    property int uiMarginsM: getSetting("uiMarginsM", 5)
    property int uiMarginsL: getSetting("uiMarginsL", 10)
    property int uiMarginsG: getSetting("uiMarginsG", 15)

    property int fontGrootteS: getSetting("fontGrootteS", 8)
    property int fontGrootteM: getSetting("fontGrootteM", 10)
    property int fontGrootteL: getSetting("fontGrootteL", 14)
    property int fontGrootteG: getSetting("fontGrootteGrateS", 22) // Typo uit origineel behouden mocht je config hiernaar zoeken
    property int fontKlokgrote: getSetting("fontKlokgrote", ((barHoogte - (topBarMargins + bottomBarMargins)) / 2))

    property int iconGrooteS: getSetting("iconGrooteS", 12)
    property int iconGrooteM: getSetting("iconGrooteM", 18)
    property int iconGrooteL: getSetting("iconGrooteL", 22)

    property int radiusGrooteS: getSetting("radiusGrooteS", 4)
    property int radiusGrooteM: getSetting("radiusGrooteM", 10)
    property int radiusGrooteL: getSetting("radiusGrooteL", 14)


    property int exitTimer: getSetting("exitTimer", 350)
    property int fastRepeatTimer: getSetting("fastRepeatTimer", 500)
    property int slowRepeatTimer: getSetting("slowRepeatTimer", 2000)
    property bool disableMvAnimation: getSetting("disableMvAnimation", false)

    property int animateTime: getSetting("animateTime", 200)
    property int animateTimePopup: getSetting("animateTimePopup", 150)



    property real shrinkAnimateS: getSetting("shrinkAnimateS", 0.95)
    property real shrinkAnimateM: getSetting("shrinkAnimateM", 0.9)
    property real shrinkAnimateL: getSetting("shrinkAnimateL", 0.8)

    property real growAnimateS: getSetting("growAnimateS", 1.05)
    property real growAnimateM: getSetting("growAnimateM", 1.1)
    property real growAnimateL: getSetting("growAnimateL", 1.2)



    property int mediaWidth: getSetting("mediaWidth", 340)

    property int sliderThickness: getSetting("sliderThickness", 8)

    property int appletAppAmount: getSetting("appletAppAmount", 2)
    property int appletDrawrAmount: getSetting("appletDrawrAmount", 2)

    property string globalFontFamily: getSetting("globalFontFamily", "Hack")

    // --- directories ---
    readonly property string quickshellDir: rootConfigDir
    readonly property string saveStatDir: rootConfigDir + "SaveStates_txt/"
    readonly property string saveState: saveStatDir
    readonly property string wallpaperDir: homePath + "/Pictures/wallpapers/"

    readonly property var editableKeys: [
        // --- COLOUR ---
        "basisAchtergrondKleur", "popupAchtergrondKleur", "borderKleur", "accentKleur", "textKleur", "textColourLink", 
        "negatiefTextKleur", "actiefWerkbaldKleur", "volleWerkbaldKleur", "legeWerkbaldKleur", 
        "colourPowerButton", "colourAppPalet", "colourSettingsButton", 

        // --- INT ---
        "achtergrondTransparantie", "barHoogte", "barbuttonlengt", "barBorderSize", "borderSize","topBarMargins", "bottomBarMargins", 
        "uiMarginsS", "uiMarginsM", "uiMarginsL", "uiMarginsG", "fontGrootteS", "fontGrootteM", "fontGrootteL", 
        "fontGrootteG", "iconGrooteS", "iconGrooteM", "iconGrooteL", "radiusGrooteS", "radiusGrooteM", 
        "radiusGrooteL", "exitTimer", "fastRepeatTimer", "slowRepeatTimer", "sliderThickness", "appletAppAmount", 
        "appletDrawrAmount",

        // --- animate int ---
        "animateTime", "shrinkAnimateS", "shrinkAnimateM", "shrinkAnimateL", "growAnimateS", "growAnimateM", "growAnimateL"

    ]
}



/**/