import QtQuick
import QGroundControl
import QGroundControl.Controls
import QGroundControl.FlyView

ToolStrip {
    id: root

    FlyViewRightToolStripActionList {
        id: actions
    }

    model: actions.model
}
