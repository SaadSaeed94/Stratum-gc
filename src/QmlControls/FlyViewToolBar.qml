import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

import QGroundControl
import QGroundControl.Controls
import QGroundControl.FlyView

Item {
    required property var guidedValueSlider
    required property bool utmspSliderTrigger

    id:     control
    width:  parent.width
    height: ScreenTools.toolbarHeight

    property var    _activeVehicle:     QGroundControl.multiVehicleManager.activeVehicle
    property bool   _communicationLost: _activeVehicle ? _activeVehicle.vehicleLinkManager.communicationLost : false
    property color  _mainStatusBGColor: "#3D4A1E"       // military green accent
    property color  _toolbarBG:         "#14160F"       // blackish-grey base
    property color  _toolbarBGLight:    "#1C1F15"       // slightly lighter panel bg
    property color  _milGreen:          "#4B5A24"       // military olive green
    property real   _leftRightMargin:   ScreenTools.defaultFontPixelWidth * 0.75
    property var    _guidedController:  globals.guidedControllerFlyView

    function dropMainStatusIndicatorTool() {
        mainStatusIndicator.dropMainStatusIndicator();
    }

    QGCPalette { id: qgcPal }

    // Solid toolbar background
    Rectangle {
        anchors.fill: parent
        color:        _toolbarBG
    }

    // Military green bottom accent line
    Rectangle {
        anchors.left:   parent.left
        anchors.right:  parent.right
        anchors.bottom: parent.bottom
        height:         2
        color:          _milGreen
        opacity:        0.85
    }

    QGCFlickable {
        anchors.fill:       parent
        contentWidth:       toolBarLayout.width
        flickableDirection: Flickable.HorizontalFlick

        Row {
            id:         toolBarLayout
            height:     parent.height
            spacing:    0

            // ---------------------------------------------------------
            // LEFT PANEL: QGC button + Main status + Flight mode
            // ---------------------------------------------------------
            Item {
                id:     leftPanel
                width:  leftPanelLayout.implicitWidth
                height: parent.height

                // Gradient background behind logo and main status indicator
                Rectangle {
                    id:         gradientBackground
                    height:     parent.height
                    width:      mainStatusLayout.width

                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: _milGreen }
                        GradientStop { position: 0.6; color: _mainStatusBGColor }
                        GradientStop { position: 1.0; color: _toolbarBG }
                    }
                }

                // Dark background to the right of the gradient
                Rectangle {
                    anchors.left:   gradientBackground.right
                    anchors.right:  parent.right
                    height:         parent.height
                    color:          _toolbarBGLight
                }

                RowLayout {
                    id:         leftPanelLayout
                    height:     parent.height
                    spacing:    ScreenTools.defaultFontPixelWidth * 2

                    RowLayout {
                        id:         mainStatusLayout
                        height:     parent.height
                        spacing:    0

                        QGCToolBarButton {
                            id:                 qgcButton
                            Layout.fillHeight:  true
                            icon.source:        "/res/QGCLogoFull.svg"
                            logo:               true
                            onClicked:          mainWindow.showToolSelectDialog()
                        }

                        MainStatusIndicator {
                            id:                 mainStatusIndicator
                            Layout.fillHeight:  true
                        }
                    }

                    QGCButton {
                        id:         disconnectButton
                        text:       qsTr("Disconnect")
                        onClicked:  _activeVehicle.closeVehicle()
                        visible:    _activeVehicle && _communicationLost
                    }

                    FlightModeIndicator {
                        Layout.fillHeight:  true
                        visible:            _activeVehicle
                    }
                }
            }

            // ---------------------------------------------------------
            // CENTER PANEL: Guided action confirm
            // ---------------------------------------------------------
            Item {
                id:     centerPanel
                // center panel takes up all remaining space in toolbar between left and right panels
                width:  Math.max(guidedActionConfirm.visible ? guidedActionConfirm.width : 0,
                                 control.width - (leftPanel.width + rightPanel.width))
                height: parent.height

                Rectangle {
                    anchors.fill:   parent
                    color:          _toolbarBG
                }

                GuidedActionConfirm {
                    id:                         guidedActionConfirm
                    height:                     parent.height
                    anchors.horizontalCenter:   parent.horizontalCenter
                    guidedController:           control._guidedController
                    guidedValueSlider:          control.guidedValueSlider
                    utmspSliderTrigger:         control.utmspSliderTrigger
                    messageDisplay:             guidedActionMessageDisplay
                }
            }

            // ---------------------------------------------------------
            // RIGHT PANEL: Garmin-style Heading Tape + Indicators
            // ---------------------------------------------------------
            Item {
                id:     rightPanel
                height: parent.height

                // We'll size this based on tape + indicators
                // (implicitWidth for indicators + preferredWidth for tape + margins)
                width:  (headingTapePreferredWidth + flyViewIndicators.implicitWidth + (_leftRightMargin * 2))

                Rectangle {
                    anchors.fill:   parent
                    color:          _toolbarBGLight
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin:  _leftRightMargin
                    anchors.rightMargin: _leftRightMargin
                    spacing: ScreenTools.defaultFontPixelWidth

                    // Garmin-style heading tape
                    Item {
                        id: headingTape
                        Layout.fillHeight: true
                        Layout.preferredWidth: headingTapePreferredWidth
                        clip: true

                        // Config
                        property int  headingTapePreferredWidth: 360
                        property real pxPerDeg: 3

                        // Vehicle heading source
                        property var  vehicle: QGroundControl.multiVehicleManager.activeVehicle
                        property real headingDeg: vehicle ? vehicle.heading.rawValue : 0

                        // Smooth movement
                        Behavior on headingDeg { NumberAnimation { duration: 120 } }

                        // Moving scale (ticks + labels)
                        Item {
                            id: scale
                            anchors.fill: parent
                            x: (parent.width / 2) - (headingTape.headingDeg * headingTape.pxPerDeg)

                            Repeater {
                                // 0..360 in 5° steps + buffer so it looks continuous
                                model: 73
                                delegate: Item {
                                    property int deg: index * 5
                                    x: deg * headingTape.pxPerDeg
                                    height: parent.height

                                    // Tick mark
                                    Rectangle {
                                        width: 1
                                        height: (deg % 10 === 0) ? parent.height * 0.70 : parent.height * 0.40
                                        anchors.verticalCenter: parent.verticalCenter
                                        color: "#8FA850"    // muted military green ticks
                                        opacity: 0.90
                                    }

                                    // Label every 30 degrees (Garmin-like),
                                    // show N/E/S/W at cardinals
                                    QGCLabel {
                                        visible: deg % 30 === 0
                                        anchors.top: parent.top
                                        anchors.topMargin: 2
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        font.bold: true
                                        font.pointSize: 11
                                        color: "#C8D4A0"    // soft olive-white
                                        text: {
                                            var d = deg % 360
                                            if (d === 0)   return "N"
                                            if (d === 90)  return "E"
                                            if (d === 180) return "S"
                                            if (d === 270) return "W"
                                            return d
                                        }
                                    }
                                }
                            }
                        }

                        // Center pointer (fixed) — military green
                        Rectangle {
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 2
                            width: 2
                            height: parent.height * 0.75
                            color: "#6B8A2A"
                            opacity: 1.0
                        }

                        // Digital heading window
                        Rectangle {
                            width: 70
                            height: parent.height * 0.72
                            anchors.centerIn: parent
                            radius: 3
                            color: "#0D0F0A"
                            opacity: 0.85
                            border.width: 1
                            border.color: "#4B5A24"     // military green border

                            QGCLabel {
                                anchors.centerIn: parent
                                text: Math.round(headingTape.headingDeg).toString().padStart(3, "0")
                                font.bold: true
                                font.pointSize: 13
                                color: "#A8C456"        // bright military green text
                            }
                        }
                    }

                    // Existing indicator cluster stays on far right
                    FlyViewToolBarIndicators {
                        id:     flyViewIndicators
                        Layout.fillHeight: true
                    }
                }

                // Local helper (so we can use it above for width)
                readonly property int headingTapePreferredWidth: 360
            }
        }
    }

    // The guided action message display is outside of the GuidedActionConfirm control so that it doesn't end up as
    // part of the Flickable
    Rectangle {
        id:                         guidedActionMessageDisplay
        anchors.top:                control.bottom
        anchors.topMargin:          _margins
        x:                          control.mapFromItem(guidedActionConfirm.parent, guidedActionConfirm.x, 0).x +
                                    (guidedActionConfirm.width - guidedActionMessageDisplay.width) / 2
        width:                      messageLabel.contentWidth + (_margins * 2)
        height:                     messageLabel.contentHeight + (_margins * 2)
        color:                      "#1C1F15"
        border.color:               "#4B5A24"
        border.width:               1
        radius:                     ScreenTools.defaultBorderRadius
        visible:                    guidedActionConfirm.visible

        QGCLabel {
            id:         messageLabel
            x:          _margins
            y:          _margins
            width:      ScreenTools.defaultFontPixelWidth * 30
            wrapMode:   Text.WordWrap
            text:       guidedActionConfirm.message
        }

        PropertyAnimation {
            id:         messageOpacityAnimation
            target:     guidedActionMessageDisplay
            property:   "opacity"
            from:       1
            to:         0
            duration:   500
        }

        Timer {
            id:             messageFadeTimer
            interval:       4000
            onTriggered:    messageOpacityAnimation.start()
        }
    }

    ParameterDownloadProgress {
        anchors.fill: parent
    }
}
