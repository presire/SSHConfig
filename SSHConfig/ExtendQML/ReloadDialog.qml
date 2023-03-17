import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs 1.2
import QtQuick.Controls 2.15
import Qt.labs.settings 1.0
import QtQuick.Controls.Material 2.15
import QtQuick.Controls.Universal 2.15


ApplicationWindow {
    id: reloadDialog
    title: qsTr("Reload")
    width: bPP === false ? Math.round(Math.min(mainWidth, mainHeight) / 10 * 9) : mainWidth
    height: reloadColumn.height

    flags: Qt.Dialog
    modality: Qt.WindowModal

    property var  parentName:  null
    property int  mainWidth:   640
    property int  mainHeight:  480
    property int  fontCheck:   1
    property bool bDark:       false
    property bool bServerMode: true
    property bool bPP:         false  // for PinePhone
    property int  returnValue: 0


    Settings {
        id: settings
        property string style: reloadDialog.bDark ? "Material" : "Universal"
    }

    Shortcut {
        sequence: "Esc"
        onActivated: {
            reloadDialog.close()
        }
    }

    Shortcut {
        sequences: ["Left", "Right"]
        onActivated: {
            reloadOKBtn.focus ? reloadCancelBtn.focus = true : reloadOKBtn.focus = true
        }
    }

    onVisibleChanged: {
        reloadCancelBtn.focus = true
    }

    Component.onCompleted: {
        // For PinePhone.
        if (bPP) {
            reloadDialog.color = reloadDialog.bDark ? "#3f3f3f" : "#f5f5f5"
        }
    }

    ColumnLayout {
        id: reloadColumn
        width: parent.width
        spacing: 20

        Label {
            text: reloadDialog.bServerMode ? qsTr("Do you want to reload the sshd_config file?") :
                                             qsTr("Do you want to re-download the sshd_config file?")
            textFormat: Label.RichText
            wrapMode: Label.WordWrap

            horizontalAlignment: Label.AlignHCenter
            verticalAlignment: Label.AlignVCenter

            Layout.maximumWidth: reloadDialog.width * 0.8
            Layout.fillHeight:   true
            Layout.topMargin:    20
            Layout.leftMargin:   (reloadDialog.width - width) / 2
            Layout.bottomMargin: 20
        }

        RowLayout {
            width: parent.width
            spacing: 20

            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: 20

            Button {
                id: reloadOKBtn
                text: qsTr("OK")
                enabled: true
                implicitWidth: Math.max(200, parent.width / 5)
                implicitHeight: Math.max(50, parent.height / 5)

                contentItem: Label {
                    text: parent.text
                    font: parent.font
                    opacity: enabled ? 1.0 : 0.3
                    color: reloadDialog.bDark ? parent.pressed ? "#cccccc" : "#ffffff" : parent.pressed ? "#333333" : "#000000"

                    horizontalAlignment: Label.AlignHCenter
                    verticalAlignment: Label.AlignVCenter
                    elide: Label.ElideRight
                }

                background: Rectangle {
                    implicitWidth: parent.width
                    implicitHeight: parent.height
                    color: "transparent"
                    opacity: parent.focus ? 0.3 : 1
                    border.color: reloadDialog.bDark ? "#10980a" : "#20a81a"
                    border.width: parent.focus ? 3 : 1
                    radius: 2
                }

                onClicked: {
                    // Reload sshd_config file.
                    reloadDialog.returnValue = 1
                    reloadDialog.close()
                }

                Keys.onReturnPressed: {
                    clicked()
                }
            }

            Button {
                id: reloadCancelBtn
                text: qsTr("Cancel")
                implicitWidth: Math.max(200, parent.width / 5)
                implicitHeight: Math.max(50, parent.height / 5)

                contentItem: Label {
                    text: parent.text
                    font: parent.font
                    opacity: enabled ? 1.0 : 0.3
                    color: reloadDialog.bDark ? parent.pressed ? "#cccccc" : "#ffffff" : parent.pressed ? "#333333" : "#000000"

                    horizontalAlignment: Label.AlignHCenter
                    verticalAlignment: Label.AlignVCenter
                    elide: Label.ElideRight
                }

                background: Rectangle {
                    implicitWidth: parent.width
                    implicitHeight: parent.height
                    color: "transparent"
                    opacity: parent.focus ? 0.3 : 1
                    border.color: reloadDialog.bDark ? "#10980a" : "#20a81a"
                    border.width: parent.focus ? 3 : 1
                    radius: 2
                }

                onClicked: {
                    reloadDialog.close()
                }

                Keys.onReturnPressed: {
                    clicked()
                }
            }
        }
    }
}
