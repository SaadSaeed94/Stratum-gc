import QtQuick
import QGroundControl
import QGroundControl.Controls
import QGroundControl.FlyView

Item {
    id: root

    // build the model the "QGC way"
    ToolStripActionList {
        id: actionList

        model: [
            ToolStripAction {
                text: qsTr("Takeoff")
                iconSource: "qrc:/res/takeoff.svg"
                visible: true
                enabled: QGroundControl.multiVehicleManager.activeVehicle !== null
                onTriggered: globals.guidedControllerFlyView.confirmAction(globals.guidedControllerFlyView.actionTakeoff)
            },
            ToolStripAction {
                text: qsTr("Return")
                iconSource: "qrc:/res/rtl.svg"
                visible: true
                enabled: QGroundControl.multiVehicleManager.activeVehicle !== null
                onTriggered: globals.guidedControllerFlyView.confirmAction(globals.guidedControllerFlyView.actionRTL)
            },
            ToolStripAction {
                text: qsTr("Land")
                iconSource: "qrc:/qmlimages/land.svg"
                visible: true
                enabled: QGroundControl.multiVehicleManager.activeVehicle !== null
                onTriggered: globals.guidedControllerFlyView.confirmAction(globals.guidedControllerFlyView.actionLand)
            },
            ToolStripAction {
                text: qsTr("Pause")
                iconSource: "qrc:/qmlimages/pause.svg"
                visible: true
                enabled: QGroundControl.multiVehicleManager.activeVehicle !== null
                onTriggered: globals.guidedControllerFlyView.confirmAction(globals.guidedControllerFlyView.actionPause)
            }
        ]
    }

    // expose it to ToolStrip
    property alias model: actionList
}
