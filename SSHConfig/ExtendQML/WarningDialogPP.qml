import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs 1.2
import QtQuick.Controls 2.15
import Qt.labs.settings 1.0
import QtQuick.Controls.Material 2.15
import QtQuick.Controls.Universal 2.15


ApplicationWindow {
    id: warningDialog
    title:         warningDialog.messageTitle
    width:         warningDialog.viewWidth
    height:        warningDialog.viewHeight * 0.8

    color: bDark ? "#3f3f3f" : "#f5f5f5"

    flags: Qt.Dialog
    modality: Qt.WindowModal

    property string messageTitle: ""
    property string messageText:  ""
    property int    viewWidth:    0
    property int    viewHeight:   0
    property bool   bDark:        false
    property int    fontPadding:  0
    property string returnValue:  ""

    ScrollView {
        id: scrollWarning
        width: parent.width
        height : parent.height - warningOKBtn.implicitHeight - 20
        contentWidth: warningRow.width    // The important part
        contentHeight: warningRow.height  // Same
        clip : true                       // Prevent drawing column outside the scrollview borders

        Rectangle {
            id: warningRect
            color: "transparent"

            anchors.fill: parent
            anchors.topMargin: 20

            RowLayout {
                id: warningRow
                width: parent.width
                spacing: 0

                Layout.fillWidth: true
                Layout.margins: 20

                Image {
                    id: warningIcon
                    source: "qrc:/Image/Warning.png"
                    fillMode: Image.Stretch

                    Layout.alignment: Qt.AlignTop | Qt.AlignVCenter
                    Layout.leftMargin: Math.round((warningDialog.viewWidth - width - warningLabel.width - 60) / 2) > 0 ?
                                       (warningDialog.viewWidth - width - warningLabel.width - 60) / 2 : 0
                    Layout.rightMargin: 20
                }

                Label {
                    id: warningLabel
                    text: warningDialog.messageText
                    font.pointSize: 12

                    textFormat: Label.RichText
                    wrapMode: Label.WordWrap

                    verticalAlignment: Label.AlignVCenter
                    Layout.maximumWidth: warningDialog.width * 0.7
                    Layout.fillHeight: true
                }
            }
        }
    }

    Button {
        id: warningOKBtn
        text: "OK"
        implicitWidth:  Math.round(warningRect.width / 5) > 200 ? 300 : 200
        implicitHeight: Math.round(warningRect.height / 15) > 50 ? 70 : 50
        focus: true

        anchors.top: scrollWarning.bottom
        anchors.bottomMargin: 20
        anchors.horizontalCenter: parent.horizontalCenter

        contentItem: Label {
            text: parent.text
            font: parent.font
            color: warningDialog.bDark ? parent.pressed ? "#cccccc" : "#ffffff" : parent.pressed ? "#333333" : "#000000"

            horizontalAlignment: Label.AlignHCenter
            verticalAlignment: Label.AlignVCenter
            elide: Label.ElideRight
        }

        background: Rectangle {
            implicitWidth: parent.width
            implicitHeight: parent.height
            color: "transparent"
            opacity: parent.focus ? 0.3 : 1
            border.color: warningDialog.bDark ? "#10980a" : "#20a81a"
            border.width: parent.focus ? 3 : 1
            radius: 2
        }

        Connections {
            target: warningOKBtn
            function onClicked() {
                warningDialog.close();
            }
        }

        Keys.onPressed: {
            if (event.key === Qt.Key_Return) {
                // If pressed [Return] key, focused [OK] button
                // Close Warning Dialog
                warningDialog.close()
            }
        }
    }
}
