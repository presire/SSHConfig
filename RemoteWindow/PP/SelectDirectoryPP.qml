import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Controls.Universal 2.15
import "../ExtendQML"
import ClientSession 1.0


Item {
    id: selectDirectory
    visible: true

    property var    parentName:     null
    property int    viewWidth:      375
    property int    viewHeight:     812
    property bool   bDark:          false
    property int    fontPadding:    0
    property int    directoryType:  0  // 0 : Directory for PID file.
                                       // 1 : Directory for chroot.

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
        let bConnect = remoteClient.connectToServer(selectDirectory.hostName,       selectDirectory.port,           selectDirectory.bUseSSL,        selectDirectory.bUseCert,   selectDirectory.certFile,
                                                    selectDirectory.bUsePrivateKey, selectDirectory.privateKeyFile, selectDirectory.bUsePassphrase, selectDirectory.passphrase, 0)
        if (bConnect === false) {
            errMsg = remoteClient.getErrorMessage()

            componentDialog = Qt.createComponent("qrc:/ExtendQML/ErrorDialogPP.qml");
            if (componentDialog.status === Component.Ready) {
                errorDialog = componentDialog.createObject(selectDirectory,
                                                           {bDark: selectDirectory.bDark, fontPadding: selectDirectory.fontPadding,
                                                            mainWidth: selectDirectory.width,
                                                            messageTitle: qsTr("Error"),
                                                            messageText: qsTr("Connection failed.") + "<br>" + errMsg});
                errorDialog.show();
            }

            btnselect.enabled = false
        }
        else {
            // Get initial direcotry.
            let directory = remoteClient.getCurrentDirectory()

            let command  = "onlydir " + directory
            let iConnect = remoteClient.writeToServer(command, 10)

            if (iConnect !== 0) {
                errMsg = remoteClient.getErrorMessage()

                componentDialog = Qt.createComponent("qrc:/ExtendQML/ErrorDialogPP.qml");
                if (componentDialog.status === Component.Ready) {
                    errorDialog = componentDialog.createObject(selectDirectory,
                                                               {bDark: selectDirectory.bDark, fontPadding: selectDirectory.fontPadding,
                                                                mainWidth: selectDirectory.width,
                                                                messageTitle: qsTr("Error"),
                                                                messageText: qsTr("Connection failed.") + "<br>" + errMsg});
                    errorDialog.show();
                }

                btnselectDirectory.enabled = false
            }
        }
    }

    Connections {
        target: remoteClient
        function onServerConnected() {
            completePopup.viewTitle = qsTr("Connection succeeded")
            completePopup.fontPadding = selectDirectory.fontPadding
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
                listModel.append({"name": directories[i]});
            }
        }
    }

    Connections {
        target: remoteClient
        function onReadError(errorMessage: string) {
            let componentDialog = Qt.createComponent("qrc:/ExtendQML/ErrorDialogPP.qml");
            if (componentDialog.status === Component.Ready) {
                let errorDialog = componentDialog.createObject(selectDirectory,
                                                           {bDark: selectDirectory.bDark, fontPadding: selectDirectory.fontPadding,
                                                            mainWidth: selectDirectory.width,
                                                            messageTitle: qsTr("Error"),
                                                            messageText: qsTr("Error on reception or invalid command.") + "<br>" + errorMessage});
                errorDialog.show();
            }
        }
    }

    // Select sshd_config file.
    function fnSelectDirectory() {
        // Change directory to selected directory.
        remoteClient.setCurrentDirectory(listModel.get(listViewSearch.currentIndex).name)
        let nextDirectory = remoteClient.getCurrentDirectory()

        // Send command to remote server.
        let command = "onlydir " + nextDirectory
        let iRet = remoteClient.writeToServer(command, 10)

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

            componentDialog = Qt.createComponent("qrc:/ExtendQML/ErrorDialogPP.qml");
            if (componentDialog.status === Component.Ready) {
                let errorDialog = componentDialog.createObject(selectDirectory,
                                                               {bDark: selectDirectory.bDark, fontPadding: selectDirectory.fontPadding,
                                                                mainWidth: selectDirectory.width,
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

    CompletePopup {
        id: completePopup

        viewTitle: ""
        positionY: 0
        viewWidth: selectDirectory.width
        fontPadding: 0
        parentName: selectDirectory.parentName
    }

    // Remote Window UI Control
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
        x: 20
        y: 20
        width: parent.width - 40

//        anchors.top: parent.top
//        anchors.topMargin: 20
//        anchors.left: parent.left
//        anchors.leftMargin: 20
//        anchors.right: parent.right
//        anchors.rightMargin: 20

        spacing: 0

        Image {
            id: pathIcon
            source: "qrc:/Image/Directory.png"
            fillMode: Image.Stretch

            Layout.alignment: Qt.AlignLeft
            Layout.rightMargin: 10
        }

        Label {
            id: labelPath
            text: ""
            font.pointSize: 10 + selectDirectory.fontPadding

            //textFormat: Label.RichText
            wrapMode: Label.WordWrap

            verticalAlignment: Label.AlignVCenter
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }

    // Select Directory List
    Frame {
        id: frameList
        x: 20
        y: pathRow.y + pathRow.height + 20
        width: parent.width - 40
        height: Math.round(parent.height / 3 * 2)

//        anchors.top: pathRow.bottom
//        anchors.topMargin: 20
//        anchors.left: parent.left
//        anchors.leftMargin: 20
//        anchors.right: parent.right
//        anchors.rightMargin: 20

        Component {
            id: highlightBar
            Rectangle {
                y: listViewSearch.count === 0 ? 0.0 : listViewSearch.currentItem == null ? 0.0 : listViewSearch.currentItem.y
                width: frameList.width - scrollVBar.width
                height: selectDirectory.itemHeight
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
                        source: "qrc:/Image/Directory.png"
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
                        font.pointSize: 12 + selectDirectory.fontPadding

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
                            keyDelegatItem.focus = true

                            selectDirectory.itemHeight = listItem.height

                            listViewSearch.currentIndex = index;
                        }
                    }

                    // Double click
                    onDoubleClicked: {
                        selectDirectory.fnSelectDirectory()
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

        icon.source: pressed ? "qrc:/Image/UpDirectoryPressed.png" : "qrc:/Image/UpDirectory.png"
        icon.width: width
        icon.height: height
        icon.color: "transparent"

        padding: 0

        anchors.top: frameList.bottom
        anchors.topMargin: 10
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
            let command   = "onlydir " + directory

            let iConnect = remoteClient.writeToServer(command, 10)
            if (iConnect === 0) {
                labelPath.text = remoteClient.getCurrentDirectory()

                listModel.clear()

                let directories = remoteClient.directories();
                for (let i = 0; i < directories.length; i++) {
                    listModel.append({"name": directories[i]});
                }
            }
            else if (iConnect === -1) {
                // Display error message.
                let errMsg = remoteClient.getErrorMessage()

                let componentDialog = Qt.createComponent("qrc:/ExtendQML/ErrorDialogPP.qml");
                if (componentDialog.status === Component.Ready) {
                    let errorDialog = componentDialog.createObject(selectDirectory,
                                                                   {bDark: selectDirectory.bDark, fontPadding: selectDirectory.fontPadding,
                                                                    mainWidth: selectDirectory.width,
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
        spacing: selectDirectory.width >= 875 ? 30 : 20

        anchors.top: selectDirectory.width >= 875 ? frameList.bottom : btnUpDirectory.bottom
        anchors.topMargin: 10
        anchors.horizontalCenter: parent.horizontalCenter

        Button {
            id: btnselect
            text: qsTr("Done")
            implicitWidth: selectDirectory.width >= 875 ? 150 : 100
            implicitHeight: 50

            font.pointSize: 10 + selectDirectory.fontPadding

            contentItem: Label {
                text: parent.text
                font: parent.font
                opacity: enabled ? 1.0 : 0.3
                color: selectDirectory.bDark ? parent.pressed ? "#cccccc" : "#ffffff" : parent.pressed ? "#333333" : "#000000"
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
                // Send path to chosen directory.
                if (listViewSearch.currentIndex >= 0 && listViewSearch.currentIndex < listViewSearch.count) {
                    if (remoteClient.getCurrentDirectory() === "/") {
                        parentName.getDirectory(selectDirectory.directoryType, remoteClient.getCurrentDirectory() + listModel.get(listViewSearch.currentIndex).name)
                    }
                    else {
                        parentName.getDirectory(selectDirectory.directoryType, remoteClient.getCurrentDirectory() + "/" + listModel.get(listViewSearch.currentIndex).name)
                    }

                    // Quit this dialog.
                    parentName.close()
                }
                else {
                    let componentDialog = Qt.createComponent("qrc:/ExtendQML/ErrorDialogPP.qml");
                    if (componentDialog.status === Component.Ready) {
                        let errorDialog = componentDialog.createObject(selectDirectory,
                                                                       {bDark: selectDirectory.bDark, fontPadding: selectDirectory.fontPadding,
                                                                        mainWidth: selectDirectory.width,
                                                                        messageTitle: qsTr("Error"),
                                                                        messageText: qsTr("You will need to select a directory.") + "<br>"});
                        errorDialog.show();
                    }
                }
            }
        }

        Button {
            id: btnBack
            text: qsTr("Back")
            implicitWidth: selectDirectory.width >= 875 ? 150 : 100
            implicitHeight: 50

            font.pointSize: 10 + selectDirectory.fontPadding

            contentItem: Label {
                text: parent.text
                font: parent.font
                opacity: enabled ? 1.0 : 0.3
                color: selectDirectory.bDark ? parent.pressed ? "#cccccc" : "#ffffff" : parent.pressed ? "#333333" : "#000000"
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
            implicitWidth: selectDirectory.width >= 875 ? 150 : 100
            implicitHeight: 50

            font.pointSize: 10 + selectDirectory.fontPadding

            contentItem: Label {
                text: parent.text
                font: parent.font
                opacity: enabled ? 1.0 : 0.3
                color: selectDirectory.bDark ? parent.pressed ? "#cccccc" : "#ffffff" : parent.pressed ? "#333333" : "#000000"
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
