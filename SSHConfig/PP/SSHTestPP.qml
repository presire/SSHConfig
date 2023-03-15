import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Controls.Universal 2.15
import "../ExtendQML"
import SSHTest 1.0


Item {
    id: root
    objectName: "pageSSHTest"

    focus: true

    CSSHTest {
        id: sshTest;
    }

    property var    parentName:      null
    property var    windowState:     null
    property var    sshServerConfig: null
    property bool   bServerMode:     true
    property bool   bDark:           false
    property int    fontPadding:     0
    property int    option:          0
    property string localFileName:   ""
    property string remoteFilePath:  ""

    // Set Downloaded file from remote server.
    Connections {
        target: sshTest
        function onDownloadSSHFileFromServer(remoteFilePath, contents) {
            root.remoteFilePath = remoteFilePath
            textSSHFilePath.text = "remote:/" + remoteFilePath
        }
    }

    // Set Downloaded file from remote server.
    Connections {
        target: sshTest
        function onReadSSHDResult(status: int, message: string) {
            if (status === 0) {
                // If sshd command is test mode, create message.
                if (root.option === 0) {
                    message = qsTr("Success.") + "<br>" + qsTr("There is nothing wrong with sshd_config file.")
                }

                // Display result.
                outputLabel.text = message

                // Display success popup.
                completePopup.viewTitle   = qsTr("The sshd command was successfully executed on remote server")
                completePopup.fontPadding = root.fontPadding
                completePopup.bAutolose   = false
                completePopup.open()
            }
            else {
                // Error.
                let componentDialog = Qt.createComponent("qrc:/ExtendQML/ErrorDialogPP.qml");
                if (componentDialog.status === Component.Ready) {
                    let errorDialog = componentDialog.createObject(root,
                                                                   {mainWidth: root.width, mainHeight: root.height, bDark: root.bDark,
                                                                    messageTitle: qsTr("Exec Error"),
                                                                    messageText: qsTr("The sshd command failed to execute.") + "<br>" + message});
                    errorDialog.show();
                }
            }

            sshTest.disconnectFromServer()
        }
    }

    function fnExecuteRemoteSSHDCommand() {
        let componentDialog = null
        let errorDialog     = null

        if (remoteFilePath === "") {
            // Error.
            componentDialog = Qt.createComponent("qrc:/ExtendQML/ErrorDialogPP.qml");
            if (componentDialog.status === Component.Ready) {
                errorDialog = componentDialog.createObject(root,
                                                           {mainWidth: root.width, mainHeight: root.height, bDark: root.bDark,
                                                            messageTitle: qsTr("Exec Error"),
                                                            messageText: qsTr("Do not select sshd_config file on remote server.") + "<br>"});
                errorDialog.show();
            }
        }
        else {
            let iRet = sshTest.executeRemoteSSHDCommand(commandEdit.text, root.remoteFilePath, root.option)

            if (iRet !== 0) {
                // Error.
                let errMsg = sshTest.getErrorMessage()
                componentDialog = Qt.createComponent("qrc:/ExtendQML/ErrorDialogPP.qml");
                if (componentDialog.status === Component.Ready) {
                    errorDialog = componentDialog.createObject(root,
                                                               {mainWidth: root.width, mainHeight: root.height, bDark: root.bDark,
                                                                messageTitle: qsTr("Exec Error"),
                                                                messageText: qsTr("Failed to execute the sshd command.") + "<br>" + errMsg});
                    errorDialog.show();
                }
            }
        }
    }

    MouseArea {
        id: mouseAreaSSHTest
        anchors.fill: parent
        acceptedButtons: Qt.ForwardButton | Qt.BackButton  // Enable "ForwardButton" and "BackButton" on mouse
        hoverEnabled: true
        cursorShape: optionCheck.hoverd ? Qt.PointingHandCursor : Qt.ArrowCursor
        z: 1

        // Single click
        onClicked: {
            if (mouse.button === Qt.ForwardButton) {
                parentName.screenMoved("", 1)
            }
            else if (mouse.button === Qt.BackButton) {
                parentName.screenMoved("", 0)
            }
        }

        onMouseXChanged: {
            let optionX  = optionCheck.mapToItem(root, 0, 0).x
            let optionY  = optionCheck.mapToItem(root, 0, 0).y
            let commandX = commandCheck.mapToItem(root, 0, 0).x
            let commandY = commandCheck.mapToItem(root, 0, 0).y

            if (mouseX >= optionX && mouseX <= (optionX + optionCheck.width) &&
                mouseY >= optionY && mouseY <= (optionY + optionCheck.height)) {
                    cursorShape = Qt.PointingHandCursor
            }
            else if (mouseX >= commandX && mouseX <= (commandX + commandCheck.width) &&
                     mouseY >= commandY && mouseY <= (commandY + commandCheck.height)) {
                cursorShape = Qt.PointingHandCursor
            }
            else {
                cursorShape = Qt.ArrowCursor
            }
        }
    }

    ScrollView {
        id: scrollSSHTest
        width: parent.width
        height : parent.height
        contentWidth:  sshTestColumn.width    // The important part
        contentHeight: sshTestColumn.height   // Same
        anchors.fill: parent
        clip : true                          // Prevent drawing column outside the scrollview borders

        ColumnLayout {
            id: sshTestColumn
            width: parent.width
            spacing: 5

            Label {
                text: qsTr("Check the syntax in sshd_config")

                textFormat: Label.RichText
                font.pointSize: 12 + root.fontPadding

                wrapMode: Label.WordWrap

                verticalAlignment: Label.AlignVCenter
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignTop | Qt.AlignVCenter
                Layout.topMargin: 50
                Layout.leftMargin: (root.width - width) / 2
            }

            RowLayout {
                width: parent.width
                Layout.alignment: Qt.AlignVCenter
                Layout.leftMargin: (root.width - width) / 2

                spacing: 10

                TextField {
                    id: textSSHFilePath
                    text: ""
                    implicitWidth: root.width * 0.7
                    enabled: root.bServerMode ? true : false

                    font.pointSize: 12 + root.fontPadding
                    placeholderText: root.bServerMode ? qsTr("Click the right icon, select \"sshd_config\" Ex: /etc/ssh/sshd_config") :
                                                        qsTr("Click the right icon, select \"sshd_config\" on remote server")

                    horizontalAlignment: TextField.AlignLeft
                    verticalAlignment: TextField.AlignVCenter
                }

                RoundButton {
                    id: btnSSHFileSelect
                    text: ""
                    width: 64
                    height: 64

                    icon.source: root.bServerMode ? pressed ? "qrc:/Image/FileButtonPressed.png" : "qrc:/Image/FileButton.png"
                                                  : pressed ? "qrc:/Image/FileNetworkButtonPressed.png" : "qrc:/Image/FileNetworkButton.png"
                    icon.width: width
                    icon.height: height
                    icon.color: "transparent"

                    padding: 0

                    Layout.leftMargin: 20

                    background: Rectangle {
                        color: "transparent"
                    }

                    onClicked: {
                        if (root.bServerMode) {
                            // Server Mode.
                            selectSSHServerFileDialog.open()
                        }
                        else {
                            // Client Mode.
                            sshTest.downloadSSHConfigFile(parentName.width, parentName.height, root.bDark, root.fontPadding)
                        }
                    }

                    SelectFileDialog {
                        id: selectSSHServerFileDialog
                        mainWidth: root.width
                        mainHeight: root.height
                        filters: "SSH Config file (sshd_config*)"

                        onSelectedFile: {
                            // Get ssh(d).service file.
                            textSSHFilePath.text = strFilePath
                        }
                    }
                }
            }


            // SSHD Option.
            Rectangle {
                implicitWidth: parent.width * 0.8
                implicitHeight: optionCheck.height + (optionCheck.bChecked ? optionColumn.height : 0)
                color: "transparent"

                Layout.alignment: Qt.AlignTop
                Layout.topMargin: 10
                Layout.leftMargin: (root.width - implicitWidth) / 2

                Label {
                    id: optionCheck
                    text: qsTr("Output option (click)")
                    font.pointSize: 12 + root.fontPadding
                    wrapMode: Label.WordWrap

                    verticalAlignment: Label.AlignVCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    //Layout.alignment: Qt.AlignVCenter
                    //Layout.leftMargin: (root.width - width) / 2

                    property bool bChecked: false

                    MouseArea {
                        id: mouseAreaOption
                        anchors.fill: parent
                        acceptedButtons: Qt.LeftButton
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        propagateComposedEvents: true
                        z: 2

                        onEntered: {}
                        onExited: {}

                        onClicked: {
                            if (!optionCheck.bChecked) {
                                optionCheck.text = qsTr("Output option")
                            }
                            else {
                                optionCheck.text = qsTr("Output option (click)")
                            }

                            optionCheck.bChecked = !optionCheck.bChecked

                            mouse.accepted = false;
                        }
                    }
                }

                ColumnLayout {
                    id: optionColumn
                    width: parent.width
                    visible: optionCheck.bChecked ? true : false

                    spacing: 0

                    anchors.top: optionCheck.bottom
                    //Layout.alignment: Qt.AlignVCenter
                    //Layout.leftMargin: (root.width - width) / 2

                    ButtonGroup {
                        id: optionGroup
                        buttons: optionColumn.children

                        onClicked: {
                            root.option = optiontBtn.checked ? 0 : optionTBtn.checked ? 1 : optionTDBtn.checked ? 2 : 3
                        }
                    }

                    RadioButton {
                        id: optiontBtn
                        text: qsTr("Check (normal).")
                        checked: true
                        font.pointSize: 10 + root.fontPadding
                        //indicator.scale: 1.25

                        ButtonGroup.group: optionGroup

                        Layout.leftMargin: (parent.width - optionTDDBtn.width) / 2
                    }

                    RadioButton {
                        id: optionTBtn
                        text: qsTr("Check and Print valid settings.")
                        font.pointSize: 10 + root.fontPadding
                        //indicator.scale: 1.25

                        ButtonGroup.group: optionGroup

                        Layout.leftMargin: (parent.width - optionTDDBtn.width) / 2
                    }

                    RadioButton {
                        id: optionTDBtn
                        text: qsTr("Check and Print valid settings with debug level.")
                        font.pointSize: 10 + root.fontPadding
                        //indicator.scale: 1.25

                        ButtonGroup.group: optionGroup

                        Layout.leftMargin: (parent.width - optionTDDBtn.width) / 2
                    }

                    RadioButton {
                        id: optionTDDBtn
                        text: qsTr("Check and Print valid settings with more debug level.")
                        font.pointSize: 10 + root.fontPadding
                        //indicator.scale: 1.25

                        ButtonGroup.group: optionGroup

                        Layout.leftMargin: (parent.width - optionTDDBtn.width) / 2
                    }
                }
            }

            // SSHD Command Path
            Label {
                id: commandCheck
                text: qsTr("Command Path (click)")
                font.pointSize: 12 + root.fontPadding
                wrapMode: Label.WordWrap

                verticalAlignment: Label.AlignVCenter
                Layout.alignment: Qt.AlignVCenter
                Layout.topMargin: 10
                Layout.leftMargin: (root.width - width) / 2

                property bool bChecked: false

                MouseArea {
                    id: mouseAreaCommand
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    propagateComposedEvents: true
                    z: 2

                    onEntered: {}
                    onExited: {}

                    onClicked: {
                        if (!commandCheck.bChecked) {
                            commandCheck.text = qsTr("Command Path")
                        }
                        else {
                            commandCheck.text = qsTr("Command Path (click)")
                        }

                        commandCheck.bChecked = !commandCheck.bChecked

                        mouse.accepted = false;
                    }
                }
            }

            TextField {
                id: commandEdit
                text: "/usr/sbin/sshd"
                width: Math.round((root.width) * 0.8)
                implicitWidth: Math.round((root.implicitWidth) * 0.8)
                visible: commandCheck.bChecked ? true : false

                font.pointSize: 12 + root.fontPadding
                placeholderText: qsTr("sshd Command Path")

                Layout.leftMargin: (root.width - width) / 2
                verticalAlignment: TextField.AlignVCenter
            }

            Button {
                id: execSSHDBtn
                text: qsTr("Check")
                implicitWidth: Math.round(root.width / 5) > 200 ? 300 : 200
                implicitHeight: Math.round(root.height / 15) > 50 ? 70 : 50

                Layout.topMargin: 20
                Layout.leftMargin: (root.width - implicitWidth) / 2

                contentItem: Label {
                    text: parent.text
                    font: parent.font
                    color: root.bDark ? parent.pressed ? "#cccccc" : "#ffffff" : parent.pressed ? "#333333" : "#000000"

                    horizontalAlignment: Label.AlignHCenter
                    verticalAlignment: Label.AlignVCenter
                    elide: Label.ElideRight
                }

                background: Rectangle {
                    implicitWidth: parent.width
                    implicitHeight: parent.height
                    color: "transparent"
                    opacity: parent.focus ? 0.3 : 1
                    border.color: root.bDark ? "#10980a" : "#20a81a"
                    border.width: parent.focus ? 3 : 1
                    radius: 2
                }

                onClicked: {
                    let iRet = 0
                    if (root.bServerMode) {
                        // Server Mode.
                        iRet = sshTest.executeSSHDCommand(commandEdit.text, textSSHFilePath.text, root.option)

                        if (iRet === 0){
                            // Display result.
                            let messageSSHD  = sshTest.getCommandResult()
                            outputLabel.text = messageSSHD

                            // Display success popup.
                            completePopup.viewTitle   = qsTr("The sshd command was successfully executed")
                            completePopup.fontPadding = root.fontPadding
                            completePopup.bAutolose   = false
                            completePopup.open()
                        }
                        else if (iRet === 1) {
                            // If password authentication is canceled.
                        }
                        else {
                            // Error.
                            let errMsg = sshTest.getErrorMessage()
                            let componentDialog = Qt.createComponent("qrc:/ExtendQML/ErrorDialogPP.qml");
                            if (componentDialog.status === Component.Ready) {
                                let errorDialog = componentDialog.createObject(root,
                                                                               {mainWidth: root.width, mainHeight: root.height, bDark: root.bDark,
                                                                                messageTitle: qsTr("Exec Error"),
                                                                                messageText: qsTr("Failed to execute the sshd command.") + "<br>" + errMsg});
                                errorDialog.show();
                            }
                        }
                    }
                    else {
                        // Client Mode.
                        root.fnExecuteRemoteSSHDCommand()
                    }
                }
            }

            Rectangle {
                implicitWidth: root.width * 0.85
                implicitHeight: Math.max(800, root.height * 0.7)
                color: "#202020"
                Layout.topMargin: 20
                Layout.leftMargin: (root.width - width) / 2
                Layout.bottomMargin: 20

                Flickable {
                    id: flick
                    width: parent.width
                    height: parent.height
                    contentWidth: parent.width
                    contentHeight: outputLabel.height
                    clip: true
                    ScrollBar {
                        clip: true
                    }

                    Label {
                        id: outputLabel
                        text: qsTr("Results are output here...")
                        color: "white"
                        font.pointSize: 12 + root.fontPadding
                        smooth: true
                        //elide: Label.ElideRight
                        wrapMode: Label.WordWrap

                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        horizontalAlignment: Label.AlignJustify
                        verticalAlignment:   Label.AlignVCenter
                    }
                }
            }
        }
    }

    CompletePopup {
        id: completePopup

        viewTitle: ""
        positionY: Math.round((root.height - completePopup.height) / 10)
        viewWidth: root.width
        fontPadding: 0
        parentName: root.parentName
    }
}
