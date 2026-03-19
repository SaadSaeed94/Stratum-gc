// File: src/FlyView/FlyView.qml
// FULL WORKING VERSION with a clean, separate LEFT GUTTER section
// (Map + overlays are shifted right by _leftGutter)

import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts

import QtLocation
import QtPositioning
import QtQuick.Window
import QtQml.Models

import QGroundControl
import QGroundControl.Controls
import QGroundControl.FlyView
import QGroundControl.FlightMap
import QGroundControl.UTMSP
import QGroundControl.Viewer3D

Item {
    id: _root

    // These should only be used by MainRootWindow
    property var planController:    _planController
    property var guidedController:  _guidedController

    // Properties of UTM adapter
    property bool utmspSendActTrigger: false
    property bool panelVisible:        true    // toggled by Q button in MainWindow

    // ---- LEFT GUTTER (reserved space for your custom buttons) ----
    // Increase this if you want a wider gutter
    property int _leftGutter: 120

    PlanMasterController {
        id:                     _planController
        flyView:                true
        Component.onCompleted:  start()
    }

    property bool   _mainWindowIsMap:       mapControl.pipState.state === mapControl.pipState.fullState
    property bool   _isFullWindowItemDark:  _mainWindowIsMap ? mapControl.isSatelliteMap : true
    property var    _activeVehicle:         QGroundControl.multiVehicleManager.activeVehicle
    property var    _missionController:     _planController.missionController
    property var    _geoFenceController:    _planController.geoFenceController
    property var    _rallyPointController:  _planController.rallyPointController
    property real   _margins:               ScreenTools.defaultFontPixelWidth / 2
    property var    _guidedController:      guidedActionsController
    property var    _guidedValueSlider:     guidedValueSlider
    property var    _widgetLayer:           widgetLayer
    property real   _toolsMargin:           ScreenTools.defaultFontPixelWidth * 0.75
    property rect   _centerViewport:        Qt.rect(0, 0, width, height)
    property real   _rightPanelWidth:       ScreenTools.defaultFontPixelWidth * 30
    property var    _mapControl:            mapControl
    property real   _widgetMargin:          ScreenTools.defaultFontPixelWidth * 0.75

    property real   _fullItemZorder:    0
    property real   _pipItemZorder:     QGroundControl.zOrderWidgets

    function _calcCenterViewPort() {
        var newToolInset = Qt.rect(0, 0, width, height)
        toolstrip.adjustToolInset(newToolInset)
    }

    function dropMainStatusIndicatorTool() {
        toolbar.dropMainStatusIndicatorTool();
    }

    QGCToolInsets {
        id:                     _toolInsets
        topEdgeLeftInset:       0
        topEdgeCenterInset:     topEdgeLeftInset
        topEdgeRightInset:      topEdgeLeftInset
        leftEdgeBottomInset:    _pipView.leftEdgeBottomInset
        bottomEdgeLeftInset:    _pipView.bottomEdgeLeftInset
    }



    // ============================================================================
    // LEFT GUTTER UI (CUSTOMIZE HERE)
    // - This stays pinned to the LEFT edge of the window
    // - Map + overlays are shifted right by mapHolder.anchors.leftMargin = _leftGutter
    // - Toolbar shifted right by toolbar.anchors.leftMargin = _leftGutter
    // ============================================================================
    Rectangle {
        id: leftGutterPanel
        anchors.left: _root.left
        anchors.top: toolbar.bottom
        anchors.bottom: _root.bottom
        visible: _root.panelVisible
        width: 230
        z: QGroundControl.zOrderTopMost + 10

        // ---- THEME (change anytime) ----
        color: "#0B1220"          // gutter background
        opacity: 1.0
        radius: 0
        border.color: "#1F2A44"
        border.width: 1

        // ---- State ----
        property var  _activeVehicle:    QGroundControl.multiVehicleManager.activeVehicle
        property bool _hasVehicle:       _selectedVehicle !== null && _selectedVehicle !== undefined
        property var  _selectedVehicle:  null   // set by fleet panel on single-click
        property var  _vehicles:         QGroundControl.multiVehicleManager.vehicles

        // ---- Helpers ----
        function doGuided(actionEnum) {
            if (!leftGutterPanel._hasVehicle) {
                mainWindow.showMessageDialog(qsTr("No Vehicle"), qsTr("Connect a vehicle first."))
                return
            }
            if (globals.guidedControllerFlyView) {
                globals.guidedControllerFlyView.confirmAction(actionEnum)
            } else {
                mainWindow.showMessageDialog(qsTr("Error"), qsTr("guidedControllerFlyView not available."))
            }
        }

        function showInfo(title, msg) {
            mainWindow.showMessageDialog(title, msg)
        }

        // ---- 6 NAV BUTTONS — 2x3 grid ----
        GridLayout {
            id:                         navGrid
            anchors.top:                parent.top
            anchors.topMargin:          12
            anchors.horizontalCenter:   parent.horizontalCenter
            columns:                    3
            rowSpacing:                 6
            columnSpacing:              6

            // Plan
            Rectangle {
                width: 64; height: 52; radius: 8
                color: "#111B2E"; border.color: "#2B3A5C"; border.width: 1
                Column { anchors.centerIn: parent; spacing: 4
                    QGCColoredImage { anchors.horizontalCenter: parent.horizontalCenter; source: "/qmlimages/Plan.svg"; width: 20; height: 20; color: "#D6D9E0" }
                    QGCLabel { anchors.horizontalCenter: parent.horizontalCenter; text: qsTr("Plan"); font.pointSize: ScreenTools.smallFontPointSize * 0.85; color: "#D6D9E0" }
                }
                MouseArea { anchors.fill: parent; onClicked: mainWindow.showPlanView() }
            }
            // Fly
            Rectangle {
                width: 64; height: 52; radius: 8
                color: "#111B2E"; border.color: "#2B3A5C"; border.width: 1
                Column { anchors.centerIn: parent; spacing: 4
                    QGCColoredImage { anchors.horizontalCenter: parent.horizontalCenter; source: "/qmlimages/PaperPlane.svg"; width: 20; height: 20; color: "#D6D9E0" }
                    QGCLabel { anchors.horizontalCenter: parent.horizontalCenter; text: qsTr("Fly"); font.pointSize: ScreenTools.smallFontPointSize * 0.85; color: "#D6D9E0" }
                }
                MouseArea { anchors.fill: parent; onClicked: mainWindow.showFlyView() }
            }
            // Analyze
            Rectangle {
                width: 64; height: 52; radius: 8
                color: "#111B2E"; border.color: "#2B3A5C"; border.width: 1
                Column { anchors.centerIn: parent; spacing: 4
                    QGCColoredImage { anchors.horizontalCenter: parent.horizontalCenter; source: "/qmlimages/Analyze.svg"; width: 20; height: 20; color: "#D6D9E0" }
                    QGCLabel { anchors.horizontalCenter: parent.horizontalCenter; text: qsTr("Analyze"); font.pointSize: ScreenTools.smallFontPointSize * 0.85; color: "#D6D9E0" }
                }
                MouseArea { anchors.fill: parent; onClicked: mainWindow.showAnalyzeTool() }
            }
            // Vehicle Config
            Rectangle {
                width: 64; height: 52; radius: 8
                color: "#111B2E"; border.color: "#2B3A5C"; border.width: 1
                Column { anchors.centerIn: parent; spacing: 4
                    QGCColoredImage { anchors.horizontalCenter: parent.horizontalCenter; source: "/qmlimages/Gears.svg"; width: 20; height: 20; color: "#D6D9E0" }
                    QGCLabel { anchors.horizontalCenter: parent.horizontalCenter; text: qsTr("Config"); font.pointSize: ScreenTools.smallFontPointSize * 0.85; color: "#D6D9E0" }
                }
                MouseArea { anchors.fill: parent; onClicked: mainWindow.showVehicleConfig() }
            }
            // Settings
            Rectangle {
                width: 64; height: 52; radius: 8
                color: "#111B2E"; border.color: "#2B3A5C"; border.width: 1
                Column { anchors.centerIn: parent; spacing: 4
                    QGCColoredImage { anchors.horizontalCenter: parent.horizontalCenter; source: "/res/gear-white.svg"; width: 20; height: 20; color: "#D6D9E0" }
                    QGCLabel { anchors.horizontalCenter: parent.horizontalCenter; text: qsTr("Settings"); font.pointSize: ScreenTools.smallFontPointSize * 0.85; color: "#D6D9E0" }
                }
                MouseArea { anchors.fill: parent; onClicked: mainWindow.showSettingsTool() }
            }
            // Tools
            Rectangle {
                width: 64; height: 52; radius: 8
                color: "#111B2E"; border.color: "#2B3A5C"; border.width: 1
                Column { anchors.centerIn: parent; spacing: 4
                    QGCColoredImage { anchors.horizontalCenter: parent.horizontalCenter; source: "/res/QGCLogoArrow.svg"; width: 20; height: 20; color: "#D6D9E0" }
                    QGCLabel { anchors.horizontalCenter: parent.horizontalCenter; text: qsTr("Tools"); font.pointSize: ScreenTools.smallFontPointSize * 0.85; color: "#D6D9E0" }
                }
                MouseArea { anchors.fill: parent; onClicked: mainWindow.showToolSelectDialog() }
            }
        }

        // ---- BUTTON LIST ----
        Column {
            id: gutterButtons
            anchors.top: navGrid.bottom
            anchors.topMargin: 14
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 14

            // TAKEOFF
            Rectangle {
                id: btnTakeoff
                width: 200; height: 52
                radius: 12
                color: "#111B2E"
                border.color: "#2B3A5C"
                border.width: 1
                opacity: leftGutterPanel._hasVehicle ? 1.0 : 0.45

                QGCColoredImage {
                    anchors.centerIn: parent
                    source: "qrc:/res/takeoff.svg"
                    width: 34; height: 34
                    color: "white"
                }

                QGCLabel {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 10
                    text: qsTr("Takeoff")
                    font.pointSize: ScreenTools.smallFontPointSize
                    color: "#D6D9E0"
                }

                QGCMouseArea {
                    anchors.fill: parent
                    enabled: leftGutterPanel._hasVehicle
                    onClicked: leftGutterPanel.doGuided(globals.guidedControllerFlyView.actionTakeoff)
                }
            }

            // RTL
            Rectangle {
                id: btnRTL
                width: 200; height: 52
                radius: 12
                color: "#111B2E"
                border.color: "#2B3A5C"
                border.width: 1
                opacity: leftGutterPanel._hasVehicle ? 1.0 : 0.45

                QGCColoredImage {
                    anchors.centerIn: parent
                    source: "qrc:/res/rtl.svg"
                    width: 34; height: 34
                    color: "white"
                }

                QGCLabel {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 10
                    text: qsTr("RTL")
                    font.pointSize: ScreenTools.smallFontPointSize
                    color: "#D6D9E0"
                }

                QGCMouseArea {
                    anchors.fill: parent
                    enabled: leftGutterPanel._hasVehicle
                    onClicked: leftGutterPanel.doGuided(globals.guidedControllerFlyView.actionRTL)
                }
            }

            // LAND
            Rectangle {
                id: btnLand
                width: 200; height: 52
                radius: 12
                color: "#111B2E"
                border.color: "#2B3A5C"
                border.width: 1
                opacity: leftGutterPanel._hasVehicle ? 1.0 : 0.45

                QGCColoredImage {
                    anchors.centerIn: parent
                    source: "qrc:/qmlimages/land.svg"
                    width: 34; height: 34
                    color: "white"
                }

                QGCLabel {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 10
                    text: qsTr("Land")
                    font.pointSize: ScreenTools.smallFontPointSize
                    color: "#D6D9E0"
                }

                QGCMouseArea {
                    anchors.fill: parent
                    enabled: leftGutterPanel._hasVehicle
                    onClicked: leftGutterPanel.doGuided(globals.guidedControllerFlyView.actionLand)
                }
            }

            // Standoff
            Rectangle {
                id: btnPause
                width: 200; height: 52
                radius: 12
                color: "#111B2E"
                border.color: "#2B3A5C"
                border.width: 1
                opacity: leftGutterPanel._hasVehicle ? 1.0 : 0.45

                QGCColoredImage {
                    anchors.centerIn: parent
                    source: "qrc:/res/StandoffActive.svg"
                    width: 34; height: 34
                    color: "white"
                }
                QGCLabel {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 10
                    text: qsTr("StandOff")
                    font.pointSize: ScreenTools.smallFontPointSize
                    color: "#D6D9E0"
                }

                QGCMouseArea {
                    anchors.fill: parent
                    enabled: leftGutterPanel._hasVehicle
                    onClicked: {standoffdialog.open()

                    }
                }
            }

        }

        // ---- FLEET PANEL ----
        Rectangle {
            id: fleetPanel
            anchors.top:        gutterButtons.bottom
            anchors.topMargin:  10
            anchors.bottom:     parent.bottom
            anchors.bottomMargin: 8
            anchors.left:       parent.left
            anchors.right:      parent.right
            color:              "transparent"

            // Header row
            Rectangle {
                id: fleetHeader
                anchors.top:   parent.top
                anchors.left:  parent.left
                anchors.right: parent.right
                height:        28
                color:         "transparent"

                QGCLabel {
                    anchors.left:       parent.left
                    anchors.leftMargin: 15
                    anchors.verticalCenter: parent.verticalCenter
                    text:       qsTr("FLEET")
                    font.pointSize: ScreenTools.smallFontPointSize * 0.8
                    color:      "#6B7A9A"
                    font.letterSpacing: 1.5
                }

                Rectangle {
                    anchors.right:       parent.right
                    anchors.rightMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    width:  vehicleCountLabel.contentWidth + 14
                    height: 16
                    radius: 8
                    color:  "#1A2840"
                    border.color: "#2B3A5C"
                    border.width: 1

                    QGCLabel {
                        id: vehicleCountLabel
                        anchors.centerIn: parent
                        text: leftGutterPanel._vehicles ? leftGutterPanel._vehicles.count + qsTr(" vehicles") : qsTr("0 vehicles")
                        font.pointSize: ScreenTools.smallFontPointSize * 0.75
                        color: "#6B9EC8"
                    }
                }
            }

            // Separator
            Rectangle {
                id: fleetSep
                anchors.top:  fleetHeader.bottom
                anchors.left: parent.left
                anchors.leftMargin: 12
                anchors.right: parent.right
                anchors.rightMargin: 12
                height: 1
                color: "#1F2A44"
            }

            // Scrollable vehicle list
            ListView {
                id: fleetList
                anchors.top:          fleetSep.bottom
                anchors.topMargin:    4
                anchors.bottom:       parent.bottom
                anchors.left:         parent.left
                anchors.leftMargin:   10
                anchors.right:        parent.right
                anchors.rightMargin:  10
                spacing:              4
                clip:                 true
                model:                (leftGutterPanel._vehicles && leftGutterPanel._vehicles.count > 0)
                                          ? leftGutterPanel._vehicles
                                          : mockVehicles

                ListModel {
                    id: mockVehicles
                    ListElement { mockId: "UAV-001"; mockType: "Quadrotor";   mockIcon: "✦"; mockAlt: "42m";  mockBat: "87%"; mockLink: 4; mockGps: "3D"; mockGpsClass: "fix3d" }
                    ListElement { mockId: "FW-002";  mockType: "Fixed Wing";  mockIcon: "✈"; mockAlt: "120m"; mockBat: "62%"; mockLink: 3; mockGps: "3D"; mockGpsClass: "fix3d" }
                    ListElement { mockId: "UAV-003"; mockType: "Quadrotor";   mockIcon: "✦"; mockAlt: "18m";  mockBat: "45%"; mockLink: 2; mockGps: "2D"; mockGpsClass: "fix2d" }
                    ListElement { mockId: "RVR-004"; mockType: "Ground Rover";mockIcon: "🚗";mockAlt: "0m";   mockBat: "—";   mockLink: 0; mockGps: "NO FIX"; mockGpsClass: "nofix" }
                }

                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded
                    contentItem: Rectangle {
                        implicitWidth: 3
                        radius: 2
                        color: "#2B3A5C"
                    }
                }

                delegate: Rectangle {
                    id: vehicleCard
                    // isMock is true when using mock data (no real vehicle object)
                    property bool isMock: typeof mockId !== "undefined"
                    property bool isSelected: isMock
                        ? leftGutterPanel._selectedVehicle === null && index === 0
                        : leftGutterPanel._selectedVehicle === object

                    width:  fleetList.width
                    height: 72
                    radius: 10
                    color:  isSelected ? "#0F1F38" : "#0F1828"
                    border.color: isSelected ? "#3A6BA8" : "#1A2840"
                    border.width: 1

                    // Active indicator bar on left edge
                    Rectangle {
                        visible: isSelected
                        width:   3
                        height:  parent.height * 0.6
                        anchors.left:           parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        radius:  2
                        color:   "#3A6BA8"
                    }

                    Column {
                        anchors.fill:        parent
                        anchors.margins:     8
                        anchors.leftMargin:  12
                        spacing:             5

                        // Top row: role icon + id + link + gps
                        Row {
                            width:   parent.width
                            height:  32
                            spacing: 8

                            // Role icon
                            Rectangle {
                                width:  28; height: 28
                                radius: 6
                                color:  "#0D2440"
                                anchors.verticalCenter: parent.verticalCenter
                                QGCLabel {
                                    anchors.centerIn: parent
                                    text: {
                                        if (vehicleCard.isMock) return mockIcon
                                        if (!object) return "?"
                                        var t = object.vehicleType
                                        if (t === 2 || t === 13) return "✈"
                                        if (t === 10) return "🚗"
                                        return "✦"
                                    }
                                    font.pointSize: ScreenTools.smallFontPointSize * 1.1
                                    color: "#5A9AE0"
                                }
                            }

                            // ID + type
                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 2
                                width: parent.width - 28 - 8 - linkRow.width - 8
                                QGCLabel {
                                    text: vehicleCard.isMock ? mockId : (object ? qsTr("UAV-") + object.id : qsTr("Unknown"))
                                    font.pointSize: ScreenTools.smallFontPointSize
                                    font.weight:    Font.Medium
                                    color: vehicleCard.isSelected ? "#6BA8E0" : "#C8D4E8"
                                }
                                QGCLabel {
                                    text: vehicleCard.isMock ? mockType : (object ? object.vehicleTypeName : "")
                                    font.pointSize: ScreenTools.smallFontPointSize * 0.8
                                    color: "#4A5A7A"
                                }
                            }

                            // Link bars + GPS pill
                            Row {
                                id: linkRow
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 5

                                Row {
                                    spacing: 1.5
                                    anchors.verticalCenter: parent.verticalCenter
                                    Repeater {
                                        model: 4
                                        Rectangle {
                                            width:  3
                                            height: 4 + (index * 3)
                                            radius: 1
                                            anchors.bottom: parent.bottom
                                            color: {
                                                var lq = vehicleCard.isMock ? mockLink * 25
                                                       : (object && object.links.count > 0 ? 75 : 0)
                                                return lq >= (index + 1) * 25 ? "#3A9E5A" : "#1F3A2A"
                                            }
                                        }
                                    }
                                }

                                Rectangle {
                                    height: 14
                                    width:  gpsLabel.contentWidth + 10
                                    radius: 3
                                    anchors.verticalCenter: parent.verticalCenter
                                    color: {
                                        var g = vehicleCard.isMock ? mockGpsClass
                                              : (!object ? "nofix" : object.gps.lock.rawValue >= 3 ? "fix3d"
                                                : object.gps.lock.rawValue === 2 ? "fix2d" : "nofix")
                                        return g === "fix3d" ? "#0D2A18" : g === "fix2d" ? "#2A1E08" : "#2A0D0D"
                                    }
                                    border.color: {
                                        var g = vehicleCard.isMock ? mockGpsClass
                                              : (!object ? "nofix" : object.gps.lock.rawValue >= 3 ? "fix3d"
                                                : object.gps.lock.rawValue === 2 ? "fix2d" : "nofix")
                                        return g === "fix3d" ? "#1A4A2A" : g === "fix2d" ? "#4A3410" : "#4A1A1A"
                                    }
                                    border.width: 1
                                    QGCLabel {
                                        id: gpsLabel
                                        anchors.centerIn: parent
                                        text: vehicleCard.isMock ? mockGps
                                            : (!object ? qsTr("NO FIX")
                                               : object.gps.lock.rawValue >= 3 ? qsTr("3D")
                                               : object.gps.lock.rawValue === 2 ? qsTr("2D") : qsTr("NO FIX"))
                                        font.pointSize: ScreenTools.smallFontPointSize * 0.7
                                        font.weight:    Font.Medium
                                        color: {
                                            var g = vehicleCard.isMock ? mockGpsClass
                                                  : (!object ? "nofix" : object.gps.lock.rawValue >= 3 ? "fix3d"
                                                    : object.gps.lock.rawValue === 2 ? "fix2d" : "nofix")
                                            return g === "fix3d" ? "#3A9E5A" : g === "fix2d" ? "#C08020" : "#C03030"
                                        }
                                    }
                                }
                            }
                        }

                        // Bottom row: alt + battery + active badge
                        Row {
                            width:   parent.width
                            spacing: 0
                            QGCLabel {
                                text: {
                                    if (vehicleCard.isMock) return qsTr("Alt ") + mockAlt + "   " + qsTr("Bat ") + mockBat
                                    if (!object) return ""
                                    var alt = object.altitudeRelative.rawValue
                                    var bat = object.battery.percentRemaining.rawValue
                                    return qsTr("Alt ") + (isNaN(alt) ? "—" : Math.round(alt) + "m")
                                         + "   " + qsTr("Bat ") + ((bat < 0 || isNaN(bat)) ? "—" : Math.round(bat) + "%")
                                }
                                font.pointSize: ScreenTools.smallFontPointSize * 0.8
                                color: "#3A4A6A"
                            }
                            Item { width: parent.width - activeBadge.width - 110; height: 1 }
                            Rectangle {
                                id: activeBadge
                                visible: vehicleCard.isSelected
                                height:  14
                                width:   activeLabel.contentWidth + 12
                                radius:  3
                                color:   "#0D2440"
                                border.color: "#1A4A7A"
                                border.width: 1
                                QGCLabel {
                                    id: activeLabel
                                    anchors.centerIn: parent
                                    text: qsTr("ACTIVE")
                                    font.pointSize: ScreenTools.smallFontPointSize * 0.7
                                    font.weight:    Font.Medium
                                    color: "#3A7AC8"
                                }
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (!vehicleCard.isMock) {
                                leftGutterPanel._selectedVehicle = object
                                QGroundControl.multiVehicleManager.activeVehicle = object
                            }
                        }
                    }
                }
            }
        }
    }


    Dialog {
        id: standoffdialog
        title: qsTr("Standoff")
        modal: true
        width: 360
        anchors.centerIn: parent
        z: QGroundControl.zOrderTopMost + 20

        property var vehicle: QGroundControl.multiVehicleManager.activeVehicle

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 14

            // Distance
            Label { text: qsTr("Distance (m)") }
            TextField {
                id: distanceField
                Layout.fillWidth: true
                text: "100"
                inputMethodHints: Qt.ImhFormattedNumbersOnly
            }

            // Height
            Label { text: qsTr("Height (m)") }
            TextField {
                id: heightField
                Layout.fillWidth: true
                text: "50"
                inputMethodHints: Qt.ImhFormattedNumbersOnly
            }

            // Speed
            Label { text: qsTr("Speed (km/h)") }
            TextField {
                id: speedField
                Layout.fillWidth: true
                text: "30"
                inputMethodHints: Qt.ImhFormattedNumbersOnly
            }

            // Direction — enum: 0=N 1=E 2=S 3=W
            Label { text: qsTr("Direction") }
            ComboBox {
                id: directionCombo
                Layout.fillWidth: true
                model: ["0 — North", "1 — East", "2 — South", "3 — West"]
                currentIndex: 0

            }

            // EXECUTE → sends 31010 then 31011
            Button {
                text: qsTr("Execute")
                Layout.fillWidth: true

                onClicked: {
                    var v = standoffdialog.vehicle
                    if (!v) {
                        console.log("No vehicle!")
                        return
                    }

                    // Step 1: STANDOFF_PARAMS cmd 31010
                    v.sendMavCommand(
                        191,                                // ← MAV_COMP_ID_ONBOARD_COMPUTER
                        31010,                              // STANDOFF_PARAMS
                        true,                               // show error on fail
                        47.401111,                            // param1: lat  (hardcoded)
                        8.521111,                            // param2: lon  (hardcoded)
                        parseFloat(distanceField.text),     // param3: distance (m)
                        parseFloat(heightField.text),       // param4: height (m AGL)
                        parseFloat(speedField.text),        // param5: speed (km/h)
                        directionCombo.currentIndex,        // param6: direction 0/1/2/3
                        0                                   // param7: unused
                    )

                    // Step 2: STANDOFF_COMMAND activate cmd 31011
                    v.sendMavCommand(
                        191,                                // ← MAV_COMP_ID_ONBOARD_COMPUTER
                        31011,                              // STANDOFF_COMMAND
                        true,
                        1,                                  // 1 = activate
                        0, 0, 0, 0, 0, 0
                    )

                    console.log("Standoff executed — dist:", distanceField.text,
                                "height:", heightField.text,
                                "speed:", speedField.text,
                                "direction:", directionCombo.currentIndex)

                    standoffdialog.close()
                }
            }

            // CANCEL
            Button {
                text: qsTr("Cancel Standoff")
                Layout.fillWidth: true

                onClicked: {
                    var v = standoffdialog.vehicle
                    if (!v) return

                    v.sendMavCommand(
                        v.defaultComponentId,
                        31011,                              // STANDOFF_COMMAND
                        true,
                        0,                                  // 0 = cancel
                        0, 0, 0, 0, 0, 0
                    )

                    standoffdialog.close()
                }
            }
        }
    }
    // ----------------------------------------------------------------
    // Map holder: shift everything (map + overlays) out of gutter
    // ----------------------------------------------------------------
    Item {
        id:                 mapHolder
        anchors.fill:       parent
        anchors.leftMargin: _leftGutter

        FlyViewMap {
            id:                     mapControl
            planMasterController:   _planController
            rightPanelWidth:        ScreenTools.defaultFontPixelHeight * 9
            pipView:                _pipView
            pipMode:                !_mainWindowIsMap
            toolInsets:             customOverlay.totalToolInsets
            mapName:                "FlightDisplayView"
            enabled:                !viewer3DWindow.isOpen
        }

        FlyViewVideo {
            id:         videoControl
            pipView:    _pipView
        }

        PipView {
            id:                     _pipView
            anchors.left:           parent.left
            anchors.bottom:         parent.bottom
            anchors.margins:        _toolsMargin
            item1IsFullSettingsKey: "MainFlyWindowIsMap"
            item1:                  mapControl
            item2:                  QGroundControl.videoManager.hasVideo ? videoControl : null
            show:                   QGroundControl.videoManager.hasVideo && !QGroundControl.videoManager.fullScreen &&
                                        (videoControl.pipState.state === videoControl.pipState.pipState || mapControl.pipState.state === mapControl.pipState.pipState)
            z:                      QGroundControl.zOrderWidgets

            property real leftEdgeBottomInset: visible ? width + anchors.margins : 0
            property real bottomEdgeLeftInset: visible ? height + anchors.margins : 0
        }

        FlyViewWidgetLayer {
            id:                     widgetLayer
            anchors.top:            parent.top
            anchors.bottom:         parent.bottom
            anchors.left:           parent.left
            anchors.leftMargin:     _leftGutter
            anchors.right:          guidedValueSlider.visible ? guidedValueSlider.left : parent.right
            anchors.margins:        _widgetMargin
            anchors.topMargin: 0 + _widgetMargin
            z:                      _fullItemZorder + 2
            parentToolInsets:       _toolInsets
            mapControl:             _mapControl
            visible:                !QGroundControl.videoManager.fullScreen
            isViewer3DOpen:         viewer3DWindow.isOpen
        }

        FlyViewCustomLayer {
            id:                 customOverlay
            anchors.fill:       widgetLayer
            z:                  _fullItemZorder + 2
            parentToolInsets:   widgetLayer.totalToolInsets
            mapControl:         _mapControl
            visible:            !QGroundControl.videoManager.fullScreen
        }

        FlyViewInsetViewer {
            id:                     widgetLayerInsetViewer
            anchors.top:            parent.top
            anchors.bottom:         parent.bottom
            anchors.left:           parent.left
            anchors.right:          guidedValueSlider.visible ? guidedValueSlider.left : parent.right
            z:                      widgetLayer.z + 1
            insetsToView:           widgetLayer.totalToolInsets
            visible:                false
        }

        GuidedActionsController {
            id:                 guidedActionsController
            missionController:  _missionController
            guidedValueSlider:  _guidedValueSlider
        }

        GuidedValueSlider {
            id:                 guidedValueSlider
            anchors.right:      parent.right
            anchors.top:        parent.top
            anchors.bottom:     parent.bottom
            anchors.topMargin: 0
            z:                  QGroundControl.zOrderTopMost
            visible:            false
        }

        Viewer3D {
            id: viewer3DWindow
            anchors.fill: parent
        }
    }

    UTMSPActivationStatusBar {
        activationStartTimestamp:   UTMSPStateStorage.startTimeStamp
        activationApproval:         UTMSPStateStorage.showActivationTab && QGroundControl.utmspManager.utmspVehicle.vehicleActivation
        flightID:                   UTMSPStateStorage.flightID
        anchors.fill:               parent

        function onActivationTriggered(value) {
            _root.utmspSendActTrigger = value
        }
    }

    // ------------------------------------------------------------
    // Toolbar shifted out of gutter
    // ------------------------------------------------------------
    FlyViewToolBar {
        id:                 toolbar
        guidedValueSlider:  _guidedValueSlider
        utmspSliderTrigger: utmspSendActTrigger
        visible:            !QGroundControl.videoManager.fullScreen
        anchors.leftMargin: _leftGutter
    }
}
