import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Controls.Universal 2.15
import ClientSession 1.0
import "ExtendQML"


Item {
    id: select
    visible: true

    property var    parentName:     null
    property int    viewWidth:      1024
    property int    viewHeight:     800
    property bool   bDark:          false
    property int    fontPadding:    0
    property int    fileMode:       0  // 0 : Download sshd_config file.
                                       // 1 : Get path to key file.
    property int    keyType:        0  // 0 : Host Key.
                                       // 1 : Authorized Key.
    property string hostName:       ""
    property string port:           ""
    property bool   bUseSSL:        false
    property bool   bUseCert:       false
    property string certFile:       ""
    property bool   bUsePrivateKey: false
    property string privateKeyFile: ""
    property bool   bUsePassphrase: false
    property string passphrase:     ""

    property var    remote:         remoteClient

    CClient {
        id: remoteClient;
    }

    Component.onCompleted: {
        // Make remote connection
        listModel.clear()
        listViewSearch.update()

        btnUpDirectory.enabled = false
        btnUpDirectory.opacity = 0.2

        let errMsg          = ""
        let componentDialog = null
        let errorDialog     = null

        // Connect remote server.
        let bConnect = remoteClient.connectToServer(select.hostName,       select.port,           select.bUseSSL,        select.bUseCert,   select.certFile,
                                                    select.bUsePrivateKey, select.privateKeyFile, select.bUsePassphrase, select.passphrase, select.fileMode)

        if (bConnect === false) {
            errMsg = remoteClient.getErrorMessage()

            componentDialog = Qt.createComponent("qrc:/ExtendQML/ErrorDialog.qml");
            if (componentDialog.status === Component.Ready) {
                errorDialog = componentDialog.createObject(select,
                                                           {bDark: select.bDark, fontPadding: select.fontPadding,
                                                            messageTitle: qsTr("Error"),
                                                            messageText: qsTr("Connection failed.") + "<br>" + errMsg});
                errorDialog.show();
            }

            btnselect.enabled = false
        }
        else {
            // Get initial direcotry.
            let directory = remoteClient.getCurrentDirectory()

            let iConnect = 0
            if (select.fileMode === 0) {
                let command = "dir " + directory
                iConnect    = remoteClient.writeToServer(command, 0)
            }
            else {
                let command = "key " + directory
                iConnect    = remoteClient.writeToServer(command, 3)
            }

            if (iConnect !== 0) {
                errMsg = remoteClient.getErrorMessage()

                componentDialog = Qt.createComponent("qrc:/ExtendQML/ErrorDialog.qml");
                if (componentDialog.status === Component.Ready) {
                    errorDialog = componentDialog.createObject(select,
                                                               {bDark: select.bDark, fontPadding: select.fontPadding,
                                                                messageTitle: qsTr("Error"),
                                                                messageText: qsTr("Connection failed.") + "<br>" + errMsg});
                    errorDialog.show();
                }

                btnselect.enabled = false
            }
        }
    }

    Connections {
        target: remoteClient
        function onServerConnected() {
            completePopup.viewTitle = qsTr("Connection succeeded")
            completePopup.fontPadding = select.fontPadding
            completePopup.bAutoClose = false
            completePopup.open()
        }
    }

    Connections {
        target: remoteClient
        function onReadDirectory() {
            labelPath.text = remoteClient.getCurrentDirectory()
            btnselect.enabled = true

            // Clear the list
            listModel.clear()

            let directories = remoteClient.directories();
            for (let i = 0; i < directories.length; i++) {
                listModel.append({"file" : 1, "name": directories[i]});
            }

            let files = remoteClient.files();
            for (let j = 0; j < files.length; j++) {
                listModel.append({"file" : 0, "name": files[j]});
            }
        }
    }

    Connections {
        target: remoteClient
        function onReadSSHFile(contents: string) {
            parentName.downloadSSHFile(remoteClient.getCurrentDirectory() + "/" + listModel.get(listViewSearch.currentIndex).name, contents)
            parentName.close()
        }
    }

    Connections {
        target: remoteClient
        function onReadError(errorMessage: string) {
            let componentDialog = Qt.createComponent("qrc:/ExtendQML/ErrorDialog.qml");
            if (componentDialog.status === Component.Ready) {
                let errorDialog = componentDialog.createObject(select,
                                                           {bDark: select.bDark, fontPadding: select.fontPadding,
                                                            messageTitle: qsTr("Error"),
                                                            messageText: qsTr("Error on reception or invalid command.") + "<br>" + errorMessage});
                errorDialog.show();
            }
        }
    }

//    Connections {
//        target: remoteClient
//        function onShowRemotePassDialog() {
//            let componentDialog = Qt.createComponent("qrc:/ExtendQML/PasswordDialog.qml")
//            if (componentDialog.status === Component.Ready) {
//                let passwordDialog = componentDialog.createObject(select,
//                                                                  {bDark: select.bDark, fontPadding: select.fontPadding,
//                                                                   messageTitle: "", messageText: ""});
//                passwordDialogConnection.target = passwordDialog
//                passwordDialog.show();
//            }
//        }
//    }

    Connections {
        id: passwordDialogConnection
        function onVisibleChanged() {
            if(!target.visible) {
                if (target.returnValue === 0) {
                    remoteClient.setRemoteHostPass(target.password)
                    let iRet = remoteClient.selectFileAdmin(listModel.get(listViewSearch.currentIndex).name)

                    let componentDialog = null
                    let errorDialog     = null
                    if (iRet === 0) {
                        // Success download.
//                        completePopup.viewTitle = qsTr("\"sshd_config\" file has been selected")
//                        completePopup.fontPadding = select.fontPadding
//                        completePopup.bAutoClose = true
//                        completePopup.open()
                    }
                    else if (iRet === 1) {
                        // Incorrect password or empty sshd_config file.
                        componentDialog = Qt.createComponent("qrc:/ExtendQML/ErrorDialog.qml");
                        if (componentDialog.status === Component.Ready) {
                            errorDialog = componentDialog.createObject(select,
                                                                       {bDark: select.bDark, fontPadding: select.fontPadding,
                                                                        messageTitle: qsTr("Warning"),
                                                                        messageText: qsTr("Incorrect administrator password or empty \"sshd_config\" file.")});
                            errorDialog.show();
                        }
                    }
                    else {
                        // Download error.
                        let errMsg = remoteClient.getErrorMessage()

                        componentDialog = Qt.createComponent("qrc:/ExtendQML/ErrorDialog.qml");
                        if (componentDialog.status === Component.Ready) {
                            errorDialog = componentDialog.createObject(select,
                                                                       {bDark: select.bDark, fontPadding: select.fontPadding,
                                                                        messageTitle: qsTr("Error"),
                                                                        messageText: qsTr("Download of \"sshd_config\" file failed.") + "<br>" + errMsg});
                            errorDialog.show();
                        }
                    }
                }

                target = null
            }
        }
    }

    Connections {
        target: remoteClient
        function onFiles(files) {
            for (let i = 0; i < files.length; i++) {
                listModel.append({"file" : 0, "name": files[i]});
            }
        }
    }

    // Select sshd_config file.
    function fnSSHDConfigSelect() {
        let iRet = 0
        if (listModel.get(listViewSearch.currentIndex).file === 0) {
            // You selected file.
            // Download sshd.service file from remote server.
            let command = "pull " + remoteClient.getCurrentDirectory() + "/" + listModel.get(listViewSearch.currentIndex).name
            iRet = remoteClient.writeToServer(command, 1)

            if (iRet === 0) {
                // Success download.
//                completePopup.viewTitle = qsTr("\"sshd_config\" file has been selected")
//                completePopup.fontPadding = select.fontPadding
//                completePopup.bAutoClose = true
//                completePopup.open()
            }
            else if (iRet === 1) {
                // If do not have read permission.
            }
            else {
                // Download error.
                let errMsg = remoteClient.getErrorMessage()

                let componentDialog = Qt.createComponent("qrc:/ExtendQML/ErrorDialog.qml");
                if (componentDialog.status === Component.Ready) {
                    let errorDialog = componentDialog.createObject(select,
                                                                   {bDark: select.bDark, fontPadding: select.fontPadding,
                                                                    messageTitle: qsTr("Error"),
                                                                    messageText: qsTr("Could not download \"sshd_config\" file.") + "<br>" + errMsg});
                    errorDialog.show();
                }
            }
        }
        else {
            // You selected directory.
            // Change directory to selected directory.
            remoteClient.setCurrentDirectory(listModel.get(listViewSearch.currentIndex).name)
            let nextDirectory = remoteClient.getCurrentDirectory()

            // Send command to remote server.
            let command = "dir " + nextDirectory
            iRet = remoteClient.writeToServer(command, 0)

            // Clear the list
            listModel.clear()

            if (iRet === 0) {
                // If the directory move is successful.
                labelPath.text = nextDirectory
            }
            else if (iRet === 1) {
                // If the current directory is the root directory, no operation.
            }
            else {
                // If the directory move fails.
                btnselect.enabled = false

                // Display error message.
                errMsg = remoteClient.getErrorMessage()

                componentDialog = Qt.createComponent("qrc:/ExtendQML/ErrorDialog.qml");
                if (componentDialog.status === Component.Ready) {
                    let errorDialog = componentDialog.createObject(select,
                                                                   {bDark: select.bDark, fontPadding: select.fontPadding,
                                                                    messageTitle: qsTr("Error"),
                                                                    messageText: qsTr("Failed to move directory on remote server.") + "<br>" + errMsg});
                    errorDialog.show();
                }
            }

            // Disable [go back one level up] button.
            if (remoteClient.getCurrentDirectory() === "/") {
                btnUpDirectory.enabled = false
                btnUpDirectory.opacity = 0.2
            }
            else {
                btnUpDirectory.enabled = true
                btnUpDirectory.opacity = 1.0
            }
        }
    }

    // Select key file.
    function fnKeyFileSelect() {
        let iRet = 0
        if (listModel.get(listViewSearch.currentIndex).file === 0) {
            // Selected key file.
            // Get path to key file.
            if (select.keyType === 0) {
                // Host key.
                parentName.getHostKey(remoteClient.getCurrentDirectory() + "/" + listModel.get(listViewSearch.currentIndex).name)
            }
            else if (select.keyType === 1) {
                // Authorized key.
                parentName.getAuthorizedKey(remoteClient.getCurrentDirectory() + "/" + listModel.get(listViewSearch.currentIndex).name)
            }

            parentName.close()

//            completePopup.viewTitle = qsTr("Key file has been selected")
//            completePopup.fontPadding = select.fontPadding
//            completePopup.bAutoClose = true
//            completePopup.open()
        }
        else {
            // You selected directory.
            // Change directory to selected directory.
            remoteClient.setCurrentDirectory(listModel.get(listViewSearch.currentIndex).name)
            let nextDirectory = remoteClient.getCurrentDirectory()

            // Send command to remote server.
            let command = "key " + nextDirectory
            iRet = remoteClient.writeToServer(command, 3)

            // Clear the list
            listModel.clear()

            if (iRet === 0) {
                // If the directory move is successful.
                labelPath.text = nextDirectory
            }
            else if (iRet === 1) {
                // If the current directory is the root directory, no operation.
            }
            else {
                // If the directory move fails.
                btnselect.enabled = false

                // Display error message.
                let errMsg = remoteClient.getErrorMessage()

                componentDialog = Qt.createComponent("qrc:/ExtendQML/ErrorDialog.qml");
                if (componentDialog.status === Component.Ready) {
                    let errorDialog = componentDialog.createObject(select,
                                                                   {bDark: select.bDark, fontPadding: select.fontPadding,
                                                                    messageTitle: qsTr("Error"),
                                                                    messageText: qsTr("Failed to move directory on remote server.") + "<br>" + errMsg});
                    errorDialog.show();
                }
            }

            // Disable [go back one level up] button.
            if (remoteClient.getCurrentDirectory() === "/") {
                btnUpDirectory.enabled = false
                btnUpDirectory.opacity = 0.2
            }
            else {
                btnUpDirectory.enabled = true
                btnUpDirectory.opacity = 1.0
            }
        }
    }

    CompletePopup {
        id: completePopup

        viewTitle: ""
        positionY: 0
        viewWidth: select.width
        fontPadding: 0
        parentName: select.parentName
    }

    // SFTPwindow UI Control
    property int itemHeight: 0

    Item {
        id: keyDelegatItem
        focus: true
        Keys.onUpPressed: {
            if (listViewSearch.currentIndex !== 0) {
                listViewSearch.currentIndex -= 1
            }
        }

        Keys.onDownPressed: {
            if (listViewSearch.currentIndex !== (listViewSearch.count - 1)) {
                listViewSearch.currentIndex += 1
            }
        }

        Keys.onEnterPressed : {
            btnselect.clicked()
        }

        Keys.onReturnPressed: {
            btnselect.clicked()
        }
    }

    RowLayout {
        id: pathRow
        width: parent.width

        anchors.top: parent.top
        anchors.topMargin: 20
        anchors.left: parent.left
        anchors.leftMargin: 20
        anchors.right: parent.right
        anchors.rightMargin: 20

        spacing: 0

        Image {
            id: pathIcon
            source: "Image/Directory.png"
            fillMode: Image.Stretch

            Layout.alignment: Qt.AlignLeft
            Layout.rightMargin: 10
        }

        Label {
            id: labelPath
            text: ""
            font.pointSize: 12 + select.fontPadding
            //color: bDark ? "#ffffff" : "#000000"

            //textFormat: Label.RichText
            wrapMode: Label.WordWrap

            verticalAlignment: Label.AlignVCenter
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }

    // Select File List
    Frame {
        id: frameList
        width: parent.width - anchors.left - anchors.right
        height: Math.round(parent.height / 4 * 3)

        anchors.top: pathRow.bottom
        anchors.topMargin: 20
        anchors.left: parent.left
        anchors.leftMargin: 20
        anchors.right: parent.right
        anchors.rightMargin: 20

        Component {
            id: highlightBar
            Rectangle {
                y: listViewSearch.count === 0 ? 0.0 : listViewSearch.currentItem == null ? 0.0 : listViewSearch.currentItem.y
                width: frameList.width - scrollVBar.width
                height: select.itemHeight
                color: "#0080f0";
                radius: 5
                enabled: false //listViewSearch.count === 0 ? false : true

                Behavior on y {
                    SpringAnimation {
                        spring: 20
                        damping: 3.0
                    }
                }
            }
        }

        ListView {
            id: listViewSearch
            implicitWidth: parent.width
            implicitHeight: parent.height

            focus: true
            clip: true

            currentIndex: -1

            highlight: highlightBar
            highlightFollowsCurrentItem: false

            model: ListModel {
                id: listModel
            }

            onCountChanged: {
               listViewSearch.currentIndex = -1
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.BackButton  // Enable "BackButton" on mouse

                // Single click
                onClicked: {
                    if (mouse.button === Qt.BackButton) {
                        keyDelegatItem.focus = true

                        // Go to the directory one level above.
                        btnUpDirectory.clicked()
                    }
                }
            }

            // Layout for each record in the List
            delegate: Rectangle {
                id: listItem
                width: frameList.width
                height: itemLayout.height
                color: "transparent"

                property int indexOfThisDelegate: index
                property bool bFocus: false

                RowLayout {
                    id: itemLayout
                    width: parent.width
                    Layout.fillWidth: true

                    Image {
                        id: iconType
                        source: model.file === 0 ? "Image/File.png" : "Image/Directory.png"
                        width: 48
                        height: 48
                        fillMode: Image.Stretch
                        Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                        Layout.leftMargin: 5
                    }

                    Label {
                        id: labelName
                        text: model.name
                        width: parent.width - 20

                        font.italic: true
                        font.pointSize: 14 + select.fontPadding
                        //color: bDark ? "#ffffff" : "#000000"

                        wrapMode: Label.WordWrap
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.alignment: Qt.AlignVCenter
                    }
                }

                MouseArea {
                    id: delegateMouseArea
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton  // Enable "LeftButton" on mouse

                    // Single click
                    onClicked: {
                        if (mouse.button === Qt.LeftButton)
                        {   // Left Clicked
//                            listViewSearch.forceActiveFocus();

//                            if (Number(indexOfThisDelegate) !== Number(listViewSearch.currentIndex)) {
//                                console.log(listViewSearch.count)
//                                console.log(listViewSearch.currentIndex)

//                                listViewSearch.itemAtIndex(listViewSearch.currentIndex).color = "transparent";
//                                listViewSearch.itemAtIndex(indexOfThisDelegate).color = "#0080f0"
//                                listItem.bFocus = true
//                            }
//                            else {
//                                // if you select the same item last time (Then, Don't work onCurrentItemChanged handler
//                                if (listItem.bFocus) {
//                                    listViewSearch.itemAtIndex(listViewSearch.currentIndex).color = "transparent";
//                                    listItem.bFocus = false
//                                }
//                                else {
//                                    listViewSearch.itemAtIndex(listViewSearch.currentIndex).color = "#0080f0"
//                                    listItem.bFocus = true
//                                }
//                            }

                            keyDelegatItem.focus = true

                            select.itemHeight = listItem.height

                            listViewSearch.currentIndex = index;
                        }
                    }

                    // Double click
                    onDoubleClicked: {
                        select.fileMode === 0 ? select.fnSSHDConfigSelect() : select.fnKeyFileSelect()
                    }
                }
            }

            // Display vertical scroll bar to ListView
            ScrollBar.vertical: ScrollBar {
                id: scrollVBar
                active: true
            }
        }
    }

    RoundButton {
        id: btnUpDirectory
        text: ""
        width: 48
        height: 48

        icon.source: pressed ? "Image/UpDirectoryPressed.png" : "Image/UpDirectory.png"
        icon.width: width
        icon.height: height
        icon.color: "transparent"

        padding: 0

        anchors.top: frameList.bottom
        anchors.topMargin: 20
        anchors.left: parent.left
        anchors.leftMargin: 20

        background: Rectangle {
            color: "transparent"
        }

        onClicked: {
            // Go to directory one level above.
            let iRet = remoteClient.setUpDirectory()
            if (iRet !== 0) {
                return
            }

            // Get directory one level above
            let directory = remoteClient.getCurrentDirectory()
            let command   = "dir " + directory

            let iConnect = remoteClient.writeToServer(command, 0)
            if (iConnect === 0) {
                labelPath.text = remoteClient.getCurrentDirectory()

                listModel.clear()

                let directories = remoteClient.directories();
                for (let i = 0; i < directories.length; i++) {
                    listModel.append({"file" : 1, "name": directories[i]});
                }

                let files = remoteClient.files();
                for (let j = 0; j < files.length; j++) {
                    listModel.append({"file" : 0, "name": files[j]});
                }
            }
            else if (iConnect === -1) {
                // Display error message.
                let errMsg = remoteClient.getErrorMessage()

                let componentDialog = Qt.createComponent("qrc:/ExtendQML/ErrorDialog.qml");
                if (componentDialog.status === Component.Ready) {
                    let errorDialog = componentDialog.createObject(select,
                                                                   {bDark: select.bDark, fontPadding: select.fontPadding,
                                                                    messageTitle: qsTr("Error"),
                                                                    messageText: qsTr("Failed to move directory on remote server.") + "<br>" + errMsg});
                    errorDialog.show();
                }
            }

            // Disable [go back one level up] button.
            if (remoteClient.getCurrentDirectory() === "/") {
                btnUpDirectory.enabled = false
                btnUpDirectory.opacity = 0.2
            }
            else {
                btnUpDirectory.enabled = true
                btnUpDirectory.opacity = 1.0
            }
        }
    }

    Row {
        id: rowBtn
        spacing: 30

        anchors.top: frameList.bottom
        anchors.topMargin: 20
        anchors.left:       btnUpDirectory.right
        anchors.leftMargin: Math.round((select.width - (btnselect.width + btnBack.width + btnCancel.width + 60)) / 2 - 20 - btnUpDirectory.width)

        Button {
            id: btnselect
            text: qsTr("Select")
            implicitWidth: Math.max(200, parent.width / 5)
            implicitHeight: Math.max(50, parent.height / 5)

            font.pointSize: 12 + select.fontPadding

            contentItem: Label {
                text: parent.text
                font: parent.font
                opacity: enabled ? 1.0 : 0.3
                color: select.bDark ? parent.pressed ? "#cccccc" : "#ffffff" : parent.pressed ? "#333333" : "#000000"
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

            onClicked: {
                select.fileMode === 0 ? select.fnSSHDConfigSelect() : select.fnKeyFileSelect()
            }
        }

        Button {
            id: btnBack
            text: qsTr("Back")
            implicitWidth: Math.max(200, parent.width / 5)
            implicitHeight: Math.max(50, parent.height / 5)

            font.pointSize: 12 + select.fontPadding

            contentItem: Label {
                text: parent.text
                font: parent.font
                opacity: enabled ? 1.0 : 0.3
                color: select.bDark ? parent.pressed ? "#cccccc" : "#ffffff" : parent.pressed ? "#333333" : "#000000"
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

            onClicked: {
                // Close remote server session.
                remoteClient.disConnectFromServer()

                // Previous view (Auth Window).
                parentName.prevViewChanged()
            }
        }

        Button {
            id: btnCancel
            text: qsTr("Cancel")
            implicitWidth: Math.max(200, parent.width / 5)
            implicitHeight: Math.max(50, parent.height / 5)

            font.pointSize: 12 + select.fontPadding

            contentItem: Label {
                text: parent.text
                font: parent.font
                opacity: enabled ? 1.0 : 0.3
                color: select.bDark ? parent.pressed ? "#cccccc" : "#ffffff" : parent.pressed ? "#333333" : "#000000"
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

            onClicked: {
                // Close remote server session process.
                remoteClient.disConnectFromServer()

                // Quit this dialog.
                parentName.close()
            }
        }
    }
}
