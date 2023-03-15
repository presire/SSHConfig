import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Controls.Universal 2.15


Popup {
    id: errorPopup
    y: 50
    width: mainWidth

    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside | Popup.CloseOnPressOutsideParent

    property int mainX:  0
    property int mainWidth:  0
    property int mainHeight: 0
    property string messageText: ""

    ColumnLayout {
        id: errorColumn
        x: parent.x
        width: parent.width
        spacing: 20

        Layout.margins: 50

        Label {
            text: errorPopup.messageText
            font.pointSize: 14

            textFormat: Label.RichText
            wrapMode: Label.WordWrap

            horizontalAlignment: Label.AlignHCenter
            verticalAlignment: Label.AlignVCenter
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.topMargin: 20
            Layout.bottomMargin: 20
        }
    }

    onOpened: {
        errorTimer.start();
    }

    Timer {
        id: errorTimer

        interval: 5000
        repeat: false
        running: false

        onTriggered: {
            errorTimer.stop();
            errorPopup.close();
        }
    }
}
