import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Controls.Universal 2.15
import "../ExtendQML"


Item {
    id: root

    property int  viewWidth:   0
    property int  viewHeight:  0
    property int  fontPadding: 0
    property bool bDark:       false
    property bool bServerMode: true

    property bool bReadSuccess: false
    property var  sshServer:    null
    property var  sshValue:     null

    // Signal and Signal Handlers
    signal readSuccess()
    onReadSuccess: {
        editorArea.text = sshServer.getContents()
    }

    signal clear()
    onClear: {
        editorArea.text = ""
    }

    function fnWriteSSHFile(sshFile : string) {
        let errMsg          = ""
        let componentDialog = null
        let errorDialog     = null

        // Write TextArea contents to temporary sshd_config.
        let iRet = sshServer.writeToSSHFileForEditor(editorArea.text)
        if (iRet === -1) {
            // Display error message.
            errMsg = sshServer.getErrorMessage()

            componentDialog = Qt.createComponent("qrc:/ExtendQML/ErrorDialogPP.qml");
            if (componentDialog.status === Component.Ready) {
                errorDialog = componentDialog.createObject(root,
                                                           {mainWidth: root.width, mainHeight: root.height, bDark: root.bDark,
                                                            messageTitle: qsTr("Error"),
                                                            messageText: qsTr("Failed to write sshd_config file.") + "<br>" + errMsg});
                errorDialog.show();
            }

            return -1
        }

        // Copy and backup sshd_config file.
        let bCanceled = false
        if (root.bServerMode) {
            // Server mode.
            iRet = sshServer.copySSHFile(sshFile)
            if (iRet === -1) {
                // If fail to copy sshd_config file.
                // Display error message.
                errMsg = sshServer.getErrorMessage()

                componentDialog = Qt.createComponent("qrc:/ExtendQML/ErrorDialogPP.qml");
                if (componentDialog.status === Component.Ready) {
                    errorDialog = componentDialog.createObject(root,
                                                               {mainWidth: root.width, mainHeight: root.height, bDark: root.bDark,
                                                                messageTitle: qsTr("Copy Error"),
                                                                messageText: qsTr("Failed to copy sshd_config file.") + "<br>" + errMsg});
                    errorDialog.show();
                }

                return -1
            }
            else if (iRet === 1) {
                bCanceled = true
            }
        }
        else {
            // Client mode. (Use remote server)
            iRet = sshServer.uploadSSHConfigFile(sshFile)
            if (iRet === -1) {
                // If fail to upload sshd_config file.
                // Display error message.
                errMsg = sshServer.getErrorMessage()

                componentDialog = Qt.createComponent("qrc:/ExtendQML/ErrorDialogPP.qml");
                if (componentDialog.status === Component.Ready) {
                    errorDialog = componentDialog.createObject(root,
                                                               {mainWidth: root.width, mainHeight: root.height, bDark: root.bDark,
                                                                messageTitle: qsTr("Upload Error"),
                                                                messageText: qsTr("Failed to upload sshd_config file.") + "<br>" + errMsg});
                    errorDialog.show();
                }

                return -1
            }
        }

        // Re-load updated sshd_config.
        let tmpSSHFile = sshServer.getTmpFilePath()
        iRet = sshServer.readSSHFile(tmpSSHFile)
        if (iRet === -1) {
            // If fail to load file.

            // Display error message.
            errMsg = sshServer.getErrorMessage()

            componentDialog = Qt.createComponent("qrc:/ExtendQML/ErrorDialogPP.qml");
            if (componentDialog.status === Component.Ready) {
                errorDialog = componentDialog.createObject(root,
                                                           {mainWidth: root.width, mainHeight: root.height, bDark: root.bDark,
                                                            messageTitle: qsTr("Reload Error"),
                                                            messageText: qsTr("Failed to reload sshd_config file.") + "<br>" + errMsg});
                errorDialog.show();
            }

            return -1
        }

        // Reload updated Json file.
        let jsonFile = sshServer.getJsonFilePath()
        if (sshValue.readFromJson(jsonFile)) {
            // If fail to reload sshd_config file.

            // Display error message.
            errMsg = sshServer.getErrorMessage()

            componentDialog = Qt.createComponent("qrc:/ExtendQML/ErrorDialogPP.qml");
            if (componentDialog.status === Component.Ready) {
                errorDialog = componentDialog.createObject(root,
                                                           {mainWidth: root.width, mainHeight: root.height, bDark: root.bDark,
                                                            messageTitle: qsTr("Reload Error"),
                                                            messageText: qsTr("Failed to reload Json file.") + "<br>" + errMsg});
                errorDialog.show();
            }

            return -1
        }

        // Diplay success popup.
        if (root.bServerMode && bCanceled === false) {
            completePopup.viewTitle = qsTr("Write \"sshd_config\" file")
            completePopup.fontPadding = root.fontPadding
            completePopup.bAutolose = false
            completePopup.open()
        }

        return 0
    }

    Frame {
        id: frameList
        x: 0
        y: 20
        width: root.viewWidth - 20
        implicitWidth: root.viewWidth - 20
        height: root.viewHeight - (y * 2)
        implicitHeight: root.viewHeight - (y * 2)

        ScrollView {
            id: scrollEditor
            x: parent.x
            y: parent.y
            width: parent.width
            height: parent.height
            clip: true                              // Prevent drawing column outside the scrollview borders

            ScrollBar.vertical.interactive: true
            ScrollBar.vertical.policy: ScrollBar.AsNeeded
            ScrollBar.vertical.visible: ScrollBar.vertical.size < 1
            ScrollBar.horizontal.interactive: true
            ScrollBar.horizontal.policy: ScrollBar.AsNeeded
            ScrollBar.horizontal.visible: ScrollBar.horizontal.size < 1

            TextArea {
                id: editorArea
                text: ""
                width: parent.width
                height: parent.height
                font.pointSize: 12 + root.fontPadding
                readOnly: false

                background: Rectangle {
                    implicitWidth: parent.width
                    height: parent.height
                    color: "transparent"
                    opacity: 0.0
                    border.width: 0
                }
            }
        }
    }

    CompletePopup {
        id: completePopup

        viewTitle:   ""
        positionY:   0
        viewWidth:   root.width
        fontPadding: root.fontPadding
        parentName:  null
    }
}
