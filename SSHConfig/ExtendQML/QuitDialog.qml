import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs 1.2
import QtQuick.Controls 2.15
import Qt.labs.settings 1.0
import QtQuick.Controls.Material 2.15
import QtQuick.Controls.Universal 2.15


ApplicationWindow {
    id: quitDialog
    title: qsTr("Quit SSHConfig")
    width: mainWidth
    height: quitColumn.height

    flags: Qt.Dialog
    modality: Qt.WindowModal

    property int  mainWidth:   640
    property int  mainHeight:  480
    property var  windowState: null
    property bool bDark:       false
    property bool bPP:         false
    property int  returnValue: 1

    Settings {
        id: settings
        property string style: windowState.getColorMode() ? "Material" : "Universal"
    }

    Shortcut {
        sequence: "Esc"
        onActivated: {
            returnValue = 1
            quitDialog.close()
        }
    }

    Shortcut {
        sequences: ["Left", "Right"]
        onActivated: {
            if (quitDialogBtnOK.focus) quitDialogBtnCancel.focus = true
            else quitDialogBtnOK.focus = true
        }
    }

    onVisibleChanged: {
        quitDialogBtnCancel.focus = true
    }

    Component.onCompleted: {
        // For PinePhone.
        if (bPP) {
            quitDialog.color = bDark ? "#3f3f3f" : "#f5f5f5"
        }
    }

    ColumnLayout {
        id: quitColumn
        width: parent.width
        spacing: 20

        Label {
            text: qsTr("Do you want to quit SSHConfig?")
            width: parent.width
            font.pointSize: 12

            wrapMode: Label.WordWrap
            horizontalAlignment: Label.AlignHCenter
            verticalAlignment: Label.AlignVCenter
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.topMargin: 20
            Layout.bottomMargin: 20
        }

        RowLayout {
            x: parent.x
            width: parent.width
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: 20
            spacing: 20

            Button {
                id: quitDialogBtnOK
                text: qsTr("OK")
                implicitWidth: Math.max(170, parent.width / 5)
                implicitHeight: Math.max(50, parent.height / 5)

                contentItem: Label {
                    text: parent.text
                    font: parent.font
                    opacity: enabled ? 1.0 : 0.3
                    color: windowState.getColorMode() ? parent.pressed ? "#cccccc" : "#ffffff" : parent.pressed ? "#333333" : "#000000"

                    horizontalAlignment: Label.AlignHCenter
                    verticalAlignment: Label.AlignVCenter
                    elide: Label.ElideRight
                }

                background: Rectangle {
                    implicitWidth: parent.width
                    implicitHeight: parent.height
                    color: "transparent"
                    opacity: parent.focus ? 0.3 : 1
                    border.color: windowState.getColorMode() ? "#10980a" : "#20a81a"
                    border.width: parent.focus ? 3 : 1
                    radius: 2
                }

                Connections {
                    target: quitDialogBtnOK
                    function onClicked() {
                        // Close QuitDialog
                        returnValue = 0
                        quitDialog.close()
                    }
                }

                Keys.onPressed: {
                    if (event.key === Qt.Key_Return) {
                        // If pressed [Return] key, focused [OK] button
                        // Close QuitDialog
                        returnValue = 0
                        quitDialog.close()
                    }
                }
            }

            Button {
                id: quitDialogBtnCancel
                text: qsTr("Cancel")
                focus: true
                flat: false

                implicitWidth: Math.max(170, parent.width / 5)
                implicitHeight: Math.max(50, parent.height / 5)

                contentItem: Label {
                    text: parent.text
                    font: parent.font
                    opacity: enabled ? 1.0 : 0.3
                    color: windowState.getColorMode() ? parent.pressed ? "#cccccc" : "#ffffff" : parent.pressed ? "#333333" : "#000000"

                    horizontalAlignment: Label.AlignHCenter
                    verticalAlignment: Label.AlignVCenter
                    elide: Label.ElideRight
                }

                background: Rectangle {
                    implicitWidth: parent.width
                    implicitHeight: parent.height
                    color: "transparent"
                    opacity: parent.focus ? 0.3 : 1
                    border.color: windowState.getColorMode() ? "#10980a" : "#20a81a"
                    border.width: parent.focus ? 3 : 1
                    radius: 2
                }

                Connections {
                    target: quitDialogBtnCancel
                    function onClicked() {
                        // Close QuitDialog
                        returnValue = 1
                        quitDialog.close();
                    }
                }

                Keys.onPressed: {
                    if (event.key === Qt.Key_Return) {
                        // If pressed [Return] key, focused [Cancel] button
                        // Close QuitDialog
                        returnValue = 1
                        quitDialog.close();
                    }
                }
            }
        }
    }
}
