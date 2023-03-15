import QtQuick 2.15
import QtQuick.Controls 2.15


Item {
    id: root

    property string text: ""
    property string font: ""

    Button {
        id: extendBtn
        font.pointSize: 12

        contentItem: Label {
            text: root.text
            font: root.font
            opacity: enabled ? 1.0 : 0.3
            color: root.pressed ? "#10980a" : "#20a81a"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }

        background: Rectangle {
            implicitWidth: 250
            implicitHeight: 60
            opacity: enabled ? 1 : 0.3
            border.color: root.pressed ? "#10980a" : "#20a81a"
            border.width: 1
            radius: 2
        }
    }
}
