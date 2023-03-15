import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs 1.2
import QtQuick.Controls 2.15
import Qt.labs.settings 1.0
import QtQuick.Controls.Material 2.15
import QtQuick.Controls.Universal 2.15


ApplicationWindow {
    id: errorDialog
    title: errorDialog.messageTitle
    width:         Math.max(errorColumn.width, 640)
    height:        errorColumn.height
    minimumWidth:  Math.max(errorColumn.width, 640)
    minimumHeight: errorColumn.height
    maximumWidth:  Math.max(errorColumn.width, 640)
    maximumHeight: errorColumn.height

    flags: Qt.Dialog
    modality: Qt.WindowModal

    property string messageTitle: ""
    property string messageText:  ""
    property int    mainWidth:    640
    property int    mainHeight:   480
    property bool   bDark:        false
    property int    fontPadding:  0
    property string returnValue:  ""

    ColumnLayout {
        id: errorColumn
        spacing: 20

        RowLayout {
            width: parent.width

            Layout.fillWidth: true
            Layout.margins: 20

            spacing: 0

            Image {
                id: errorIcon
                source: "qrc:/Image/Critical.png"
                fillMode: Image.Stretch

                Layout.alignment: Qt.AlignTop | Qt.AlignVCenter
                Layout.leftMargin:  (errorDialog.width - errorIcon.width - errorLabel.width - 60) / 2
                Layout.rightMargin: 20
            }

            Label {
                id: errorLabel
                text: errorDialog.messageText
                font.pointSize: 12 + errorDialog.fontPadding

                textFormat: Label.RichText
                wrapMode: Label.WordWrap

                verticalAlignment: Label.AlignVCenter
                Layout.maximumWidth: errorDialog.width - errorIcon.width - 60
                Layout.fillHeight: true
            }
        }

        Button {
            id: errorOKBtn
            text: "OK"
            implicitWidth: Math.round(errorColumn.width / 5) > 200 ? 300 : 200
            implicitHeight: Math.round(errorColumn.height / 15) > 50 ? 70 : 50
            focus: true

            Layout.leftMargin: (errorDialog.width - errorOKBtn.width) / 2
            Layout.bottomMargin: 20

            contentItem: Label {
                text: parent.text
                font: parent.font
                color: errorDialog.bDark ? parent.pressed ? "#cccccc" : "#ffffff" : parent.pressed ? "#333333" : "#000000"

                horizontalAlignment: Label.AlignHCenter
                verticalAlignment: Label.AlignVCenter
                elide: Label.ElideRight
            }

            background: Rectangle {
                implicitWidth: parent.width
                implicitHeight: parent.height
                color: "transparent"
                opacity: parent.focus ? 0.3 : 1
                border.color: errorDialog.bDark ? "#10980a" : "#20a81a"
                border.width: parent.focus ? 3 : 1
                radius: 2
            }

            Connections {
                target: errorOKBtn
                function onClicked() {
                    errorDialog.close();
                }
            }

            Keys.onPressed: {
                if (event.key === Qt.Key_Return) {
                    // If pressed [Return] key, focused [OK] button
                    // Close ErrorDialog
                    errorDialog.close()
                }
            }
        }
    }
}
