import Quickshell
import Quickshell.Io
import QtQuick
import "../"

PopupWindow {
    id: powermaneger
    visible: true
    color: "transparent"

    property int minuten: 5

    implicitHeight: ((Style.barHoogte * 8) + (Style.uiMarginsM * 10) + (Style.fontGrootteL + 4))
    implicitWidth: 200

    anchor {
        window: barWindow

        rect: Qt.rect(
            barWindow.powermanegerX + barWindow.powermanegerWidth / 2 - implicitWidth / 2,
            barWindow.height,
            implicitWidth,
            implicitHeight
        )
    }

    // --- mouse detection ---
    HoverHandler {
        id: popupHover

        onHoveredChanged: {

            if (hovered) {
                closeTimer.stop()
            } 
            else {
                closeTimer.start()
            }
        }
    }

    Timer {
        id: closeTimer
        interval: Style.exitTimer
        onTriggered: {
            if (!Style.disableMvAnimation) {
                closeAnim.start()
            } else {
                powerwindow.active = false
            }
        }
    }

    function stopSluiten() { closeTimer.stop() }
    function startSluiten() { closeTimer.start() }

    Process {
        id: openerQmlDir
        command: ["bash", "-c", "xdg-open " + Style.quickshellDir]
    }

    Process {
        id: openerSaveStates
        command: ["bash", "-c", "xdg-open " + Style.saveStatDir]
    }

    // .sh file for your ease of use / chaining.  "shutdown.sh"
    Process {
        id: shutdownProcess
        command: ["bash", Style.rootConfigDir + "scripts/shutdown.sh", powermaneger.minuten.toString()]
        onStarted: console.log("shutdown over", powermaneger.minuten, "minuten")
        onExited: (code, status) => console.log("exitcode:", code)
    }

    // directe shutdown — geen argument = "now"
    Process {
        id: shutdownNowProcess
        command: ["bash", Style.rootConfigDir + "scripts/shutdown.sh"]
        onStarted: console.log("shutdown now")
        onExited: (code, status) => console.log("exitcode:", code)
    }

    Process {
        id: sleepProc
        command: ["bash", "-c", Style.rootConfigDir + "scripts/sleep.sh"] // .sh file for your ease of use / chaining.  "sleep.sh"
        onStarted: console.log("pad:", Style.rootConfigDir + "scripts/sleep.sh")
        onExited: (code, status) => console.log("exitcode:", code)
    }

    Process {
        id: logoutProc
        command: ["bash", "-c", Style.rootConfigDir + "scripts/logout.sh"] // .sh file for your ease of use / chaining.  "logout.sh"
        onStarted: console.log("pad:", Style.rootConfigDir + "scripts/logout.sh")
        onExited: (code, status) => console.log("exitcode:", code)
    }

    Item {
        id: uislider
        anchors.fill: parent

        transform: Translate {
            id: slideDouwn
            y: 0
        }

        NumberAnimation {
            id: openAnim
            target: slideDouwn
            property: "y"
            from: -powermaneger.height 
            to: 0
            duration: Style.animateTimePopup
            easing.type: Easing.OutCubic
            running: !Style.disableMvAnimation
        }

        NumberAnimation {
            id: closeAnim
            target: slideDouwn
            property: "y"
            from: 0
            to: -powermaneger.height
            duration: Style.animateTimePopup
            easing.type: Easing.InCubic
            onStopped: if (slideDouwn.y <= -powermaneger.height + 1) powerwindow.active = false
        }

        Rectangle {
            id: rootui
            anchors.fill: parent

            color: Style.popupAchtergrondKleur
            radius: Style.radiusGrooteM

            SettingsButtonElement {
                id: settingsW

                anchors {
                    top:   parent.top
                    left:  parent.left
                    right: parent.right

                    topMargin:   Style.uiMarginsM
                    leftMargin:  Style.uiMarginsM
                    rightMargin: Style.uiMarginsM
                }

                border {
                    color: Style.borderKleur
                    width: Style.borderSize
                }

                radius: Style.radiusGrooteM
                height: Style.barHoogte
                color:  "transparent"
                
                HoverHandler { id: settingsHover; cursorShape: Qt.PointingHandCursor }
                TapHandler { onTapped: Style.openSettings() }

                scale: settingsHover.hovered ? Style.growAnimateS : 1.0
                Behavior on scale {
                    NumberAnimation { duration: Style.animateTime; easing.type: Easing.OutCubic }
                }

                Text {
                    anchors.centerIn: parent
                    text:  "Settings"
                    color: Style.textKleur

                    font {
                        family: Style.globalFontFamily 
                        pixelSize: 18
                        bold: true 
                    }
                }
            }

            // --- select your power profilles ---
            Rectangle {
                id: powerProfilleSlector

                property string huidigProfiel: ""
                property var    profielen:     ["power-saver", "balanced", "performance"]

                border {
                    color: Style.borderKleur
                    width: Style.borderSize
                }

                height: Style.barHoogte
                color:  "transparent"
                radius: Style.radiusGrooteM

                anchors {
                    top:   settingsW.bottom
                    left:  parent.left
                    right: parent.right

                    topMargin:   Style.uiMarginsM
                    leftMargin:  Style.uiMarginsM
                    rightMargin: Style.uiMarginsM
                }

                // huidig profiel ophalen bij opstarten
                Process {
                    id: getProfielProc
                    command: ["powerprofilesctl", "get"]
                    running: true

                    stdout: SplitParser {
                        onRead: data => {
                            const t = data.trim()
                            if (t !== "") powerProfilleSlector.huidigProfiel = t
                        }
                    }
                }

                // profiel instellen
                Process {
                    id: setProfielProc
                    property string doel: ""
                    command: ["powerprofilesctl", "set", doel]

                    onExited: (code, _) => {
                        if (code === 0) powerProfilleSlector.huidigProfiel = doel
                    }
                }

                Row {
                    anchors.centerIn: parent
                    spacing: 8

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: powerProfilleSlector.huidigProfiel !== ""
                            ? powerProfilleSlector.huidigProfiel
                            : "laden…"
                        color: Style.textKleur

                        font {
                            family: Style.globalFontFamily
                            pixelSize: 18
                            bold:      true
                        }
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text:  "▾"
                        color: Style.textKleur
                        font {
                            family: Style.globalFontFamily
                            pixelSize: 14
                        }
                    }
                }

                HoverHandler { id: profilleHover; cursorShape: Qt.PointingHandCursor }
                TapHandler {
                    onTapped: {
                        bestandDropdown.visible = false
                        profielDropdown.visible = !profielDropdown.visible
                    }
                }

                scale: profilleHover.hovered ? Style.growAnimateS : 1.0
                Behavior on scale {
                    NumberAnimation { duration: Style.animateTime; easing.type: Easing.OutCubic }
                }
            }

            // --- set shutdown timer ---
            Rectangle {
                id: timeLengtSelector

                // huidige waarde in minuten — gebruik powermaneger.minuten elders

                border {
                    color: Style.borderKleur
                    width: Style.borderSize
                }

                height: Style.barHoogte
                color:  "transparent"
                radius: Style.radiusGrooteM

                anchors {
                    top:   powerProfilleSlector.bottom
                    left:  parent.left
                    right: parent.right

                    topMargin:   Style.uiMarginsM
                    leftMargin:  Style.uiMarginsM
                    rightMargin: Style.uiMarginsM
                }

                // --- min knop ---
                Rectangle {
                    id: minusMinut

                    width: 40
                    color: "transparent"

                    anchors {
                        top:    parent.top
                        bottom: parent.bottom
                        left:   parent.left
                    }

                    Text {
                        anchors.centerIn: parent
                        text:  "-"
                        color: Style.textKleur

                        font {
                            family: Style.globalFontFamily 
                            pixelSize: 18
                            bold: true 
                        }
                    }

                    HoverHandler { id: minusHover; cursorShape: Qt.PointingHandCursor }
                    TapHandler {
                        id: minusTap
                        onTapped: if (powermaneger.minuten > 1) powermaneger.minuten -= 1
                    }

                    Timer {
                        id: herhaalTimer
                        interval: 80
                        repeat:   true
                        running: minusTap.pressed && minusTap.longPressed
                        onTriggered: {
                            if (powermaneger.minuten > 1) powermaneger.minuten -= 1
                            else herhaalTimer.stop()
                        }
                    }

                    scale: minusHover.hovered ? Style.growAnimateL : 1.0
                    Behavior on scale {
                        NumberAnimation { duration: Style.animateTime; easing.type: Easing.OutCubic }
                    }
                }

                // --- getal invoerveld ---
                Rectangle {
                    id: minetAmount

                    color:  "transparent"

                    border { 
                        color: Style.borderKleur
                        width: Style.borderSize 
                    }

                    anchors {
                        top:    parent.top
                        bottom: parent.bottom
                        left:   minusMinut.right
                        right:  plusMinut.left
                    }

                    TextInput {
                        id: minutenInput

                        anchors.centerIn: parent
                        width: parent.width - 8

                        text:  powermaneger.minuten.toString()
                        color: Style.textKleur

                        font {
                            family: Style.globalFontFamily 
                            pixelSize: 18
                            bold: true 
                        }

                        horizontalAlignment: TextInput.AlignHCenter
                        selectByMouse:       true
                        cursorVisible:       activeFocus

                        validator: IntValidator { bottom: 1; top: 999 }

                        onTextChanged: {
                            const v = parseInt(text)
                            if (!isNaN(v) && v >= 1)
                                powermaneger.minuten = v
                        }

                        onEditingFinished: {
                            const v = parseInt(text)
                            if (isNaN(v) || v < 1)
                                text = powermaneger.minuten.toString()
                        }

                        Binding {
                            target:   minutenInput
                            property: "text"
                            value:    powermaneger.minuten.toString()
                            when:     !minutenInput.activeFocus
                        }
                    }

                    HoverHandler { id: inputHover; cursorShape: Qt.IBeamCursor }
                    TapHandler { onTapped: minutenInput.forceActiveFocus() }

                }

                // --- plus knop ---
                Rectangle {
                    id: plusMinut

                    width: 40
                    color: "transparent"

                    anchors {
                        top:    parent.top
                        bottom: parent.bottom
                        right:  parent.right
                    }

                    Text {
                        anchors.centerIn: parent
                        text:  "+"
                        color: Style.textKleur

                        font {
                            family: Style.globalFontFamily 
                            pixelSize: 18
                            bold: true 
                        }
                    }

                    HoverHandler { id: plusHover; cursorShape: Qt.PointingHandCursor }
                    TapHandler {
                        id: plusTap
                        onTapped: if (powermaneger.minuten < 999) powermaneger.minuten += 1
                    }

                    Timer {
                        id: herhaalTimerPlus
                        interval: 80
                        repeat:   true
                        running: plusTap.pressed && plusTap.longPressed
                        onTriggered: {
                            if (powermaneger.minuten < 999) powermaneger.minuten += 1
                            else herhaalTimerPlus.stop()
                        }
                    }

                    scale: plusHover.hovered ? Style.growAnimateL : 1.0
                    Behavior on scale {
                        NumberAnimation { duration: Style.animateTime; easing.type: Easing.OutCubic }
                    }
                }
            }


            // --- start shutdown timer ---
            Rectangle {
                id: powerDouwnTimerStart

                anchors {
                    top: timeLengtSelector.bottom
                    left: parent.left
                    right: parent.right

                    topMargin:   Style.uiMarginsM
                    leftMargin:  Style.uiMarginsM
                    rightMargin: Style.uiMarginsM
                }

                border { 
                    color: Style.borderKleur
                    width: Style.borderSize 
                }

                height: Style.barHoogte
                color:  "transparent"
                radius: Style.radiusGrooteM

                Text {
                    anchors.centerIn: parent
                    text:  "Shut Down in "
                    color: Style.textKleur

                    font {
                        family: Style.globalFontFamily 
                        pixelSize: 18
                        bold: true 
                    }
                }

                
                HoverHandler { id: startTimerHover; cursorShape: Qt.PointingHandCursor }
                TapHandler { onTapped: shutdownProcess.running = true }

                scale: startTimerHover.hovered ? Style.growAnimateS : 1.0
                Behavior on scale {
                    NumberAnimation { duration: Style.animateTime; easing.type: Easing.OutCubic }
                }
            }

            // --- sleep / log out button ---
            Rectangle {
                id: sleepLogOut

                height: Style.barHoogte
                color:  "transparent"

                anchors {
                    top: powerDouwnTimerStart.bottom
                    left: parent.left
                    right: parent.right

                    topMargin:   Style.uiMarginsM
                    leftMargin:  Style.uiMarginsM
                    rightMargin: Style.uiMarginsM
                }

                Rectangle {
                    id: sleepButton

                    width:  (rootui.width - (Style.uiMarginsM * 3)) / 2
                    color:  "transparent"
                    radius: Style.radiusGrooteM

                    border { 
                        color: Style.borderKleur
                        width: Style.borderSize 
                    }

                    anchors { 
                        top: parent.top
                        bottom: parent.bottom
                        left: parent.left
                    }

                    Text {
                        anchors.centerIn: parent
                        text:  "Sleep"
                        color: Style.textKleur

                        font {
                            family: Style.globalFontFamily 
                            pixelSize: 18
                            bold: true 
                        }
                    }

                    HoverHandler { id: sleepHover; cursorShape: Qt.PointingHandCursor }
                    TapHandler { onTapped: sleepProc.running = true }

                    scale: sleepHover.hovered ? Style.growAnimateM : 1.0
                    Behavior on scale {
                        NumberAnimation { duration: Style.animateTime; easing.type: Easing.OutCubic }
                    }
                }
            

                Rectangle {
                    id: logOutBrutton
    
                    width:  (rootui.width - (Style.uiMarginsM * 3)) / 2 
                    color:  "transparent"
                    radius: Style.radiusGrooteM
                    border { 
                        color: Style.borderKleur
                        width: Style.borderSize 
                    }

                    anchors { 
                        top: parent.top
                        right: parent.right 
                        bottom: parent.bottom
                    }

                    Text {
                        anchors.centerIn: parent
                        text:  "Log Out"
                        color: Style.textKleur
                        font {
                            family: Style.globalFontFamily 
                            pixelSize: 18
                            bold: true 
                        }
                    }

                    HoverHandler { id: logoutHover; cursorShape: Qt.PointingHandCursor }
                    TapHandler { onTapped: logoutProc.running = true }

                    scale: logoutHover.hovered ? Style.growAnimateM : 1.0
                    Behavior on scale {
                        NumberAnimation { duration: Style.animateTime; easing.type: Easing.OutCubic }
                    }
                }
            }
        

            // --- save state selector ---
            Rectangle {
                id: saveStateSelector

                property string map:                 "$HOME/.config/quickshell/SaveStates_txt"
                property string filterExt:           ".txt"
                property string geselecteerdBestand: "latest.txt"

                readonly property string geselecteerdPad:
                    geselecteerdBestand !== "" ? Style.saveState + "/" + geselecteerdBestand : ""

                signal bestandGekozen(string pad)

                border { 
                    color: Style.borderKleur
                    width: Style.borderSize 
                }

                height: Style.barHoogte
                color:  "transparent"
                radius: Style.radiusGrooteM

                anchors {
                    top:   sleepLogOut.bottom
                    left:  parent.left
                    right: parent.right

                    topMargin:   Style.uiMarginsM
                    leftMargin:  Style.uiMarginsM
                    rightMargin: Style.uiMarginsM
                }

                ListModel { id: bestandenModel }

                function laadBestanden() {
                    bestandenModel.clear()
                    lsProc.running = true
                }

                Component.onCompleted: laadBestanden()

                Process {
                    id: lsProc
                    command: ["bash", "-c", "ls -1p " + saveStateSelector.map + " 2>/dev/null"]
                    stdout: SplitParser {
                        onRead: regel => {
                            const naam = regel.trim()
                            if (naam === "" || naam.endsWith("/")) return
                            if (saveStateSelector.filterExt !== ""
                                && !naam.endsWith(saveStateSelector.filterExt)) return
                            bestandenModel.append({ bestandNaam: naam })
                        }
                    }
                }

                Row {
                    anchors.centerIn: parent
                    spacing: 8

                    Text {
                        anchors.verticalCenter: parent.verticalCenter

                        text:  saveStateSelector.geselecteerdBestand !== ""
                            ? saveStateSelector.geselecteerdBestand
                            : "Kies save state…"

                        color: Style.textKleur
                        font {
                            family: Style.globalFontFamily 
                            pixelSize: 18
                            bold: true 
                        }

                        elide: Text.ElideRight
                        maximumLineCount: 1
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text:  "▾"
                        color: Style.textKleur
                        font.pixelSize: 14
                    }
                }

                HoverHandler { id: saveStateHover; cursorShape: Qt.PointingHandCursor }
                TapHandler {
                    onTapped: {
                        saveStateSelector.laadBestanden()
                        // sluit de andere dropdown als die open is
                        profielDropdown.visible = false
                        bestandDropdown.visible = !bestandDropdown.visible
                    }
                }

                scale: saveStateHover.hovered ? Style.growAnimateS : 1.0
                Behavior on scale {
                    NumberAnimation { duration: Style.animateTime; easing.type: Easing.OutCubic }
                }
            }

            // --- save / load button for save states ---
            Rectangle {
                id: saveLoadSaveState

                height: Style.barHoogte
                color:  "transparent"

                anchors {
                    top: saveStateSelector.bottom
                    left: parent.left
                    right: parent.right

                    topMargin:   Style.uiMarginsM
                    leftMargin:  Style.uiMarginsM
                    rightMargin: Style.uiMarginsM
                }

                Rectangle {
                    id: saveSaveState

                    width:  (rootui.width - (Style.uiMarginsM * 3)) / 2
                    color:  "transparent"
                    radius: Style.radiusGrooteM

                    border { 
                        color: Style.borderKleur
                        width: Style.borderSize 
                    }

                    anchors { top: parent.top; bottom: parent.bottom; left: parent.left }

                    Text {
                        anchors.centerIn: parent
                        text:  "Save"
                        color: Style.textKleur
                        font {
                            family: Style.globalFontFamily 
                            pixelSize: 18
                            bold: true 
                        }
                    }

                    HoverHandler { id: saveHover; cursorShape: Qt.PointingHandCursor }
                    TapHandler { onTapped: {} /* Voeg save actie toe */ }

                    scale: saveHover.hovered ? Style.growAnimateM : 1.0
                    Behavior on scale {
                        NumberAnimation { duration: Style.animateTime; easing.type: Easing.OutCubic }
                    }
                }

                Rectangle {
                    id: loadSaveState

                    width:  (rootui.width - (Style.uiMarginsM * 3)) / 2
                    color:  "transparent"
                    radius: Style.radiusGrooteM

                    border { 
                        color: Style.borderKleur
                        width: Style.borderSize 
                    }

                    anchors { 
                        top: parent.top
                        bottom: parent.bottom
                        right: parent.right 
                    }

                    Text {
                        anchors.centerIn: parent
                        text:  "Load"
                        color: Style.textKleur

                        font {
                            family: Style.globalFontFamily 
                            pixelSize: 18
                            bold: true 
                        }
                    }

                    HoverHandler { id: loadHover; cursorShape: Qt.PointingHandCursor }
                    TapHandler { onTapped: {} /* Voeg load actie toe */ }

                    scale: loadHover.hovered ? Style.growAnimateM : 1.0
                    Behavior on scale {
                        NumberAnimation { duration: Style.animateTime; easing.type: Easing.OutCubic }
                    }
                }
            }

            // --- shutdown pc ---
            Rectangle {
                id: shutdown

                border { 
                    color: Style.borderKleur
                    width: Style.borderSize 
                }

                height: Style.barHoogte
                color:  "transparent"
                radius: Style.radiusGrooteM

                anchors {
                    top: saveLoadSaveState.bottom
                    left: parent.left
                    right: parent.right

                    topMargin:   Style.uiMarginsM
                    leftMargin:  Style.uiMarginsM
                    rightMargin: Style.uiMarginsM
                }

                Text {
                    anchors.centerIn: parent
                    text:  "Shut Down"
                    color: Style.textKleur
                    font {
                        family: Style.globalFontFamily 
                        pixelSize: 18
                        bold: true 
                    }
                }

                HoverHandler { id: shutdownHover; cursorShape: Qt.PointingHandCursor }
                TapHandler {
                    onTapped: shutdownNowProcess.running = true
                }

                scale: shutdownHover.hovered ? Style.growAnimateS : 1.0
                Behavior on scale {
                    NumberAnimation { duration: Style.animateTime; easing.type: Easing.OutCubic }
                }
            }

            Text {
                id: saveStatDir
                text:  "save state"
                color: Style.textKleur

                font {
                    family: Style.globalFontFamily 
                    pixelSize: Style.fontGrootteL
                }

                anchors {
                    top:  shutdown.bottom
                    left: parent.left

                    topMargin:  Style.uiMarginsM
                    leftMargin: Style.uiMarginsL
                }

                HoverHandler { id: saveDirHover; cursorShape: Qt.PointingHandCursor }
                TapHandler { onTapped: openerSaveStates.running = true }

                scale: saveDirHover.hovered ? Style.growAnimateS : 1.0
                Behavior on scale {
                    NumberAnimation { duration: Style.animateTime; easing.type: Easing.OutCubic }
                }
            }

            Text {
                id: qmlConfig
                text:  "qml"
                color: Style.textKleur

                font {
                    family: Style.globalFontFamily 
                    pixelSize: Style.fontGrootteL
                }

                anchors {
                    top:   shutdown.bottom
                    right: parent.right

                    topMargin:   Style.uiMarginsM
                    rightMargin: Style.uiMarginsL
                }

                HoverHandler { id: qmlHover; cursorShape: Qt.PointingHandCursor }
                TapHandler { onTapped: openerQmlDir.running = true }

                scale: qmlHover.hovered ? Style.growAnimateS : 1.0
                Behavior on scale {
                    NumberAnimation { duration: Style.animateTime; easing.type: Easing.OutCubic }
                }
            }

            // ═══════════════════════════════════════════════════════════════
            // DROPDOWN OVERLAYS — altijd aan het einde zodat ze bovenop renderen
            // ═══════════════════════════════════════════════════════════════

            // --- transparante achtergrond om dropdowns te sluiten ---
            Item {
                anchors.fill: parent
                z: 5
                visible: profielDropdown.visible || bestandDropdown.visible
                TapHandler { onTapped: {
                    profielDropdown.visible = false
                    bestandDropdown.visible = false
                }}
            }

            // --- power profiel dropdown overlay ---
            Rectangle {
                id: profielDropdown
                visible: false
                z: 10

                x:      Style.uiMarginsM
                y:      powerProfilleSlector.y + powerProfilleSlector.height + Style.uiMarginsM / 2
                width:  rootui.width - Style.uiMarginsM * 2

                // hoogte = aantal profielen × (barHoogte + spacing) + padding
                height: powerProfilleSlector.profielen.length
                        * (Style.barHoogte + Style.uiMarginsM)
                        + Style.uiMarginsM

                color:  Style.popupAchtergrondKleur
                radius: Style.radiusGrooteM

                border { 
                    color: Style.borderKleur
                    width: Style.borderSize 
                }

                Column {
                    anchors {
                        top:   parent.top
                        left:  parent.left
                        right: parent.right

                        topMargin:   Style.uiMarginsM
                        leftMargin:  Style.uiMarginsM
                        rightMargin: Style.uiMarginsM
                    }

                    spacing: Style.uiMarginsM / 2

                    Repeater {
                        model: powerProfilleSlector.profielen

                        Rectangle {
                            width:  parent.width
                            height: Style.barHoogte
                            color:  "transparent"
                            radius: Style.radiusGrooteM

                            border {
                                color: modelData === powerProfilleSlector.huidigProfiel
                                    ? Style.textKleur
                                    : Style.borderKleur
                                width: Style.borderSize
                            }

                            Text {
                                anchors.centerIn: parent
                                text:  modelData
                                color: Style.textKleur

                                font {
                                    family: Style.globalFontFamily
                                    pixelSize: 18
                                    bold: modelData === powerProfilleSlector.huidigProfiel
                                }
                            }

                            HoverHandler { id: itemHover; cursorShape: Qt.PointingHandCursor }
                            TapHandler {
                                onTapped: {
                                    setProfielProc.doel    = modelData
                                    setProfielProc.running = true
                                    profielDropdown.visible = false
                                }
                            }

                            scale: itemHover.hovered ? Style.shrinkAnimateS : 1.0
                            Behavior on scale {
                                NumberAnimation { duration: Style.animateTime; easing.type: Easing.OutCubic }
                            }
                                
                        }
                    }
                }
            }
            

            // --- bestand dropdown overlay ---
            Rectangle {
                id: bestandDropdown
                visible: false
                z: 10

                x:      Style.uiMarginsM
                y:      saveStateSelector.y + saveStateSelector.height + Style.uiMarginsM / 2
                width:  rootui.width - Style.uiMarginsM * 2

                height: Math.min(
                            bestandenModel.count * (Style.barHoogte + Style.uiMarginsM / 2)
                            + Style.uiMarginsM * 2,
                            (Style.barHoogte + Style.uiMarginsM / 2) * 4 + Style.uiMarginsM * 2
                        )

                color:  Style.popupAchtergrondKleur
                radius: Style.radiusGrooteM

                border { 
                    color: Style.borderKleur
                    width: Style.borderSize 
                }

                // lege staat
                Text {
                    anchors.centerIn: parent
                    visible:   bestandenModel.count === 0
                    text:      "Geen bestanden"
                    color:     Style.textKleur

                    font {
                        family: Style.globalFontFamily 
                        pixelSize: 16
                        bold: false 
                    }
                }

                ListView {
                    id: bestandenLijst
                    visible: bestandenModel.count > 0
                    model:   bestandenModel
                    clip:    true
                    spacing: Style.uiMarginsM / 2

                    anchors {
                        fill:        parent

                        topMargin:   Style.uiMarginsM
                        bottomMargin: Style.uiMarginsM
                        leftMargin:  Style.uiMarginsM
                        rightMargin: Style.uiMarginsM
                    }

                    delegate: Rectangle {
                        width:  bestandenLijst.width
                        height: Style.barHoogte
                        color:  "transparent"
                        radius: Style.radiusGrooteM

                        border {
                            color: model.bestandNaam === saveStateSelector.geselecteerdBestand
                                ? Style.textKleur
                                : Style.borderKleur
                            width: Style.borderSize
                        }

                        Text {
                            anchors.centerIn: parent
                            text:  model.bestandNaam
                            color: Style.textKleur

                            font {
                                family: Style.globalFontFamily
                                pixelSize: 18
                                bold: model.bestandNaam === saveStateSelector.geselecteerdBestand
                            }

                            elide:            Text.ElideRight
                            maximumLineCount: 1
                        }

                        HoverHandler { id: bestandHover; cursorShape: Qt.PointingHandCursor }
                        TapHandler {
                            onTapped: {
                                saveStateSelector.geselecteerdBestand = model.bestandNaam
                                saveStateSelector.bestandGekozen(saveStateSelector.geselecteerdPad)
                                bestandDropdown.visible = false
                            }
                        }

                        scale: bestandHover.hovered ? Style.shrinkAnimateS : 1.0
                        Behavior on scale {
                            NumberAnimation { duration: Style.animateTime; easing.type: Easing.OutCubic }
                        }
                    }

                }
            }
        }
    }
}