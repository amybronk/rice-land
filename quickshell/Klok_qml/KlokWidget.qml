import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../"

PopupWindow {
    id: klokwindow
    visible: true
    color: Qt.rgba(0.1, 0.1, 0.1, 0)

    property real hourAngle: 0
    property real minuteAngle: 0
    property real secondAngle: 0
    
    // Property to track the last checked day for midnight transitions
    property int lastCheckedDay: -1
    // Property to track which month/year the user is currently looking at
    property date viewedDate: new Date()
    
    // Track the current day of the week (0 = Monday, 6 = Sunday)
    property int currentDayOfWeekIndex: -1
    // Track if the user is viewing the actual current month
    property bool isViewingCurrentMonth: true

    implicitHeight: 600
    implicitWidth: 250

    anchor {
        window: barWindow
        rect: Qt.rect(
            barWindow.klokX + barWindow.klokWidth / 2 - implicitWidth / 2,
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
                if (closeAnim.running) {
                    closeAnim.stop()
                    openAnim.from = klokSlider.y
                    openAnim.start()
                } else if (klokSlider.y < 0 && !openAnim.running) {
                    openAnim.from = -klokwindow.height
                    openAnim.start()
                }
            } else {
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
                klokwidget.active = false
            }
        }
    }
    
    function stopSluiten() { closeTimer.stop() }
    function startSluiten() { closeTimer.start() }
    
    // Function to calculate time and angles immediately
    function updateTime() {
        var date = new Date()
        klok_text.text = Qt.formatDateTime(date, "HH:mm:ss")
        date_text.text = Qt.formatDateTime(date, "dddd, dd MMMM yyyy")

        var seconds = date.getSeconds()
        var minutes = date.getMinutes()
        var hours = date.getHours()

        // Seconds: 6 degrees per second
        secondAngle = seconds * 6

        // Minutes: 6 degrees per minute + fractional part for smooth movement
        minuteAngle = (minutes * 6) + (seconds * 0.1)

        // Hours: 30 degrees per hour + fractional part based on minutes
        hourAngle = ((hours % 12) * 30) + (minutes * 0.5)

        // Update calendar highlight if midnight passes
        if (date.getDate() !== lastCheckedDay) {
            lastCheckedDay = date.getDate()
            
            // Calculate day of week index (JavaScript day 0 is Sunday, we need 6 to be Sunday)
            var jsDay = date.getDay()
            currentDayOfWeekIndex = (jsDay === 0) ? 6 : jsDay - 1
            
            // Only rebuild the grid if the user is currently viewing the current month
            if (isViewingCurrentMonth) {
                generateCalendar()
            }
        }
    }

    // --- Calendar Navigation Logic ---
    function changeMonth(offset) {
        // Set date to 1st to prevent jumping/skipping months due to different day counts (e.g. 31st Jan -> Feb)
        var newDate = new Date(viewedDate.getFullYear(), viewedDate.getMonth() + offset, 1)
        viewedDate = newDate
        generateCalendar()
    }

    function resetMonth() {
        viewedDate = new Date()
        generateCalendar()
    }

    // Function to populate the 6x7 calendar grid based on viewedDate
    function generateCalendar() {
        calendarModel.clear()
        
        var currentMonth = viewedDate.getMonth()
        var currentYear = viewedDate.getFullYear()

        // Real world today data for the highlight
        var today = new Date()
        var actualCurrentDate = today.getDate()
        
        // Update the property so the week indicators know if they should highlight
        isViewingCurrentMonth = (currentMonth === today.getMonth() && currentYear === today.getFullYear())

        // Determine the day of the week for the 1st of the month
        var firstDay = new Date(currentYear, currentMonth, 1)
        var startDayOfWeek = firstDay.getDay() 
        
        // Shift index so Monday is 0 and Sunday is 6
        var startOffset = startDayOfWeek === 0 ? 6 : startDayOfWeek - 1

        var daysInMonth = new Date(currentYear, currentMonth + 1, 0).getDate()
        var daysInPrevMonth = new Date(currentYear, currentMonth, 0).getDate()

        // Populate exactly 42 days
        for (var i = 0; i < 42; i++) {
            if (i < startOffset) {
                var prevDay = daysInPrevMonth - startOffset + i + 1
                calendarModel.append({
                    "dayNumber": prevDay,
                    "isCurrentMonth": false,
                    "isToday": false
                })
            } else if (i >= startOffset && i < startOffset + daysInMonth) {
                var currentDay = i - startOffset + 1
                var isToday = (isViewingCurrentMonth && currentDay === actualCurrentDate)
                calendarModel.append({
                    "dayNumber": currentDay,
                    "isCurrentMonth": true,
                    "isToday": isToday
                })
            } else {
                var nextDay = i - startOffset - daysInMonth + 1
                calendarModel.append({
                    "dayNumber": nextDay,
                    "isCurrentMonth": false,
                    "isToday": false
                })
            }
        }
    }

    Component.onCompleted: {
        updateTime()
        resetMonth() // Initializes viewedDate and generates the first grid
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: updateTime()
    }

    ListModel {
        id: calendarModel
    }

    Item {
        id: rootui

        transform: Translate {
            id: klokSlider
            y: 0
        }

        NumberAnimation {
            id: openAnim
            target: klokSlider
            property: "y"
            from: -klokwindow.height
            to: 0
            duration: Style.animateTimePopup
            easing.type: Easing.OutQuart
            running: !Style.disableMvAnimation
        }

        NumberAnimation {
            id: closeAnim
            target: klokSlider
            property: "y"
            from: 0
            to: -klokwindow.height
            duration: Style.animateTimePopup
            easing.type: Easing.InQuart
            running: false
            onStopped: if (klokSlider.y <= -klokwindow.height + 1) klokwidget.active = false
        }

        width: parent.width
        height: parent.height

        Rectangle {
            id: timeui

            height: Style.barHoogte + (Style.uiMarginsG * 2) + (timeui.width)
            color: "transparent"

            anchors {
                top: parent.top
                left: parent.left
                right: parent.right

                leftMargin:  Style.uiMarginsG
                rightMargin: Style.uiMarginsG
            }

            Rectangle {
                id: timetext

                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                }

                radius: Style.radiusGrooteM

                height: Style.barHoogte
                color: Colors.secondary_container

                Text {
                    id: klok_text
                    color: Colors.on_secondary_container
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        verticalCenter: parent.verticalCenter
                    }
                    font.pixelSize: Style.fontKlokgrote
                    text: Qt.formatDateTime(new Date(), "HH:mm:ss")
                }
            }

            Rectangle {
                id: analogklok

                anchors {
                    top: timetext.bottom
                    left: parent.left
                    right: parent.right
                    topMargin: Style.uiMarginsG
                }

                height: analogklok.width
                radius: analogklok.width / 2
                color: Colors.background

                Repeater {
                    model: 12
                    Text {
                        id: clockNumber
                        property int num: index + 1
                        property real angleRad: (num * 30 - 90) * Math.PI / 180
                        
                        x: (analogklok.width / 2) + Math.cos(angleRad) * (analogklok.width / 2 - Style.klokInsetPixels) - width / 2
                        y: (analogklok.height / 2) + Math.sin(angleRad) * (analogklok.height / 2 - Style.klokInsetPixels) - height / 2
                        
                        text: num
                        color: Colors.on_background
                        font.pixelSize: 12
                        font.bold: true
                    }
                }

                Rectangle {
                    id: hourHand
                    x: parent.width / 2 - width / 2
                    y: parent.height / 2 - height
                    width: 4
                    height: parent.height * 0.28   
                    color: Colors.primary
                    antialiasing: true

                    transform: Rotation {
                        origin.x: hourHand.width / 2
                        origin.y: hourHand.height
                        angle: hourAngle
                    }
                }

                Rectangle {
                    id: minuteHand
                    x: parent.width / 2 - width / 2
                    y: parent.height / 2 - height
                    width: 3
                    height: parent.height * 0.38  
                    color: Colors.secondary
                    antialiasing: true

                    transform: Rotation {
                        origin.x: minuteHand.width / 2
                        origin.y: minuteHand.height
                        angle: minuteAngle
                    }
                }

                Rectangle {
                    id: secondHand
                    x: parent.width / 2 - width / 2
                    y: parent.height / 2 - height
                    width: 1.5
                    height: parent.height * 0.42  
                    color: Colors.tertiary
                    antialiasing: true

                    transform: Rotation {
                        origin.x: secondHand.width / 2
                        origin.y: secondHand.height
                        angle: secondAngle
                    }
                }

                Rectangle {
                    anchors.centerIn: parent
                    width: 8
                    height: 8
                    radius: 4
                    color: secondHand.color
                }
            }
        }

        Rectangle {
            id: dateui

            color: "transparent"

            anchors {
                top: timeui.bottom
                right: parent.right
                left: parent.left
                bottom: parent.bottom

                leftMargin:  Style.uiMarginsG
                rightMargin: Style.uiMarginsG
            }
            
            Rectangle {
                id: datetext

                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                }

                radius: Style.radiusGrooteM

                height: Style.barHoogte
                color: Colors.secondary_container

                Text {
                    id: date_text
                    color: Colors.on_secondary_container
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        verticalCenter: parent.verticalCenter
                    }
                    font.pixelSize: Style.fontKlokgrote
                    text: Qt.formatDateTime(new Date(), "dddd, dd MMMM yyyy")
                }
            }

            Rectangle {
                id: buttonui
                
                anchors {
                    top: datetext.bottom
                    left: parent.left
                    right: parent.right
                    topMargin: Style.uiMarginsG
                }
                height: 30 
                color: "transparent"

                RowLayout {
                    anchors.fill: parent
                    spacing: Style.uiMarginsM

                    // --- Prev Month Button ---
                    Rectangle {
                        id: lastmonth
                        Layout.preferredWidth: 35
                        Layout.fillHeight: true
                        radius: Style.radiusGrooteS

                        color: prevHover.hovered ? Colors.primary : Colors.secondary_container
                        scale: prevHover.hovered ? Style.growAnimateS : 1.0

                        Behavior on scale {
                            NumberAnimation { duration: Style.animateTime; easing.type: Easing.OutCubic }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: "<"
                            color: prevHover.hovered ? Colors.on_primary : Colors.on_secondary_container
                            font.pixelSize: Style.fontGrootteL
                            font.bold: true
                        }

                        HoverHandler { id: prevHover }
                        TapHandler { onTapped: changeMonth(-1) }
                    }

                    // --- Current Month Label / Reset Button ---
                    Rectangle {
                        id: thismonth
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: Style.radiusGrooteS

                        color: currentHover.hovered ? Colors.primary : Colors.secondary_container
                        scale: currentHover.hovered ? Style.growAnimateS : 1.0

                        Behavior on scale {
                            NumberAnimation { duration: Style.animateTime; easing.type: Easing.OutCubic }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: Qt.formatDateTime(viewedDate, "MMMM yyyy")
                            color: currentHover.hovered ? Colors.on_primary : Colors.on_secondary_container
                            font.pixelSize: Style.fontGrootteM
                            font.bold: true
                        }

                        HoverHandler { id: currentHover }
                        TapHandler { onTapped: resetMonth() }
                    }

                    // --- Next Month Button ---
                    Rectangle {
                        id: nextmonth
                        Layout.preferredWidth: 35
                        Layout.fillHeight: true
                        radius: Style.radiusGrooteS

                        color: nextHover.hovered ? Colors.primary : Colors.secondary_container
                        scale: nextHover.hovered ? Style.growAnimateS : 1.0

                        Behavior on scale {
                            NumberAnimation { duration: Style.animateTime; easing.type: Easing.OutCubic }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: ">"
                            color: nextHover.hovered ? Colors.on_primary : Colors.on_secondary_container
                            font.pixelSize: Style.fontGrootteL
                            font.bold: true
                        }

                        HoverHandler { id: nextHover }
                        TapHandler { onTapped: changeMonth(1) }
                    }
                }
            }

            Row { 
                id: dayindecator 

                anchors {
                    top: buttonui.bottom
                    left: parent.left
                    right: parent.right
                    topMargin: Style.uiMarginsG
                }
                
                Repeater {
                    model: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]
                    
                    Item {
                        // Divide row width equally, matching the grid columns
                        width: dayindecator.width / 7
                        // Give it a fixed height, comparable to a grid cell height
                        height: 30 
                        
                        // Check if this column matches today's day of the week and the current viewed month
                        property bool isTodayColumn: (index === currentDayOfWeekIndex) && isViewingCurrentMonth

                        // Circular background mimicking the calendar grid look
                        Rectangle {
                            anchors.centerIn: parent
                            width: Math.min(parent.width, parent.height) * 0.9
                            height: width
                            radius: width / 2 
                            // Highlights with primary color if today, otherwise uses background color
                            color: isTodayColumn ? Colors.primary : Colors.background
                        }

                        Text {
                            anchors.centerIn: parent
                            text: modelData
                            font.pixelSize: 12
                            font.bold: true
                            
                            // Adjust text color based on highlight state
                            color: isTodayColumn ? Colors.on_primary : Colors.on_background
                            
                            // Keep unhighlighted indicators slightly dim if preferred, or remove for full opacity
                            opacity: isTodayColumn ? 1.0 : 0.6 
                        }
                    }
                }
            }
            
            Grid { 
                id: monthblok 
                
                columns: 7
                rows: 6
                
                anchors {
                    top: dayindecator.bottom
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                    topMargin: Style.uiMarginsG
                }

                Repeater {
                    model: calendarModel

                    Item {
                        width: monthblok.width / 7
                        height: monthblok.height / 6

                        Rectangle {
                            anchors.centerIn: parent
                            width: Math.min(parent.width, parent.height) * 0.9
                            height: width
                            radius: width / 2 

                            color: {
                                if (calendarHover.hovered) return Colors.tertiary;
                                if (isToday) return Colors.primary;
                                return Colors.background; 
                            }

                            opacity: isCurrentMonth ? 1.0 : 0.6

                            HoverHandler { id: calendarHover }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: dayNumber
                            font.pixelSize: 14
                            
                            color: {
                                if (calendarHover.hovered) return Colors.on_tertiary;
                                if (isToday) return Colors.on_primary;
                                return Colors.on_background; 
                            }
                            
                            opacity: isCurrentMonth ? 1.0 : 0.3
                        }
                    }
                }
            }
        }
    }
}