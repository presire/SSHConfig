import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Controls.Universal 2.15
import "ExtendQML"
import ClientSession 1.0


ApplicationWindow {
    id: reloadDialog
    width:  reloadDialogColumn.width
    height: reloadDialogColumn.height
    minimumWidth:  reloadDialogColumn.width
    minimumHeight: reloadDialogColumn.height
    maximumWidth:  reloadDialogColumn.width
    maximumHeight: reloadDialogColumn.height
    visible: true

    property int    viewWidth:      0
    property int    viewHeight:     0
    property bool   bDark:          false
    property int    fontPadding:    0
    property int    fileMode:       0  // 0 : Download sshd_config file.
                                       // 1 : Get path to key file.

    property string hostName:       ""
    property string port:           ""
    property bool   bUseSSL:        false
    property bool   bUseCert:       false
    property string certFile:       ""
    property bool   bUsePrivateKey: false
    property string privateKeyFile: ""
    property bool   bUsePassphrase: false
    property string passphrase:     ""
    property string sshdFile:       ""

    onClosing: {
        remoteClient.disConnectFromServer()
    }

    signal reloadSSHFile(string sshdFile, string contents)

    CClient {
        id: remoteClient;
    }

    Connections {
        target: remoteClient
        function onReloadSSHFile(contents: string) {
            // Send sshd_config file path on remote server and sshd_config file's contents.
            reloadDialog.reloadSSHFile(reloadDialog.sshdFile, contents)

            // Close Remote Dialog.
            reloadDialog.close()
        }
    }

    Connections {
        target: remoteClient
        function onServerConnected() {
        }
    }

    function fnReload() {
        // Make remote connection
        let errMsg          = ""
        let componentDialog = null
        let errorDialog     = null

        // Connect remote server.
        let bConnect = remoteClient.connectToServer(reloadDialog.hostName,   reloadDialog.port,           reloadDialog.bUseSSL,        reloadDialog.bUseCert,
                                                    reloadDialog.certFile,   reloadDialog.bUsePrivateKey, reloadDialog.privateKeyFile, reloadDialog.bUsePassphrase,
                                                    reloadDialog.passphrase, reloadDialog.fileMode)

        if (bConnect === false) {
            errMsg = remoteClient.getErrorMessage()

            componentDialog = Qt.createComponent("qrc:/ExtendQML/ErrorDialog.qml");
            if (componentDialog.status === Component.Ready) {
                errorDialog = componentDialog.createObject(reloadDialog,
                                                           {bDark: reloadDialog.bDark, fontPadding: reloadDialog.fontPadding,
                                                            messageTitle: qsTr("Error"),
                                                            messageText: qsTr("Connection failed.") + "<br>" + errMsg});
                errorDialog.show();
            }
        }
        else {
            // Get sshd_config file.
            let directory = remoteClient.getCurrentDirectory()
            let command   = "reload " + reloadDialog.sshdFile

            let iConnect = remoteClient.writeToServer(command, 2)
            if (iConnect !== 0) {
                errMsg = remoteClient.getErrorMessage()

                componentDialog = Qt.createComponent("qrc:/ExtendQML/ErrorDialog.qml");
                if (componentDialog.status === Component.Ready) {
                    errorDialog = componentDialog.createObject(reloadDialog,
                                                               {bDark: reloadDialog.bDark, fontPadding: reloadDialog.fontPadding,
                                                                messageTitle: qsTr("Error"),
                                                                messageText: qsTr("Connection failed.") + "<br>" + errMsg});
                    errorDialog.show();
                }
            }
        }
    }

    // Reload Dialog UI Control
    ColumnLayout {
        id: reloadDialogColumn

        RowLayout {
            width: parent.width
            spacing: 0

            Layout.alignment: Qt.AlignHCenter
            Layout.margins: 20

            Image {
                id: reloadIcon
                source: "Image/SSHFile.png"
                fillMode: Image.Stretch

                Layout.alignment: Qt.AlignVCenter
                Layout.rightMargin: 20
            }

            Label {
                text: qsTr("Do you want to re-download the sshd_config file?")
                font.pointSize: 12 + reloadDialog.fontPadding

                textFormat: Label.RichText
                wrapMode: Label.WordWrap

                verticalAlignment: Label.AlignVCenter
                Layout.fillHeight: true
            }
        }

        RowLayout {
            width: parent.width
            spacing: 20

            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 50
            //Layout.rightMargin: 40
            Layout.bottomMargin: 20

            Button {
                id: okBtn
                text: qsTr("OK")
                implicitWidth: Math.max(200, parent.width / 5)
                implicitHeight: Math.max(50, parent.height / 5)
                font.pointSize: 12 + reloadDialog.fontPadding

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
                    opacity: enabled ? 1 : 0.3
                    border.color: parent.pressed ? "#10980a" : "#20a81a"
                    border.width: parent.pressed ? 3 : 2
                    radius: 2
                }

                onClicked: {
                    // Download sshd_config.
                    reloadDialog.fnReload()
                }

                Keys.onReturnPressed: {
                    clicked()
                }
            }

            Button {
                id: cancelBtn
                text: qsTr("Cancel")
                implicitWidth: Math.max(200, parent.width / 5)
                implicitHeight: Math.max(50, parent.height / 5)
                font.pointSize: 12 + reloadDialog.fontPadding

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
                    opacity: enabled ? 1 : 0.3
                    border.color: parent.pressed ? "#10980a" : "#20a81a"
                    border.width: parent.pressed ? 3 : 2
                    radius: 2
                }

                onClicked: {
                    // Cancel.
                    reloadDialog.close()
                }

                Keys.onReturnPressed: {
                    clicked()
                }
            }
        }
    }
}
