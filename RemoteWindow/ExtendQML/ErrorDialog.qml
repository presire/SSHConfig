import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs 1.2
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Controls.Universal 2.15


ApplicationWindow {
    id: errorDialog
    title: errorDialog.messageTitle
    width:          Math.max(errorColumn.width, 640)
    height:         errorColumn.height
    minimumWidth:   Math.max(errorColumn.width, 640)
    minimumHeight:  errorColumn.height
    maximumWidth:   Math.max(errorColumn.width, 640)
    maximumHeight:  errorColumn.height

    flags: Qt.Dialog
    modality: Qt.WindowModal

    property string messageTitle: ""
    property string messageText:  ""
    property string returnValue:  ""
    property bool   bDark:        false
    property int    fontPadding:  0

    ColumnLayout {
        id: errorColumn
        spacing: 20

        RowLayout {
            width: parent.width

            Layout.alignment: Qt.AlignHCenter
            Layout.margins: 20

            spacing: 0

            Image {
                id: errorIcon
                source: "qrc:/Image/Critical.png"
                fillMode: Image.Stretch

                Layout.alignment: Qt.AlignVCenter
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
            text: qsTr("OK")
            implicitWidth: Math.max(200, parent.width / 5)
            implicitHeight: Math.max(50, parent.height / 5)
            font.pointSize: 12 + errorDialog.fontPadding

            Layout.leftMargin: (errorDialog.width - errorOKBtn.width) / 2
            Layout.bottomMargin: 20

            contentItem: Label {
                text: parent.text
                font: parent.font
                opacity: enabled ? 1.0 : 0.3
                color: errorDialog.bDark ? parent.pressed ? "#cccccc" : "#ffffff" : parent.pressed ? "#333333" : "#000000"
                horizontalAlignment: Label.AlignHCenter
                verticalAlignment: Label.AlignVCenter
                elide: Label.ElideRight
            }

            background: Rectangle {
                implicitWidth: parent.width
                implicitHeight: parent.height
                color: "transparent"
                opacity: enabled ? 1 : 0.3
                border.color: parent.pressed ? "#10980a" : "#20a81a"
                border.width: parent.pressed ? 3 : 2
                radius: 2
            }

            Connections {
                target: errorOKBtn
                function onClicked() {
                    errorDialog.close();
                }
            }
        }
    }
}
