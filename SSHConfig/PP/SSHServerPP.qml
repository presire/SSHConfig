import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import Qt.labs.settings 1.0
import QtQuick.Controls.Material 2.15
import QtQuick.Controls.Universal 2.15
import "../ExtendQML"
import SSHValue 1.0


Page {
    id: pageSSHServer
    title: qsTr("SSH Server")
    objectName: "pageSSHServer"
    focus: true

    property var    parentName:      null
    property var    windowState:     null
    property var    sshServerConfig: null
    property int    fontPadding:     0
    property bool   bDark:           false
    property bool   bServerMode:     true
    property string localFileName:   ""
    property string remoteFileName:  ""
    property bool   bReadSuccess:    false

    CSSHValue {
        id: sshValue
    }

    Component.onCompleted: {
        if (pageSSHServer.bServerMode) {
            // Server Mode.
            // Enable "Reload" button, but disable "Write" buttons.
            btnReload.enabled = true
            btnWrite.enabled  = false

            let iAuth = sshServerConfig.getFileReadPermissions(textSSHFilePath.text)
            if (iAuth === 0) {
                // If you have file read permission.

                // Change the buttons text from the ssh(d).service file permissions.
                btnReload.text = qsTr("Read/Reload")
                btnWrite.text  = qsTr("Write")
            }
            else if (iAuth === -1) {
                // If you do not have file read permission.

                // change the buttons text from the ssh(d).service file permissions.
                btnReload.text = qsTr("Read/Reload") + "\n" + qsTr("(Req: Auth)")
                btnWrite.text  = qsTr("Write") + "\n" + qsTr("(Req: Auth)")
            }
            else {
                // Text-Edit is blank or file not exist.
                return
            }

            // Display exist file.
            textSSHFilePath.readFilePath = textSSHFilePath.text
        }
        else {
            // Client Mode.

            // Enable "Read / Reload" button, but disable "Write" buttons.
            btnReload.enabled = true
            btnWrite.enabled  = false

            btnReload.text = qsTr("Read/Reload")
            btnWrite.text  = qsTr("Write")
        }
    }

    Connections {
        id: errorDialogConnection
        function onVisibleChanged() {
            if(!target.visible) {
                if (target.returnValue === 0) {
                }
                target = null
            }
        }
    }

    ErrorPopup {
        id: errorPopup
    }

    // Set Downloaded file on remote server.
    Connections {
        target: sshServerConfig
        function onDownloadSSHFileFromServer(remoteFilePath, contents) {
            // Read recieving file.
            pageSSHServer.fnReadSSHFileFromServer(remoteFilePath, contents)
        }
    }

    // Set Re-Downloaded file on remote server.
    Connections {
        target: sshServerConfig
        function onReloadSSHFileFromServer(remoteFilePath, contents) {
            // Read recieving file.
            pageSSHServer.fnReadSSHFileFromServer(remoteFilePath, contents)
        }
    }

    // Uploaded file to remote server.
    Connections {
        target: sshServerConfig
        function onUploadedSSHFileToServer(status, errorMessage) {
            // Uploaded file.
            if (status !== 0) {
                let errMsg = errorMessage
                let componentDialog = Qt.createComponent("qrc:/ExtendQML/ErrorDialogPP.qml");
                if (componentDialog.status === Component.Ready) {
                    let errorDialog = componentDialog.createObject(pageSSHServer,
                                                                   {mainWidth: pageSSHServer.width, mainHeight: pageSSHServer.height, bDark: pageSSHServer.bDark,
                                                                    messageTitle: qsTr("Read Error"),
                                                                    messageText: qsTr("Failed to upload sshd_config file.") + "<br>" + errMsg});
                    errorDialogConnection.target = errorDialog
                    errorDialog.show();
                }
            }
            else {
                completePopup.viewTitle   = qsTr("Upload \"sshd_config\" file to remote server")
                completePopup.fontPadding = pageSSHServer.fontPadding
                completePopup.bAutolose   = false
                completePopup.open()
            }

            sshServerConfig.disconnectFromServer()
        }
    }

    function fnReadSSHFile(strFilePath: string) {
        let errMsg = ""
        let componentDialog = null
        let errorDialog     = null

        // Read sshd_config file.
        let iRet = sshServerConfig.readSSHFile(strFilePath)
        if (iRet === -1) {
            // If fail to load file.

            // Disable read flag.
            pageSSHServer.bReadSuccess = false

            // Delete the contents of TextEdit.
            textSSHFilePath.readFilePath = ""

            // Display error message.
            errMsg = sshServerConfig.getErrorMessage()

            componentDialog = Qt.createComponent("qrc:/ExtendQML/ErrorDialogPP.qml");
            if (componentDialog.status === Component.Ready) {
                errorDialog = componentDialog.createObject(pageSSHServer,
                                                           {mainWidth: pageSSHServer.width, mainHeight: pageSSHServer.height, bDark: pageSSHServer.bDark,
                                                            messageTitle: qsTr("Read Error"),
                                                            messageText: qsTr("Failed to read sshd_config file.") + "<br>" + errMsg});
                errorDialogConnection.target = errorDialog
                errorDialog.show();
            }

            return -1
        }
        else if (iRet === 1) {
            // When password authentication is canceled for a file that requires admin privileges.

            // Disable read flag.
            pageSSHServer.bReadSuccess = false

            // Delete the contents of TextEdit.
            textSSHFilePath.readFilePath = ""

            textSSHFilePath.text = strFilePath

            // Enable "Reload" button, but disable "Write" buttons,
            // change the buttons text from the ssh(d).service file permissions.
            btnReload.enabled = true
            btnWrite.enabled  = false
            btnReload.text = qsTr("Read/Reload") + "\n" + qsTr("(Req: Auth)")
            btnWrite.text  = stackLayout.currentIndex !== 4 ?
                             qsTr("Write") + "\n" + qsTr("(Req: Auth)") : qsTr("Write(editor)") + "\n" + qsTr("(Req: Auth)")

            return 1
        }
        else {
            // If the file successed to load.

            // Enable read flag.
            pageSSHServer.bReadSuccess = true

            // Save the selected ssh(d).service file to ini file.
            sshServerConfig.saveSSHFilePath(strFilePath)

            textSSHFilePath.text = strFilePath

            textSSHFilePath.readFilePath = strFilePath

            // Change the buttons text from the ssh(d).service file permissions.
            if (sshServerConfig.getFileReadPermissions(strFilePath) === 0) {
                btnReload.text = qsTr("Read/Reload")
                btnWrite.text  = stackLayout.currentIndex !== 4 ? qsTr("Write") : qsTr("Write(editor)")
            }
            else {
                btnReload.text = qsTr("Read/Reload") + "\n" + qsTr("(Req: Auth)")
                btnWrite.text  = stackLayout.currentIndex !== 4 ?
                                 qsTr("Write") + "\n" + qsTr("(Req: Auth)") : qsTr("Write(editor)") + "\n" + qsTr("(Req: Auth)")
            }

            // Enable buttons.
            btnReload.enabled = true
            btnWrite.enabled  = true

            // Diplay success popup.
            completePopup.viewTitle = qsTr("Read \"sshd_config\" file")
            completePopup.fontPadding = pageSSHServer.fontPadding
            completePopup.bAutolose = false
            completePopup.open()

            // If there are duplicate non-duplicate items.
            if (iRet === 2) {
                // Display warning message.
                let warningMsg = sshServerConfig.getErrorMessage()

                componentDialog = Qt.createComponent("qrc:/ExtendQML/WarningDialogPP.qml");
                if (componentDialog.status === Component.Ready) {
                    let warningDialog = componentDialog.createObject(pageSSHServer,
                                                                {viewWidth: pageSSHServer.width, viewHeight: pageSSHServer.height, bDark: pageSSHServer.bDark,
                                                                 fontPadding: pageSSHServer.fontPadding,
                                                                 messageTitle: qsTr("Warning"),
                                                                 messageText: qsTr("There are duplicate values in the non-duplicable items.") + "<br>" + warningMsg});
                    warningDialog.show();
                }
            }

            // Set item value to UI.
            let jsonFile = sshServerConfig.getJsonFilePath()
            if (sshValue.readFromJson(jsonFile)) {
                return -1
            }

            // Clear all contents.
            tabViewGeneral.clear()
            tabViewAuthentication.clear()
            tabViewKerberos.clear()
            tabViewOther.clear()
            tabViewEditor.clear()

            // Set all contents.
            tabViewGeneral.readSuccess()
            tabViewAuthentication.readSuccess()
            tabViewKerberos.readSuccess()
            tabViewOther.readSuccess()
            tabViewEditor.readSuccess()
        }

        return 0
    }

    function fnReadSSHFileFromServer(remoteFilePath: string, strContents: string) {
        let errMsg = ""
        let componentDialog = null
        let errorDialog     = null

        // Read sshd_config file.
        let iRet = sshServerConfig.readSSHFileFromServer(strContents)
        if (iRet === -1) {
            // If fail to load file.

            // Disable read flag.
            pageSSHServer.bReadSuccess = false

            // Delete the contents of TextEdit.
            textSSHFilePath.readFilePath = ""

            // Display error message.
            errMsg = sshServerConfig.getErrorMessage()

            componentDialog = Qt.createComponent("qrc:/ExtendQML/ErrorDialogPP.qml");
            if (componentDialog.status === Component.Ready) {
                errorDialog = componentDialog.createObject(pageSSHServer,
                                                           {mainWidth: pageSSHServer.width, mainHeight: pageSSHServer.height, bDark: pageSSHServer.bDark,
                                                            messageTitle: qsTr("Read Error"),
                                                            messageText: qsTr("Failed to read sshd_config file.") + "<br>" + errMsg});
                errorDialogConnection.target = errorDialog
                errorDialog.show();
            }
        }
        else {
            // If the file successed to load.

            // Enable read flag.
            pageSSHServer.bReadSuccess = true

            // Save the selected ssh(d).service file to ini file.
            //let strFilePath = sshServerConfig.getTmpFilePath()
            //sshServerConfig.saveSSHFilePath(strFilePath)

            // Set file path for UI.
            pageSSHServer.remoteFileName = remoteFilePath

            // Set path to sshd_config to UI on remote server.
            textSSHFilePath.text = "Remote:/" + remoteFilePath

            textSSHFilePath.readFilePath = remoteFilePath

            // Change the buttons text from the ssh(d).service file permissions.
            let strFilePath = sshServerConfig.getTmpFilePath()
            if (sshServerConfig.getFileReadPermissions(strFilePath) === 0) {
                btnReload.text = qsTr("Read/Reload")
                btnWrite.text  = qsTr("Write")
            }
            else {
                btnReload.text = qsTr("Read/Reload") + "\n" + qsTr("(Req: Auth)")
                btnWrite.text  = qsTr("Write") + "\n" + qsTr("(Req: Auth)")
            }

            // Enable buttons.
            btnReload.enabled = true
            btnWrite.enabled  = true

            // Diplay success popup.
            completePopup.viewTitle = qsTr("Read \"sshd_config\" file")
            completePopup.fontPadding = pageSSHServer.fontPadding
            completePopup.bAutolose = false
            completePopup.open()

            // If there are duplicate non-duplicate items.
            if (iRet === 2) {
                // Display warning message.
                let warningMsg = sshServerConfig.getErrorMessage()

                componentDialog = Qt.createComponent("qrc:/ExtendQML/WarningDialogPP.qml");
                if (componentDialog.status === Component.Ready) {
                    let warningDialog = componentDialog.createObject(pageSSHServer,
                                                                {viewWidth: pageSSHServer.width, viewHeight: pageSSHServer.height, bDark: pageSSHServer.bDark,
                                                                 fontPadding: pageSSHServer.fontPadding,
                                                                 messageTitle: qsTr("Warning"),
                                                                 messageText: qsTr("There are duplicate values in the non-duplicable items.") + "<br>" + warningMsg});
                    warningDialog.show();
                }
            }

            // Set item value to UI.
            let jsonFile = sshServerConfig.getJsonFilePath()
            if (sshValue.readFromJson(jsonFile)) {
                return -1
            }

            // Clear all contents.
            tabViewGeneral.clear()
            tabViewAuthentication.clear()
            tabViewKerberos.clear()
            tabViewOther.clear()
            tabViewEditor.clear()

            // Set all contents.
            tabViewGeneral.readSuccess()
            tabViewAuthentication.readSuccess()
            tabViewKerberos.readSuccess()
            tabViewOther.readSuccess()
            tabViewEditor.readSuccess()
        }
    }

    function fnWriteSSHFile() {
        let errMsg = ""
        let componentDialog = null
        let errorDialog     = null

        // Set all contents.
        tabViewGeneral.writeSuccess()
        tabViewAuthentication.writeSuccess()
        tabViewKerberos.writeSuccess()
        tabViewOther.writeSuccess()

        // Write to Json file.
        let JsonFile = sshServerConfig.getJsonFilePath()
        let iRet = sshValue.writeToJson(JsonFile)
        if (iRet === -1) {
            // If fail to write Json file.
            // Display error message.
            errMsg = sshValue.getErrorMessage()

            componentDialog = Qt.createComponent("qrc:/ExtendQML/ErrorDialogPP.qml");
            if (componentDialog.status === Component.Ready) {
                errorDialog = componentDialog.createObject(pageSSHServer,
                                                           {mainWidth: pageSSHServer.width, mainHeight: pageSSHServer.height, bDark: pageSSHServer.bDark,
                                                            messageTitle: qsTr("Write Error"),
                                                            messageText: qsTr("Failed to write temporary Json file.") + "<br>" + errMsg});
                errorDialogConnection.target = errorDialog
                errorDialog.show();
            }

            return -1
        }

        // Write and convert from Json file to temporary sshd_config file.
        iRet = sshServerConfig.writeToSSHFile()
        if (iRet === -1) {
            // If fail to write Json file.
            // Display error message.
            errMsg = sshServerConfig.getErrorMessage()

            componentDialog = Qt.createComponent("qrc:/ExtendQML/ErrorDialogPP.qml");
            if (componentDialog.status === Component.Ready) {
                errorDialog = componentDialog.createObject(pageSSHServer,
                                                           {mainWidth: pageSSHServer.width, mainHeight: pageSSHServer.height, bDark: pageSSHServer.bDark,
                                                            messageTitle: qsTr("Write Error"),
                                                            messageText: qsTr("Failed to write temporary Json file.") + "<br>" + errMsg});
                errorDialogConnection.target = errorDialog
                errorDialog.show();
            }

            return -1
        }

        // Copy and backup sshd_config file.
        let bCanceled = false
        if (pageSSHServer.bServerMode) {
            // Server mode.
            iRet = sshServerConfig.copySSHFile(textSSHFilePath.readFilePath)
            if (iRet === -1) {
                // If fail to copy sshd_config file.
                // Display error message.
                errMsg = sshServerConfig.getErrorMessage()

                componentDialog = Qt.createComponent("qrc:/ExtendQML/ErrorDialogPP.qml");
                if (componentDialog.status === Component.Ready) {
                    errorDialog = componentDialog.createObject(pageSSHServer,
                                                               {mainWidth: pageSSHServer.width, mainHeight: pageSSHServer.height, bDark: pageSSHServer.bDark,
                                                                messageTitle: qsTr("Copy Error"),
                                                                messageText: qsTr("Failed to copy sshd_config file.") + "<br>" + errMsg});
                    //errorDialogConnection.target = errorDialog
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
            iRet = sshServerConfig.uploadSSHConfigFile(pageSSHServer.remoteFileName)
            if (iRet === -1) {
                // If fail to upload sshd_config file.
                // Display error message.
                errMsg = sshServerConfig.getErrorMessage()

                componentDialog = Qt.createComponent("qrc:/ExtendQML/ErrorDialogPP.qml");
                if (componentDialog.status === Component.Ready) {
                    errorDialog = componentDialog.createObject(pageSSHServer,
                                                               {mainWidth: pageSSHServer.width, mainHeight: pageSSHServer.height, bDark: pageSSHServer.bDark,
                                                                messageTitle: qsTr("Upload Error"),
                                                                messageText: qsTr("Failed to upload sshd_config file.") + "<br>" + errMsg});
                    errorDialog.show();
                }

                return -1
            }
        }

        // Reload updated sshd_config.
        let tmpSSHFile = sshServerConfig.getTmpFilePath()
        iRet = sshServerConfig.readSSHFile(tmpSSHFile)
        if (iRet === -1) {
            // If fail to reload sshd_config file.

            // Display error message.
            errMsg = sshServerConfig.getErrorMessage()

            componentDialog = Qt.createComponent("qrc:/ExtendQML/ErrorDialogPP.qml");
            if (componentDialog.status === Component.Ready) {
                errorDialog = componentDialog.createObject(pageSSHServer,
                                                           {mainWidth: pageSSHServer.width, mainHeight: pageSSHServer.height, bDark: pageSSHServer.bDark,
                                                            messageTitle: qsTr("Reload Error"),
                                                            messageText: qsTr("Failed to reload sshd_config file.") + "<br>" + errMsg});
                errorDialogConnection.target = errorDialog
                errorDialog.show();
            }

            return -1
        }

        // Reload updated Json file.
        let jsonFile = sshServerConfig.getJsonFilePath()
        if (sshValue.readFromJson(jsonFile)) {
            // If fail to reload Json file.

            // Display error message.
            errMsg = sshServerConfig.getErrorMessage()

            componentDialog = Qt.createComponent("qrc:/ExtendQML/ErrorDialogPP.qml");
            if (componentDialog.status === Component.Ready) {
                errorDialog = componentDialog.createObject(pageSSHServer,
                                                           {mainWidth: pageSSHServer.width, mainHeight: pageSSHServer.height, bDark: pageSSHServer.bDark,
                                                            messageTitle: qsTr("Reload Error"),
                                                            messageText: qsTr("Failed to reload Json file.") + "<br>" + errMsg});
                errorDialogConnection.target = errorDialog
                errorDialog.show();
            }
            return -1
        }

        // Diplay success popup.
        if (pageSSHServer.bServerMode && bCanceled === false) {
            completePopup.viewTitle   = qsTr("Write \"sshd_config\" file")
            completePopup.fontPadding = pageSSHServer.fontPadding
            completePopup.bAutolose   = false
            completePopup.open()
        }

        return 0
    }

    header: Column {
        id: headerSSHServer
        width: parent.width
        spacing: 5

        anchors.top: parent.top
        anchors.topMargin: 15

        TabBar {
            id: mainBar
            width: parent.width

            clip: true
            currentIndex: 0

            TabButton {
                id: tabGeneral
                text: qsTr("General")
                width: Math.max(250, mainBar.width / mainBar.count)

                font.pointSize: 12 + pageSSHServer.fontPadding

                Rectangle {
                    id: bgGeneral
                    width: labelGeneral.width
                    height: mainBar.currentItem.height
                    color: "transparent"
                    border.color: pageSSHServer.bDark ? "white" : "black"
                    border.width: pageSSHServer.bDark ? 0 : 2
                    opacity: 0.3

                    anchors.left: labelGeneral.left
                    anchors.right: labelGeneral.right
                }

                contentItem: Label {
                    id: labelGeneral
                    text: parent.text
                    font: parent.font
                    color: pageSSHServer.bDark ? stackLayout.currentIndex === 0 ? Material.color(Material.Blue, Material.Shade200) : "white" :
                           stackLayout.currentIndex === 0 ? "#0000f0" : "black"

                    horizontalAlignment: Label.AlignHCenter
                    verticalAlignment: Label.AlignVCenter
                    elide: Label.ElideRight
                }

                Rectangle {
                    id: bgSelectGeneral
                    width: mainBar.currentItem.width
                    height: mainBar.currentItem.height
                    color: pageSSHServer.bDark ? "transparent" : mouseHover.hovered ? "#808080" : "transparent"

                    opacity: 0.5

                    anchors.left: labelGeneral.left
                    anchors.right: labelGeneral.right
                    HoverHandler {
                        id: mouseHover
                        acceptedDevices: PointerDevice.Mouse
                    }
                }

                Rectangle {
                    id: barGeneral
                    y: mainBar.height - height
                    width: labelGeneral.width
                    height: pageSSHServer.bDark ? 0 : stackLayout.currentIndex === 0 ? 5 : 0
                    color: "#0000f0"

                    anchors.left: labelGeneral.left
                    radius: 10
                    opacity: 0.5

                    NumberAnimation {
                        id: generalWidthChange
                        target: barGeneral;
                        property: "width";
                        from: 0;
                        to: labelGeneral.width
                        duration: 350;
                    }
                }

                Connections {
                    target: tabGeneral
                    function onPressed() {
                        generalWidthChange.start()
                    }
                }
            }

            TabButton {
                id: tabAuthentication
                text: qsTr("Authentication")
                width: Math.max(250, mainBar.width / mainBar.count)

                font.pointSize: 12 + pageSSHServer.fontPadding

                Rectangle {
                    id: bgAuthentication
                    width: labelAuthentication.width
                    height: mainBar.currentItem.height
                    color: "transparent"
                    border.color: pageSSHServer.bDark ? "white" : "black"
                    border.width: pageSSHServer.bDark ? 0 : 2
                    opacity: 0.3

                    anchors.left: labelAuthentication.left
                    anchors.right: labelAuthentication.right
                }

                contentItem: Label {
                    id: labelAuthentication
                    text: parent.text
                    font: parent.font
                    color: pageSSHServer.bDark ? stackLayout.currentIndex === 1 ? Material.color(Material.Blue, Material.Shade200) : "white" :
                           stackLayout.currentIndex === 1 ? "#0000f0" : "black"

                    horizontalAlignment: Label.AlignHCenter
                    verticalAlignment: Label.AlignVCenter
                    elide: Label.ElideRight
                }

                Rectangle {
                    id: bgSelectAuthentication
                    width: mainBar.currentItem.width
                    height: mainBar.currentItem.height
                    color: pageSSHServer.bDark ? "transparent" : mouseHoverAuthentication.hovered ? "#808080" : "transparent"

                    opacity: 0.5

                    anchors.left: labelAuthentication.left
                    anchors.right: labelAuthentication.right

                    HoverHandler {
                        id: mouseHoverAuthentication
                        acceptedDevices: PointerDevice.Mouse
                    }
                }

                Rectangle {
                    id: barAuthentication
                    y: mainBar.height - height
                    width: labelAuthentication.width
                    height: pageSSHServer.bDark ? 0 : stackLayout.currentIndex === 1 ? 5 : 0
                    color: "#0000f0"
                    radius: 10
                    opacity: 0.5

                    anchors.left: labelAuthentication.left

                    NumberAnimation {
                        id: authWidthChange
                        target: barAuthentication;
                        property: "width";
                        from: 0;
                        to: labelAuthentication.width
                        duration: 350;
                    }
                }

                Connections {
                    target: tabAuthentication
                    function onPressed() {
                        authWidthChange.start()
                    }
                }
            }

            TabButton {
                id: tabKerberos
                text: qsTr("Kerberos")
                width: Math.max(250, mainBar.width / mainBar.count)

                font.pointSize: 12 + pageSSHServer.fontPadding

                Rectangle {
                    id: bgKerberos
                    width: labelKerberos.width
                    height: mainBar.currentItem.height
                    color: "transparent"
                    border.color: pageSSHServer.bDark ? "white" : "black"
                    border.width: pageSSHServer.bDark ? 0 : 2
                    opacity: 0.3

                    anchors.left: labelKerberos.left
                    anchors.right: labelKerberos.right
                }

                contentItem: Label {
                    id: labelKerberos
                    text: parent.text
                    font: parent.font
                    color: pageSSHServer.bDark ? stackLayout.currentIndex === 2 ? Material.color(Material.Blue, Material.Shade200) : "white" :
                                               stackLayout.currentIndex === 2 ? "#0000f0" : "black"

                    horizontalAlignment: Label.AlignHCenter
                    verticalAlignment: Label.AlignVCenter
                    elide: Label.ElideRight
                }

                Rectangle {
                    id: bgSelectKerberos
                    width: mainBar.currentItem.width
                    height: mainBar.currentItem.height
                    color: pageSSHServer.bDark ? "transparent" : mouseHoverKerberos.hovered ? "#808080" : "transparent"

                    opacity: 0.5

                    anchors.left: labelKerberos.left
                    anchors.right: labelKerberos.right

                    HoverHandler {
                        id: mouseHoverKerberos
                        acceptedDevices: PointerDevice.Mouse
                    }
                }

                Rectangle {
                    id: barKerberos
                    y: mainBar.height - height
                    width: labelKerberos.width
                    height: pageSSHServer.bDark ? 0 : stackLayout.currentIndex === 2 ? 5 : 0
                    color: "#0000f0"
                    radius: 10
                    opacity: 0.5

                    anchors.left: labelKerberos.left

                    NumberAnimation {
                        id: kerberosWidthChange
                        target: barKerberos;
                        property: "width";
                        from: 0;
                        to: labelKerberos.width
                        duration: 350;
                    }
                }

                Connections {
                    target: tabKerberos
                    function onPressed() {
                        kerberosWidthChange.start()
                    }
                }
            }

            TabButton {
                id: tabOtherSettings
                text: qsTr("Other Settings")
                width: Math.max(250, mainBar.width / mainBar.count)

                font.pointSize: 12 + pageSSHServer.fontPadding

                Rectangle {
                    id: bgOtherSettings
                    width: labelOtherSettings.width
                    height: mainBar.currentItem.height
                    color: "transparent"
                    border.color: pageSSHServer.bDark ? "white" : "black"
                    border.width: pageSSHServer.bDark ? 0 : 2
                    opacity: 0.3

                    anchors.left: labelOtherSettings.left
                    anchors.right: labelOtherSettings.right
                }

                contentItem: Label {
                    id: labelOtherSettings
                    text: parent.text
                    font: parent.font
                    color: pageSSHServer.bDark ? stackLayout.currentIndex === 3 ? Material.color(Material.Blue, Material.Shade200) : "white" :
                                               stackLayout.currentIndex === 3 ? "#0000f0" : "black"

                    horizontalAlignment: Label.AlignHCenter
                    verticalAlignment: Label.AlignVCenter
                    elide: Label.ElideRight
                }

                Rectangle {
                    id: bgSelectOtherSettings
                    width: mainBar.currentItem.width
                    height: mainBar.currentItem.height
                    color: pageSSHServer.bDark ? "transparent" : mouseHoverOtherSettings.hovered ? "#808080" : "transparent"

                    opacity: 0.5

                    anchors.left: labelOtherSettings.left
                    anchors.right: labelOtherSettings.right

                    HoverHandler {
                        id: mouseHoverOtherSettings
                        acceptedDevices: PointerDevice.Mouse
                    }
                }

                Rectangle {
                    id: barOtherSettings
                    y: mainBar.height - height
                    width: labelOtherSettings.width;
                    height: pageSSHServer.bDark ? 0 : stackLayout.currentIndex === 3 ? 5 : 0
                    color: "#0000f0"
                    radius: 10
                    opacity: 0.5

                    anchors.left: labelOtherSettings.left

                    NumberAnimation {
                        id: otherWidthChange
                        target: barOtherSettings
                        property: "width"
                        from: 0
                        to: labelOtherSettings.width
                        duration: 350
                    }
                }

                Connections {
                    target: tabOtherSettings
                    function onPressed() {
                        otherWidthChange.start()
                    }
                }
            }

            TabButton {
                id: tabEditor
                text: qsTr("Editor")
                width: Math.max(250, mainBar.width / mainBar.count)

                font.pointSize: 12 + pageSSHServer.fontPadding

                Rectangle {
                    id: bgEditor
                    width: labelEditor.width
                    height: mainBar.currentItem.height
                    color: "transparent"
                    border.color: pageSSHServer.bDark ? "white" : "black"
                    border.width: pageSSHServer.bDark ? 0 : 2
                    opacity: 0.3

                    anchors.left: labelEditor.left
                    anchors.right: labelEditor.right
                }

                contentItem: Label {
                    id: labelEditor
                    text: parent.text
                    font: parent.font
                    color: pageSSHServer.bDark ? stackLayout.currentIndex === 4 ? Material.color(Material.Blue, Material.Shade200) : "white" :
                                               stackLayout.currentIndex === 4 ? "#0000f0" : "black"

                    horizontalAlignment: Label.AlignHCenter
                    verticalAlignment: Label.AlignVCenter
                    elide: Label.ElideRight
                }

                Rectangle {
                    id: bgselectEditor
                    width: mainBar.currentItem.width
                    height: mainBar.currentItem.height
                    color: pageSSHServer.bDark ? "transparent" : mouseHoverEditor.hovered ? "#808080" : "transparent"

                    opacity: 0.5

                    anchors.left: labelEditor.left
                    anchors.right: labelEditor.right

                    HoverHandler {
                        id: mouseHoverEditor
                        acceptedDevices: PointerDevice.Mouse
                    }
                }

                Rectangle {
                    id: barEditor
                    y: mainBar.height - height
                    width: labelEditor.width;
                    height: pageSSHServer.bDark ? 0 : stackLayout.currentIndex === 4 ? 5 : 0
                    color: "#0000f0"
                    radius: 10
                    opacity: 0.5

                    anchors.left: labelEditor.left

                    NumberAnimation {
                        id: editorWidthChange
                        target: barEditor
                        property: "width"
                        from: 0
                        to: labelEditor.width
                        duration: 350
                    }
                }

                Connections {
                    target: tabEditor
                    function onPressed() {
                        editorWidthChange.start()
                    }
                }
            }
        }

        Rectangle {
            implicitWidth: parent.width - anchors.leftMargin - anchors.rightMargin
            implicitHeight: Math.max(textSSHFilePath.height, btnFileSelect.height, btnReload.height, btnWrite.height)
            color: "transparent"

            Flickable {
                id: flick
                width: parent.width
                height: parent.height
                contentWidth: subHeaderRow.width
                contentHeight: parent.height
                flickableDirection: Flickable.HorizontalFlick
                boundsBehavior: Flickable.StopAtBounds
                clip: true

                ScrollBar {
                    clip: true
                }

                RowLayout {
                    id: subHeaderRow
                    spacing: 10

                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter

                    TextField {
                        id: textSSHFilePath
                        y: (parent.height - height) / 2
                        text: sshServerConfig.getSSHFilePath()
                        width: (pageSSHServer.width - btnFileSelect.width - parent.spacing * 3 - btnFileSelect.width - btnWrite.width - btnReload.width) > 300 ?
                                pageSSHServer.width - btnFileSelect.width - parent.spacing * 3 - btnFileSelect.width - btnWrite.width - btnReload.width : 300
                        implicitWidth: (pageSSHServer.width - btnFileSelect.width - parent.spacing * 3 - btnFileSelect.width - btnWrite.width - btnReload.width) > 300 ?
                                        pageSSHServer.width - btnFileSelect.width - parent.spacing * 3 - btnFileSelect.width - btnWrite.width - btnReload.width : 300
                        enabled: pageSSHServer.bServerMode ? true : false

                        font.pointSize: 10 + pageSSHServer.fontPadding
                        placeholderText: qsTr("Click the right icon, select \"sshd_config\". Ex: /etc/ssh/sshd_config")

                        horizontalAlignment: TextField.AlignLeft
                        verticalAlignment: TextField.AlignVCenter
                        Layout.leftMargin: 20

                        property string readFilePath: ""

                        onAccepted: {
                            if (pageSSHServer.bServerMode) {
                                // Server Mode.

                                // Remove temporary sshd_config file.
                                //sshServerConfig.removeTmpFiles()

                                // Read sshd_config file.
                                pageSSHServer.fnReadSSHFile(textSSHFilePath.text)
                            }
                            else {
                                // Client Mode.
                                sshServerConfig.downloadSSHConfigFile(parentName.width, parentName.height, pageSSHServer.bDark, pageSSHServer.fontPadding)
                            }
                        }
                    }

                    RoundButton {
                        id: btnFileSelect
                        text: ""
                        width: 48
                        height: 48

                        icon.source: pageSSHServer.bServerMode ? pressed ? "qrc:/Image/FileButtonPressed.png" : "qrc:/Image/FileButton.png"
                        : pressed ? "qrc:/Image/FileNetworkButtonPressed.png" : "qrc:/Image/FileNetworkButton.png"
                        icon.width: width
                        icon.height: height
                        icon.color: "transparent"

                        padding: 0

                        background: Rectangle {
                            color: "transparent"
                        }

                        onClicked: {
                            if (pageSSHServer.bServerMode) {
                                selectSSHServerFileDialog.open()
                            }
                            else {
                                sshServerConfig.downloadSSHConfigFile(parentName.width, parentName.height, pageSSHServer.bDark, pageSSHServer.fontPadding)
                            }
                        }

                        SelectFileDialog {
                            id: selectSSHServerFileDialog
                            mainWidth: pageSSHServer.width
                            mainHeight: pageSSHServer.height
                            filters: "SSH Config file (sshd_config*)"

                            onSelectedFile: {
                                // Read sshd_config file.
                                pageSSHServer.fnReadSSHFile(strFilePath)
                            }
                        }
                    }

                    Button {
                        id: btnReload
                        text: qsTr("Read/Reload")
                        font.pointSize: 10 + pageSSHServer.fontPadding
                        enabled: true

                        contentItem: Label {
                            text: btnReload.text
                            font: btnReload.font
                            opacity: enabled ? 1.0 : 0.3

                            horizontalAlignment: Label.AlignHCenter
                            verticalAlignment: Label.AlignVCenter
                            elide: Label.ElideRight
                        }

                        background: Rectangle {
                            implicitWidth: pageSSHServer.fontPadding === 0 ? 140 : pageSSHServer.fontPadding === 3 ? 180 : 100
                            implicitHeight: pageSSHServer.fontPadding === 0 ? 40 : pageSSHServer.fontPadding === 3 ? 50 : 40

                            color: "transparent"
                            opacity: enabled ? 1 : 0.3
                            border.color: btnReload.pressed ? "#10781a" : "#30983a"
                            border.width: btnReload.pressed ? 3 : 2
                            radius: 2
                        }

                        onClicked: {
                            if (pageSSHServer.bServerMode) {
                                // Server Mode.
                                if (textSSHFilePath.readFilePath !== "") {
                                    textSSHFilePath.text = textSSHFilePath.readFilePath
                                    pageSSHServer.fnReadSSHFile(textSSHFilePath.readFilePath)
                                }
                                else {
                                    selectSSHServerFileDialog.open()
                                }
                            }
                            else {
                                // Client Mode.
                                if (pageSSHServer.bReadSuccess) {
                                    sshServerConfig.reloadSSHConfigFile(pageSSHServer.bDark, pageSSHServer.fontPadding, pageSSHServer.remoteFileName)
                                }
                                else {
                                    sshServerConfig.downloadSSHConfigFile(parentName.width, parentName.height, pageSSHServer.bDark, pageSSHServer.fontPadding)
                                }
                            }
                        }
                    }

                    Button {
                        id: btnWrite
                        x: btnFileSelect.x + btnFileSelect.width + spacing
                        text: qsTr("Write")
                        font.pointSize: 10 + pageSSHServer.fontPadding
                        enabled: pageSSHServer.bReadSuccess ? true : false

                        Layout.rightMargin: 20

                        contentItem: Label {
                            text: btnWrite.text
                            font: btnWrite.font
                            opacity: enabled ? 1.0 : 0.3

                            horizontalAlignment: Label.AlignHCenter
                            verticalAlignment: Label.AlignVCenter
                            elide: Label.ElideRight
                        }

                        background: Rectangle {
                            implicitWidth: pageSSHServer.fontPadding === 0 ? 140 : pageSSHServer.fontPadding === 3 ? 180 : 100
                            implicitHeight: pageSSHServer.fontPadding === 0 ? 40 : pageSSHServer.fontPadding === 3 ? 50 : 40
                            color: "transparent"
                            opacity: enabled ? 1 : 0.3
                            border.color: btnWrite.pressed ? "#10781a" : "#30983a"
                            border.width: btnWrite.pressed ? 3 : 2
                            radius: 2
                        }

                        Connections {
                            target: btnWrite
                            function onClicked() {
                                // Write contents.
                                if (stackLayout.currentIndex < 4) {
                                    // Non editor tab.
                                    pageSSHServer.fnWriteSSHFile()
                                }
                                else if (stackLayout.currentIndex === 4) {
                                    // Editor tab.
                                    let iRet = tabViewEditor.fnWriteSSHFile(textSSHFilePath.readFilePath)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    StackLayout {
        id: stackLayout
        x: 20
        y: 15
        width: parent.width - 20
        height: pageSSHServer.height - headerSSHServer.y - headerSSHServer.height - 15

        currentIndex: mainBar.currentIndex

        Component.onCompleted: {
            animationLayout.start()
        }

        onCurrentIndexChanged: {
            animationLayout.start()

            // Set "Write" button text for "Editor" tab.
            if (currentIndex === 4) {
                if (pageSSHServer.bServerMode) {
                    let iRet = sshServerConfig.getFileReadPermissions(textSSHFilePath.text)
                    btnWrite.text = iRet === 0 ? qsTr("Write(editor)") : qsTr("Write(editor)") + "\n" + qsTr("(Req: Auth)")
                }
                else {
                    btnWrite.text = qsTr("Write(editor)")
                }
            }
            else {
                if (pageSSHServer.bServerMode) {
                    let iRet = sshServerConfig.getFileReadPermissions(textSSHFilePath.text)
                    btnWrite.text = iRet === 0 ? qsTr("Write") : qsTr("Write") + "\n" + qsTr("(Req: Auth)")
                }
                else {
                    btnWrite.text = qsTr("Write")
                }
            }
        }

        ParallelAnimation {
            id: animationLayout
            running: true
            NumberAnimation {
                target: stackLayout
                properties: "x"
                from: parent.width / 4 * 3
                to: 20
                duration: 250
                easing.type: Easing.OutQuad
            }
            NumberAnimation {
                target: stackLayout
                properties: "opacity"
                from: 0.0
                to: 1.0
                duration: 300
                easing.type: Easing.InOutQuad
            }
        }

        TabViewGeneralPP {
            id: tabViewGeneral
            viewWidth: parent.width
            viewHeight: parent.height
            fontPadding:  pageSSHServer.fontPadding
            bDark: pageSSHServer.bDark
            bServerMode: pageSSHServer.bServerMode

            bReadSuccess: pageSSHServer.bReadSuccess
            sshServerConfig: pageSSHServer.sshServerConfig
            sshValue: sshValue

            MouseArea {
                id: mouseAreaGeneral
                anchors.fill: parent
                acceptedButtons: Qt.ForwardButton | Qt.BackButton  // Enable "ForwardButton" and "BackButton" on mouse

                // Single click
                onClicked: {
                    if (mouse.button === Qt.ForwardButton) {
                        parentName.screenMoved("", 1)
                    }
                    else if (mouse.button === Qt.BackButton) {
                        parentName.screenMoved("", 0)
                    }
                }
            }
        }

        TabViewAuthenticationPP {
            id: tabViewAuthentication
            viewWidth:    parent.width
            viewHeight:   parent.height
            fontPadding:  pageSSHServer.fontPadding
            bDark:        pageSSHServer.bDark
            bServerMode:  pageSSHServer.bServerMode

            bReadSuccess:    pageSSHServer.bReadSuccess
            sshServerConfig: pageSSHServer.sshServerConfig
            sshValue:        sshValue

            MouseArea {
                id: mouseAreaAuth
                anchors.fill: parent
                acceptedButtons: Qt.ForwardButton | Qt.BackButton  // Enable "ForwardButton" and "BackButton" on mouse

                // Single click
                onClicked: {
                    if (mouse.button === Qt.ForwardButton) {
                        parentName.screenMoved("", 1)
                    }
                    else if (mouse.button === Qt.BackButton) {
                        parentName.screenMoved("", 0)
                    }
                }
            }
        }

        TabViewKerberosPP {
            id: tabViewKerberos
            viewWidth:    parent.width
            viewHeight:   parent.height
            fontPadding:  pageSSHServer.fontPadding
            bDark:        pageSSHServer.bDark

            bReadSuccess: pageSSHServer.bReadSuccess
            sshValue:     sshValue

            MouseArea {
                id: mouseAreaKerberos
                anchors.fill: parent
                acceptedButtons: Qt.ForwardButton | Qt.BackButton  // Enable "ForwardButton" and "BackButton" on mouse

                // Single click
                onClicked: {
                    if (mouse.button === Qt.ForwardButton) {
                        parentName.screenMoved("", 1)
                    }
                    else if (mouse.button === Qt.BackButton) {
                        parentName.screenMoved("", 0)
                    }
                }
            }
        }

        TabViewOtherPP {
            id: tabViewOther
            viewWidth:    parent.width
            viewHeight:   parent.height
            fontPadding:  pageSSHServer.fontPadding
            bDark:        pageSSHServer.bDark

            bReadSuccess:    pageSSHServer.bReadSuccess
            bServerMode:     pageSSHServer.bServerMode
            sshServerConfig: pageSSHServer.sshServerConfig
            sshValue:        sshValue

            MouseArea {
                id: mouseAreaOther
                anchors.fill: parent
                acceptedButtons: Qt.ForwardButton | Qt.BackButton  // Enable "ForwardButton" and "BackButton" on mouse

                // Single click
                onClicked: {
                    if (mouse.button === Qt.ForwardButton) {
                        parentName.screenMoved("", 1)
                    }
                    else if (mouse.button === Qt.BackButton) {
                        parentName.screenMoved("", 0)
                    }
                }
            }
        }

        TabViewEditorPP {
            id: tabViewEditor
            viewWidth:    parent.width
            viewHeight:   parent.height
            fontPadding:  pageSSHServer.fontPadding
            bDark:        pageSSHServer.bDark
            bServerMode:  pageSSHServer.bServerMode

            bReadSuccess: pageSSHServer.bReadSuccess
            sshServer:    sshServerConfig
            sshValue:     sshValue

            MouseArea {
                id: mouseAreaEditor
                anchors.fill: parent
                acceptedButtons: Qt.ForwardButton | Qt.BackButton  // Enable "ForwardButton" and "BackButton" on mouse

                // Single click
                onClicked: {
                    if (mouse.button === Qt.ForwardButton) {
                        parentName.screenMoved("", 1)
                    }
                    else if (mouse.button === Qt.BackButton) {
                        parentName.screenMoved("", 0)
                    }
                }
            }
        }
    }

    CompletePopup {
        id: completePopup

        viewTitle: ""
        positionY: 0
        viewWidth: pageSSHServer.width
        fontPadding: 0
        parentName: pageSSHServer.parentName
    }
}
