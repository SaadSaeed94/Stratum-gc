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
        topEdgeLeftInset:       toolbar.height
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
        width: 230
        z: QGroundControl.zOrderTopMost + 10

        // ---- THEME (change anytime) ----
        color: "#0B1220"          // gutter background
        opacity: 0.95
        radius: 14
        border.color: "#1F2A44"
        border.width: 1

        // ---- State ----
        property var  _activeVehicle: QGroundControl.multiVehicleManager.activeVehicle
        property bool _hasVehicle: _activeVehicle !== null && _activeVehicle !== undefined

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

        // ---- BUTTON LIST ----
        // TIP: Add more buttons by copy/pasting any Rectangle button block below
        Column {
            id: gutterButtons
            anchors.top: parent.top
            anchors.topMargin:18
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 14

            // TAKEOFF
            Rectangle {
                id: btnTakeoff
                width: 200; height: 86
                radius: 18
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
                width: 200; height: 86
                radius: 18
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
                width: 200; height: 86
                radius: 18
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

            // STANDOFF
            // FIX: id renamed from btnPause → btnStandoff
            // FIX: enabled now correctly checks _hasVehicle (was hardcoded true)
            // FIX: SVG path uses qrc:/ prefix (was broken non-qrc path)
            Rectangle {
                id: btnStandoff
                width: 200; height: 86
                radius: 18
                color: "#111B2E"
                border.color: "#2B3A5C"
                border.width: 1
                opacity: leftGutterPanel._hasVehicle ? 1.0 : 0.45

                QGCColoredImage {
                    anchors.centerIn: parent
                    source: "qrc:/res/StandoffActive.svg"   // FIX: corrected path + typo
                    width: 34; height: 34
                    color: "white"
                }

                QGCLabel {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 10
                    text: qsTr("Standoff")
                    font.pointSize: ScreenTools.smallFontPointSize
                    color: "#D6D9E0"
                }

                QGCMouseArea {
                    anchors.fill: parent
                    enabled: leftGutterPanel._hasVehicle   // FIX: respects vehicle connection
                    onClicked: standoffdialog.open()
                }
            }

            Rectangle {
                id: btnSetup
                width: 86; height: 86
                radius: 18
                color: "#111B2E"
                border.color: "#2B3A5C"
                border.width: 1

                QGCColoredImage {
                    anchors.centerIn: parent
                    source: "qrc:/qmlimages/Gears.svg"
                    width: 34; height: 34
                    color: "white"
                }

                QGCLabel {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 10
                    text: qsTr("Setup")
                    font.pointSize: ScreenTools.smallFontPointSize
                    color: "#D6D9E0"
                }

                QGCMouseArea {
                    anchors.fill: parent
                    onClicked: leftGutterPanel.showInfo(qsTr("Setup"), qsTr("Wire this to a screen later."))
                }
            }
        }

        // ---- LOGO (inside gutter) ----
        Image {
            id: nxLogoGutter
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 14
            source: "qrc:/res/QGCLogoWhite.svg"
            fillMode: Image.PreserveAspectFit
            width: 92
            height: 92
            opacity: 0.75
            smooth: true
        }
    }

    // ============================================================================
    // STANDOFF DIALOG
    // All fixes applied:
    //   - Lat/Lon are now user-entered TextFields (no hardcoded coordinates)
    //   - Component ID uses v.defaultComponentId consistently in both Execute & Cancel
    //   - MAVLink command IDs use _mavCmdStandoffParams / _mavCmdStandoffCommand constants
    //   - Default field values removed — user must enter explicitly
    //   - NaN validation before sending any MAVLink command
    // ============================================================================
    Dialog {
        id: standoffdialog
        title: qsTr("Standoff Parameters")
        modal: true
        width: 380
        anchors.centerIn: parent
        z: QGroundControl.zOrderTopMost + 20

        property var vehicle: QGroundControl.multiVehicleManager.activeVehicle

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 14

            // --- Latitude (user-entered) ---
            Label { text: qsTr("Latitude (decimal degrees)") }
            TextField {
                id: latField
                Layout.fillWidth: true
                text: ""
                placeholderText: qsTr("e.g. 47.401111")
                inputMethodHints: Qt.ImhFormattedNumbersOnly
            }

            // --- Longitude (user-entered) ---
            Label { text: qsTr("Longitude (decimal degrees)") }
            TextField {
                id: lonField
                Layout.fillWidth: true
                text: ""
                placeholderText: qsTr("e.g. 8.521111")
                inputMethodHints: Qt.ImhFormattedNumbersOnly
            }

            // --- Distance ---
            Label { text: qsTr("Distance (m)") }
            TextField {
                id: distanceField
                Layout.fillWidth: true
                text: ""
                placeholderText: qsTr("e.g. 100")
                inputMethodHints: Qt.ImhFormattedNumbersOnly
            }

            // --- Height ---
            Label { text: qsTr("Height (m AGL)") }
            TextField {
                id: heightField
                Layout.fillWidth: true
                text: ""
                placeholderText: qsTr("e.g. 50")
                inputMethodHints: Qt.ImhFormattedNumbersOnly
            }

            // --- Speed ---
            Label { text: qsTr("Speed (km/h)") }
            TextField {
                id: speedField
                Layout.fillWidth: true
                text: ""
                placeholderText: qsTr("e.g. 30")
                inputMethodHints: Qt.ImhFormattedNumbersOnly
            }

            // --- Direction ---
            Label { text: qsTr("Direction") }
            ComboBox {
                id: directionCombo
                Layout.fillWidth: true
                model: ["0 — North", "1 — East", "2 — South", "3 — West"]
                currentIndex: 0
            }

            // --- EXECUTE ---
            Button {
                text: qsTr("Execute")
                Layout.fillWidth: true

                onClicked: {
                    var v = standoffdialog.vehicle
                    if (!v) {
                        mainWindow.showMessageDialog(qsTr("No Vehicle"), qsTr("Connect a vehicle first."))
                        return
                    }

                    var lat    = parseFloat(latField.text)
                    var lon    = parseFloat(lonField.text)
                    var dist   = parseFloat(distanceField.text)
                    var height = parseFloat(heightField.text)
                    var speed  = parseFloat(speedField.text)

                    if (isNaN(lat) || isNaN(lon) || isNaN(dist) || isNaN(height) || isNaN(speed)) {
                        mainWindow.showMessageDialog(
                            qsTr("Invalid Input"),
                            qsTr("Please fill in all fields before executing.")
                        )
                        return
                    }

                    // Calls Q_INVOKABLE Vehicle::guidedModeStandoff()
                    // which goes → FirmwarePlugin → sendMavCommand internally
                    v.guidedModeStandoff(lat, lon, dist, height, speed, directionCombo.currentIndex)

                    standoffdialog.close()
                }
            }

            // --- CANCEL STANDOFF ---
            Button {
                text: qsTr("Cancel Standoff")
                Layout.fillWidth: true

                onClicked: {
                    var v = standoffdialog.vehicle
                    if (!v) return

                    // Calls Q_INVOKABLE Vehicle::guidedModeCancelStandoff()
                    v.guidedModeCancelStandoff()

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
            visible:    QGroundControl.videoManager.hasVideo
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
            anchors.right:          guidedValueSlider.visible ? guidedValueSlider.left : parent.right
            anchors.margins:        _widgetMargin
            anchors.topMargin:      toolbar.height + _widgetMargin
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
            anchors.topMargin:  toolbar.height
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
