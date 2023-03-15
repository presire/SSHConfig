import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs 1.2
import QtQuick.Controls 2.15
import Qt.labs.settings 1.0
import QtQuick.Controls.Material 2.15
import QtQuick.Controls.Universal 2.15


ApplicationWindow {
    id: restartDialog
    title: qsTr("Restart")
    width: bPP === false ? Math.round(Math.min(mainWidth, mainHeight) / 10 * 9) : mainWidth
    height: restartColumn.height

    flags: Qt.Dialog
    modality: Qt.WindowModal

    property var  parentName:  null
    property var  windowState: null
    property int  mainWidth:   640
    property int  mainHeight:  480
    property bool bServerMode: true
    property int  fontCheck:   1
    property bool bTheme:      false
    property int  langIndex:   0
    property bool bPP:         false  // for PinePhone


    Settings {
        id: settings
        property string style: windowState.getColorMode() ? "Material" : "Universal"
    }

    Shortcut {
        sequence: "Esc"
        onActivated: {
            restartDialog.close()
        }
    }

    Shortcut {
        sequences: ["Left", "Right"]
        onActivated: {
            restartOKBtn.focus ? restartCancelBtn.focus = true : restartOKBtn.focus = true
        }
    }

    onVisibleChanged: {
        restartCancelBtn.focus = true
    }

    Component.onCompleted: {
        // For PinePhone.
        if (bPP) {
            restartDialog.color = parentName.bDark ? "#3f3f3f" : "#f5f5f5"
        }
    }

    ColumnLayout {
        id: restartColumn
        width: parent.width
        spacing: 20

        Label {
            text: qsTr("When you restart this software, the color will change.") + "<br>" +
                  qsTr("Now, would you like to Restart?")
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
                id: restartOKBtn
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
                    // Save window size.
                    let bMaximized = false
                    if(parentName.visibility === Window.Maximized) {
                        bMaximized = true
                    }

                    windowState.setMainWindowState(parentName.x, parentName.y, parentName.width, parentName.height, bMaximized)

                    // Save Server Mode.
                    windowState.setServerMode(restartDialog.bServerMode)

                    // Save Font.
                    windowState.setFontSize(restartDialog.fontCheck)

                    // Save color mode.
                    windowState.setColorMode(restartDialog.bTheme)
                    windowState.setColorModeOverWrite(false)

                    // Save language.
                    windowState.setLanguage(restartDialog.langIndex)

                    // Remove tmp files.
                    windowState.removeTmpFiles()

                    // Restart software.
                    windowState.restartSoftware()

                    Qt.quit()
                }

                Keys.onReturnPressed: {
                    clicked()
                }
            }

            Button {
                id: restartCancelBtn
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
                    restartDialog.close()
                }

                Keys.onReturnPressed: {
                    clicked()
                }
            }
        }
    }
}
