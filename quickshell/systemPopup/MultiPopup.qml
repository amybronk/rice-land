// systemPopup/MyPopup.qml
import Quickshell
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../media"
import "../widgets"
import "../"

Item {
    id: root
    required property bool isCurrentScreen
    required property string screenName

    readonly property bool isOpen: PopupManager.isOpen && isCurrentScreen
    readonly property bool shouldBeVisible: isOpen || scaleAnim.running || yAnim.running

    property int volume: 55
    property bool playing: false

    width: 900
    height: 400

    scale: root.isOpen ? 1.0 : 0.2
    y: root.isOpen ? 0 : -400

    enabled: root.isOpen

    Behavior on scale {
        NumberAnimation {
            id: scaleAnim 
            duration: 200
            easing.type: Easing.OutCubic
        }
    }

    Behavior on y {
        NumberAnimation {
            id: yAnim 
            duration: 250
            easing.type: Easing.OutQuart 
        }
    }

    clip: true

    Rectangle {
        anchors.fill: parent
        color: Colors.background
        bottomLeftRadius: 24
        bottomRightRadius: 24

        HoverHandler {
            onHoveredChanged: {
                PopupManager.setHovered(root.screenName, hovered)
            }
        }

        Item {
            id: contentWrapper
            anchors.fill: parent
            
            layer.enabled: true
            layer.smooth: true

            Text {
                id: date_text_big
                anchors {
                    top: contentWrapper.top
                    horizontalCenter: contentWrapper.horizontalCenter
                } 
                font.pixelSize: 24
                text: Time.dateString
                color: Colors.on_background
            }

            Text { // verdwijn / verschin gebaseerd op een togle easy diagnostics 
                anchors {
                    bottom: contentWrapper.bottom
                    right: contentWrapper.right
                    bottomMargin: 2
                    rightMargin: 30
                }
                horizontalAlignment: Text.AlignRight
                width: 35
                color: Style.easy_diagnostics ? Colors.on_background : Colors.background
                text: root.screenName
                font.pixelSize: 10
            }

            SliderContainer {
                id: volume_slider_container

                anchors {
                    top: contentWrapper.top
                    bottom: contentWrapper.bottom
                    left: contentWrapper.left
                    topMargin: 0
                    margins: 16
                }
                
                width: 200 
                radius: 24
                color: Colors.secondary_container
            }

            Mediaplayer {
                id: mediaplayer
                width: 200
                radius: 24

                anchors {
                    top: contentWrapper.top
                    bottom: contentWrapper.bottom
                    right: contentWrapper.right
                    topMargin: 0
                    margins: 16
                }
            }

            Rectangle {
                id: calender // Kept original ID spelling to maintain existing references

                anchors {
                    top: date_text_big.bottom
                    bottom: contentWrapper.bottom
                    right: mediaplayer.left
                    left: volume_slider_container.right
                    margins: 16
                }
                radius: 24
                color: Colors.secondary_container

                // --- Calendar State ---
                property int lastCheckedDay: -1
                property date viewedDate: new Date()
                property int currentDayOfWeekIndex: -1
                property bool isViewingCurrentMonth: true

                ListModel { id: calendarModel }

                function changeMonth(offset) {
                    var newDate = new Date(viewedDate.getFullYear(), viewedDate.getMonth() + offset, 1)
                    viewedDate = newDate
                    generateCalendar()
                }

                function resetMonth() {
                    viewedDate = new Date()
                    generateCalendar()
                }

                function generateCalendar() {
                    calendarModel.clear()
                    
                    var currentMonth = viewedDate.getMonth()
                    var currentYear = viewedDate.getFullYear()
                    var today = new Date()
                    var actualCurrentDate = today.getDate()
                    
                    isViewingCurrentMonth = (currentMonth === today.getMonth() && currentYear === today.getFullYear())

                    var firstDay = new Date(currentYear, currentMonth, 1)
                    var startDayOfWeek = firstDay.getDay() 
                    var startOffset = startDayOfWeek === 0 ? 6 : startDayOfWeek - 1

                    var daysInMonth = new Date(currentYear, currentMonth + 1, 0).getDate()
                    var daysInPrevMonth = new Date(currentYear, currentMonth, 0).getDate()

                    for (var i = 0; i < 42; i++) {
                        if (i < startOffset) {
                            calendarModel.append({ "dayNumber": daysInPrevMonth - startOffset + i + 1, "isCurrentMonth": false, "isToday": false })
                        } else if (i >= startOffset && i < startOffset + daysInMonth) {
                            var currentDay = i - startOffset + 1
                            var isToday = (isViewingCurrentMonth && currentDay === actualCurrentDate)
                            calendarModel.append({ "dayNumber": currentDay, "isCurrentMonth": true, "isToday": isToday })
                        } else {
                            calendarModel.append({ "dayNumber": i - startOffset - daysInMonth + 1, "isCurrentMonth": false, "isToday": false })
                        }
                    }
                }

                function checkDate() {
                    var date = new Date()
                    if (date.getDate() !== lastCheckedDay) {
                        lastCheckedDay = date.getDate()
                        var jsDay = date.getDay()
                        currentDayOfWeekIndex = (jsDay === 0) ? 6 : jsDay - 1
                        if (isViewingCurrentMonth) {
                            generateCalendar()
                        }
                    }
                }

                Component.onCompleted: {
                    checkDate()
                    resetMonth()
                }

                // Check for day changes every minute to update highlights
                Timer {
                    interval: 60000 
                    running: true
                    repeat: true
                    onTriggered: calender.checkDate()
                }

                // --- Calendar UI ---
                Item {
                    anchors.fill: parent
                    anchors.margins: 16

                    // Navigation buttons
                    RowLayout {
                        id: buttonui
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 30 
                        spacing: 12

                        Rectangle {
                            id: lastmonth
                            Layout.preferredWidth: 35
                            Layout.fillHeight: true
                            radius: 8
                            color: prevHover.hovered ? Colors.primary : "transparent"
                            scale: prevHover.hovered ? 1.1 : 1.0

                            Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

                            Text {
                                anchors.centerIn: parent
                                text: "<"
                                color: prevHover.hovered ? Colors.on_primary : Colors.on_secondary_container
                                font.pixelSize: 16
                                font.bold: true
                            }

                            HoverHandler { id: prevHover }
                            TapHandler { onTapped: calender.changeMonth(-1) }
                        }

                        Rectangle {
                            id: thismonth
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: 8
                            color: currentHover.hovered ? Colors.primary : "transparent"
                            scale: currentHover.hovered ? 1.05 : 1.0

                            Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

                            Text {
                                anchors.centerIn: parent
                                text: Qt.formatDateTime(calender.viewedDate, "MMMM yyyy")
                                color: currentHover.hovered ? Colors.on_primary : Colors.on_secondary_container
                                font.pixelSize: 16
                                font.bold: true
                            }

                            HoverHandler { id: currentHover }
                            TapHandler { onTapped: calender.resetMonth() }
                        }

                        Rectangle {
                            id: nextmonth
                            Layout.preferredWidth: 35
                            Layout.fillHeight: true
                            radius: 8
                            color: nextHover.hovered ? Colors.primary : "transparent"
                            scale: nextHover.hovered ? 1.1 : 1.0

                            Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

                            Text {
                                anchors.centerIn: parent
                                text: ">"
                                color: nextHover.hovered ? Colors.on_primary : Colors.on_secondary_container
                                font.pixelSize: 16
                                font.bold: true
                            }

                            HoverHandler { id: nextHover }
                            TapHandler { onTapped: calender.changeMonth(1) }
                        }
                    }

                    // Days of week row
                    Row { 
                        id: dayindecator 
                        anchors.top: buttonui.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.topMargin: 12
                        
                        Repeater {
                            model: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]
                            
                            Item {
                                width: dayindecator.width / 7
                                height: 30 
                                property bool isTodayColumn: (index === calender.currentDayOfWeekIndex) && calender.isViewingCurrentMonth

                                Rectangle {
                                    anchors.centerIn: parent
                                    width: Math.min(parent.width, parent.height) * 0.9
                                    height: width
                                    radius: width / 2 
                                    color: isTodayColumn ? Colors.primary : "transparent"
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData
                                    font.pixelSize: 12
                                    font.bold: true
                                    color: isTodayColumn ? Colors.on_primary : Colors.on_secondary_container
                                    opacity: isTodayColumn ? 1.0 : 0.6 
                                }
                            }
                        }
                    }
                    
                    // Calendar grid
                    Grid { 
                        id: monthblok 
                        columns: 7
                        rows: 6
                        
                        anchors {
                            top: dayindecator.bottom
                            left: parent.left
                            right: parent.right
                            bottom: parent.bottom
                            topMargin: 8
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
                                        return "transparent"; 
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
                                        return Colors.on_secondary_container; 
                                    }
                                    
                                    opacity: isCurrentMonth ? 1.0 : 0.3
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}