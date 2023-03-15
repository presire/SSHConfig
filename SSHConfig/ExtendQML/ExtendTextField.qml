import QtQuick 2.15
import QtQuick.Controls 2.15

TextField {
    id: control
    placeholderText: ""

    property bool colorMode:  false
    property int  rectWidth:  200
    property int  rectHeight: 40

    background: Rectangle {
        implicitWidth: rectWidth
        implicitHeight: rectHeight
        color: colorMode ? "transparent" : control.enabled ? "transparent" : "#353637"
        border.color: colorMode ? "transparent" : control.enabled ? "#21be2b" : "transparent"
    }

    cursorDelegate: Rectangle {
        id: cursor
        visible: false
        color: "salmon"
        width: control.cursorRectangle.width

        SequentialAnimation {
            loops: Animation.Infinite
            running: control.cursorVisible

            PropertyAction {
                target: cursor
                property: 'visible'
                value: true
            }

            PauseAnimation {
                duration: 600
            }

            PropertyAction {
                target: cursor
                property: 'visible'
                value: false
            }

            PauseAnimation {
                duration: 600
            }

            onStopped: {
                cursor.visible = false
            }
        }
    }
}
