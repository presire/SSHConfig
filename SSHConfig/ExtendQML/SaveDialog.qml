import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs 1.2
import QtQuick.Controls 2.15
import Qt.labs.settings 1.0
import QtQuick.Controls.Material 2.15
import QtQuick.Controls.Universal 2.15


ApplicationWindow {
    property int  mainWidth:   640
    property int  mainHeight:  480
    property var  windowState: null
    property int  state:       0
    property int  move:        0

    property bool   bServerMode:    true
    property bool   bAdminPassword: true
    property int    iFont:          0
    property bool   bTheme:         false

    id: saveDialog
    title: qsTr("Save the Settings")
    width: Math.round(Math.min(mainWidth, mainHeight) / 10 * 9)
    height: saveColumn.height

    flags: Qt.Dialog
    modality: Qt.WindowModal

    Settings {
        id: settings
        property string style: windowState.getColorMode() ? "Material" : "Universal"
    }

    Shortcut {
        sequence: "Esc"
        onActivated: {
            saveDialog.close()
        }
    }

    Shortcut {
        sequences: ["Left"]
        onActivated: {
            saveYesBtn.focus ? saveCancelBtn.focus = true : saveNoBtn.focus ? saveYesBtn.focus = true : saveNoBtn.focus = true
        }
    }

    Shortcut {
        sequences: ["Right"]
        onActivated: {
            saveYesBtn.focus ? saveNoBtn.focus = true : saveNoBtn.focus ? saveCancelBtn.focus = true : saveYesBtn.focus = true
        }
    }

    onVisibleChanged: {
        saveCancelBtn.focus = true
    }

    ColumnLayout {
        id: saveColumn
        width: parent.width
        spacing: 20

        Label {
            text: qsTr("No data is saved.") + "<br>" +
                  qsTr("Do you want to save it?")
            textFormat: Label.RichText
            wrapMode: Label.WordWrap

            horizontalAlignment: Label.AlignHCenter
            verticalAlignment: Label.AlignVCenter
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.topMargin: 20
            Layout.bottomMargin: 20
        }

        RowLayout {
            width: parent.width
            spacing: 20

            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: 20

            Button {
                id: saveYesBtn
                text: qsTr("Yes")
                enabled: true
                implicitWidth: Math.max(200, parent.width / 5)
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

                onClicked: {
                    // Save Server Mode.
                    windowState.setServerMode(bServerMode)

                    // Save Font
                    windowState.setFontSize(iFont)

                    // Save ColorMode
                    if (bTheme !== windowState.getColorMode()) {
                        windowState.setColorModeOverWrite(true)
                    }
                    else {
                        windowState.setColorModeOverWrite(false)
                    }

                    // Return status value.
                    saveDialog.state = 0

                    // Close dialog.
                    saveDialog.close()
                }

                Keys.onReturnPressed: {
                    clicked()
                }
            }

            Button {
                id: saveNoBtn
                text: qsTr("No")
                implicitWidth: Math.max(200, parent.width / 5)
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

                onClicked: {
                    // Return status value.
                    saveDialog.state = 1

                    // Close dialog.
                    saveDialog.close()
                }

                Keys.onReturnPressed: {
                    clicked()
                }
            }

            Button {
                id: saveCancelBtn
                text: qsTr("Cancel")
                implicitWidth: Math.max(200, parent.width / 5)
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

                onClicked: {
                    // Return status value.
                    saveDialog.state = 2

                    // Close dialog.
                    saveDialog.close()
                }

                Keys.onReturnPressed: {
                    clicked()
                }
            }
        }
    }
}
