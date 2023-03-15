import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Controls.Universal 2.15
import "../ExtendQML"
import WindowState 1.0
import ClientSession 1.0


Item {
    id: auth
    visible: true

    // Widows status.
    property var  parentName:  null
    property int  viewWidth:   375
    property int  viewHeight:  812
    property bool bDark:       false
    property int  fontPadding: 0

    // Edit Flag.
    property int  editStatus:  0

    // Save Flag.
    property bool bSave:       false

    // Read mode option.
    // Buffer for configuration information.
    property string oldHostName:       windowState.getHostName()
    property string oldPort:           windowState.getPort()
    property bool   bOldUseSSL:        windowState.getSSL()
    property bool   bOldUseCert:       windowState.getCert()
    property string oldCertFile:       windowState.getCertFile()
    property bool   bOldPrivateKey:    windowState.getPrivateKey()
    property string oldPrivateKeyFile: windowState.getPrivateKeyFile()
    property bool   bOldPassphrase:    windowState.getPassphrase()

    property string hostName:       oldHostName
    property string port:           oldPort
    property bool   bUseSSL:        bOldUseSSL
    property bool   bUseCert:       bOldUseCert
    property string certFile:       oldCertFile
    property bool   bUsePrivateKey: bOldPrivateKey
    property string privateKeyFile: oldPrivateKeyFile
    property bool   bUsePassphrase: bOldPassphrase
    property string passphrase:     ""

    CWindowState {
        id: windowState;
    }

    ScrollView {
        id: scrollModeSettings
        width: parent.width
        height : parent.height
        contentWidth: authColumn.width    // The important part
        contentHeight: authColumn.height  // Same
        anchors.fill: parent
        clip : true                       // Prevent drawing column outside the scrollview borders

        ColumnLayout {
            id: authColumn
            width: parent.width
            spacing: 5

            // Host name.
            RowLayout {
                id: hostRow
                width: parent.width
                spacing: 20

                Layout.alignment: Qt.AlignVCenter
                Layout.topMargin: 30
                Layout.leftMargin: (auth.width - width) / 2

                Label {
                    id: hostLabel
                    text: qsTr("Host Name :")
                    font.pointSize: 12 + auth.fontPadding

                    textFormat: Label.RichText

                    Layout.fillHeight: true
                    horizontalAlignment: Label.AlignHCenter
                    verticalAlignment: Label.AlignVCenter
                }

                TextField {
                    id: hostEdit
                    text: auth.oldHostName
                    width: Math.round((auth.width - hostLabel.width - hostRow.spacing) * 0.5)
                    implicitWidth: Math.round((auth.width - hostLabel.width - hostRow.spacing) * 0.5)
                    font.pointSize: 12 + auth.fontPadding
                    placeholderText: qsTr("Remote Server Name")

                    horizontalAlignment: TextField.AlignRight
                    verticalAlignment: TextField.AlignVCenter

                    // Input limit
                    validator: RegExpValidator {
                        regExp: /[a-zA-Z0-9_.:;@/\\][a-zA-Z0-9_-.:;@/\\]*/
                    }

                    onTextEdited: {
                        if (text !== oldHostName) editStatus |= 0x01
                        else                      editStatus &= ~0x01

                        auth.hostName = text
                    }
                }
            }

            // Port number.
            RowLayout {
                id: portRow
                width: parent.width
                spacing: 20

                Layout.alignment: Qt.AlignVCenter
                Layout.leftMargin: (auth.width - width) / 2

                Label {
                    id: portLabel
                    text: qsTr("Port :")
                    font.pointSize: 12 + auth.fontPadding

                    textFormat: Label.RichText

                    Layout.fillHeight: true
                    horizontalAlignment: Label.AlignHCenter
                    verticalAlignment: Label.AlignVCenter
                }

                TextField {
                    id: portEdit
                    text: auth.oldPort.length === 0 ? "61060" : auth.oldPort
                    width: Math.round((auth.width - portLabel.width - portRow.spacing) * 0.2)
                    implicitWidth: Math.round((auth.width - portLabel.width - portRow.spacing) * 0.2)
                    font.pointSize: 12 + auth.fontPadding
                    placeholderText: qsTr("Port Number")

                    horizontalAlignment: TextField.AlignRight
                    verticalAlignment: TextField.AlignVCenter

                    // Input limit (1 - 65535)
                    validator: RegExpValidator {
                        regExp: /[1-9][0-9]{4}|65535/
                    }

                    onTextEdited: {
                        // Input limit (No input allowed for 65536 or higher)
                        if (acceptableInput) {
                            if (text > 65535) {
                                text = displayText
                            }
                        }

                        if (text !== oldPort) editStatus |= 0x02
                        else                  editStatus &= ~0x02

                        auth.port = text
                    }
                }
            }

            // Use SSL.
            CheckBox {
                id: useSSLCheck
                text: qsTr("Use SSL")
                checked: auth.bOldUseSSL ? true : false
                font.pointSize: 12 + auth.fontPadding

                Layout.alignment: Qt.AlignVCenter
                Layout.leftMargin: (auth.width - width) / 2

                indicator: Rectangle {
                    y: (useSSLCheck.height - height) / 2
                    implicitWidth: 30
                    implicitHeight: 30
                    color: "transparent"
                    border.color: auth.bDark ? "white" : "black"
                    opacity: parent.enabled ? useSSLCheck.down ? 0.5 : 1.0 : 0.2
                    border.width: 2

                    Image {
                        id: imgUseSSLCheck
                        x: (parent.width - width) / 2
                        y: (parent.height - height) / 2
                        width: parent.width - 10
                        height: parent.height - 10
                        source: "qrc:/Image/Check.png"
                        visible: useSSLCheck.checked
                    }
                }

                onCheckedChanged: {
                    if (checked !== auth.bOldUseSSL)  editStatus |= 0x04
                    else                              editStatus &= ~0x04

                    auth.bUseSSL = checked
                }
            }

            // Use certificate.
            CheckBox {
                id: useCertCheck
                text: qsTr("Use Certificate")
                checked: auth.bOldUseCert ? true : false
                visible: useSSLCheck.checked ? true : false
                font.pointSize: 12 + auth.fontPadding

                Layout.alignment: Qt.AlignVCenter
                Layout.leftMargin: (auth.width - width) / 2

                indicator: Rectangle {
                    y: (useCertCheck.height - height) / 2
                    implicitWidth: 30
                    implicitHeight: 30
                    color: "transparent"
                    border.color: auth.bDark ? "white" : "black"
                    opacity: parent.enabled ? useCertCheck.down ? 0.5 : 1.0 : 0.2
                    border.width: 2

                    Image {
                        id: imgUseCertCheck
                        x: (parent.width - width) / 2
                        y: (parent.height - height) / 2
                        width: parent.width - 10
                        height: parent.height - 10
                        source: "qrc:/Image/Check.png"
                        visible: useCertCheck.checked
                    }
                }

                onCheckedChanged: {
                    if (checked !== auth.bOldUseCert) editStatus |= 0x08
                    else                              editStatus &= ~0x08

                    auth.bUseCert = checked
                }
            }

            // Certificate file.
            RowLayout {
                id: certFileRow
                width: parent.width
                visible: useSSLCheck.checked ? useCertCheck.checked ? true : false : false
                spacing: 20

                Layout.alignment: Qt.AlignVCenter
                Layout.leftMargin: (auth.width - width) / 2

                Label {
                    id: certFileLabel
                    text: qsTr("Certificate File :")
                    font.pointSize: 12 + auth.fontPadding

                    textFormat: Label.RichText

                    Layout.fillHeight: true
                    horizontalAlignment: Label.AlignHCenter
                    verticalAlignment: Label.AlignVCenter
                }

                TextField {
                    id: certFileEdit
                    text: auth.oldCertFile
                    width: Math.round((auth.width - certFileLabel.width - certFileRow.spacing) * 0.5)
                    implicitWidth: Math.round((auth.width - certFileLabel.width - certFileRow.spacing) * 0.5)
                    font.pointSize: 12 + auth.fontPadding
                    placeholderText: qsTr("Select Certificate file")

                    horizontalAlignment: TextField.AlignRight
                    verticalAlignment: TextField.AlignVCenter

                    onTextEdited: {
                        if (certFileEdit.text !== auth.oldCertFile) editStatus |= 0x10
                        else                                        editStatus &= ~0x10

                        auth.certFile = text
                    }
                }

                RoundButton {
                    id: btnCertFileSelect
                    text: ""
                    width: 64
                    height: 64

                    icon.source: pressed ? "qrc:/Image/KeyFileButtonPressed.png" : "qrc:/Image/KeyFileButton.png"
                    icon.width: width
                    icon.height: height
                    icon.color: "transparent"

                    padding: 0
                    Layout.alignment: Qt.AlignHCenter

                    background: Rectangle {
                        color: "transparent"
                    }

                    onClicked: {
                        selectCertFileDialog.open()
                    }
                }

                SelectFileDialog {
                    id: selectCertFileDialog
                    mainWidth: parentName.width
                    mainHeight: parentName.height
                    filters: "Certificate file (*.pem *.der *.crt)"

                    onSelectedFile: {
                        certFileEdit.text = strFilePath
                        auth.certFile     = strFilePath

                        if (certFileEdit.text !== auth.oldCertFile) editStatus |= 0x10
                        else                                        editStatus &= ~0x10
                    }
                }
            }


            // Use private key.
            CheckBox {
                id: usePrivateKeyCheck
                text: qsTr("Use Private Key")
                checked: auth.bOldPrivateKey ? true : false
                visible: useSSLCheck.checked ? true : false
                font.pointSize: 12 + auth.fontPadding

                Layout.alignment: Qt.AlignVCenter
                Layout.leftMargin: (auth.width - width) / 2

                indicator: Rectangle {
                    y: (usePrivateKeyCheck.height - height) / 2
                    implicitWidth: 30
                    implicitHeight: 30
                    color: "transparent"
                    border.color: auth.bDark ? "white" : "black"
                    opacity: parent.enabled ? usePrivateKeyCheck.down ? 0.5 : 1.0 : 0.2
                    border.width: 2

                    Image {
                        id: imgPrivateKeyCheck
                        x: (parent.width - width) / 2
                        y: (parent.height - height) / 2
                        width: parent.width - 10
                        height: parent.height - 10
                        source: "qrc:/Image/Check.png"
                        visible: usePrivateKeyCheck.checked
                    }
                }

                onCheckedChanged: {
                    if (checked !== auth.bOldPrivateKey) editStatus |= 0x20
                    else                                 editStatus &= ~0x20

                    auth.bUsePrivateKey = checked
                }
            }

            // Private key file.
            RowLayout {
                id: privateKeyFileRow
                width: parent.width
                visible: useSSLCheck.checked ? usePrivateKeyCheck.checked ? true : false : false
                spacing: 20

                Layout.alignment: Qt.AlignVCenter
                Layout.leftMargin: (auth.width - width) / 2

                Label {
                    id: privateKeyFileLabel
                    text: qsTr("Private Key File :")
                    font.pointSize: 12 + auth.fontPadding

                    textFormat: Label.RichText

                    Layout.fillHeight: true
                    horizontalAlignment: Label.AlignHCenter
                    verticalAlignment: Label.AlignVCenter
                }

                TextField {
                    id: privateKeyFileEdit
                    text: auth.oldPrivateKeyFile
                    width: Math.round((auth.width - privateKeyFileLabel.width - privateKeyFileRow.spacing) * 0.5)
                    implicitWidth: Math.round((auth.width - privateKeyFileLabel.width - privateKeyFileRow.spacing) * 0.5)
                    font.pointSize: 12 + auth.fontPadding
                    placeholderText: qsTr("Select Private Key file")

                    horizontalAlignment: TextField.AlignRight
                    verticalAlignment: TextField.AlignVCenter

                    onTextEdited: {
                        if (privateKeyFileEdit.text !== auth.oldPrivateKeyFile) editStatus |= 0x40
                        else                                                    editStatus &= ~0x40

                        auth.privateKeyFile = text
                    }
                }

                RoundButton {
                    id: btnPrivateKeyFileSelect
                    text: ""
                    width: 64
                    height: 64

                    icon.source: pressed ? "qrc:/Image/KeyFileButtonPressed.png" : "qrc:/Image/KeyFileButton.png"
                    icon.width: width
                    icon.height: height
                    icon.color: "transparent"

                    padding: 0
                    Layout.alignment: Qt.AlignHCenter

                    background: Rectangle {
                        color: "transparent"
                    }

                    onClicked: {
                        selectPrivateKeyFileDialog.open()
                    }
                }

                SelectFileDialog {
                    id: selectPrivateKeyFileDialog
                    mainWidth: parentName.width
                    mainHeight: parentName.height
                    filters: "Private Key file (*.pem *.der *.key)"

                    onSelectedFile: {
                        privateKeyFileEdit.text = strFilePath
                        auth.privateKeyFile     = strFilePath
                    }
                }
            }

            // Use Passphrase.
            CheckBox {
                id: passphraseCheck
                text: qsTr("Use Passphrase")
                checked: auth.bOldPassphrase ? true : false
                visible: useSSLCheck.checked ? usePrivateKeyCheck.checked ? true : false : false
                font.pointSize: 12 + auth.fontPadding

                Layout.alignment: Qt.AlignVCenter
                Layout.leftMargin: (auth.width - width) / 2

                indicator: Rectangle {
                    y: (passphraseCheck.height - height) / 2
                    implicitWidth: 30
                    implicitHeight: 30
                    color: "transparent"
                    border.color: auth.bDark ? "white" : "black"
                    opacity: parent.enabled ? passphraseCheck.down ? 0.5 : 1.0 : 0.2
                    border.width: 2

                    Image {
                        id: imgPassphraseCheck
                        x: (parent.width - width) / 2
                        y: (parent.height - height) / 2
                        width: parent.width - 10
                        height: parent.height - 10
                        source: "qrc:/Image/Check.png"
                        visible: passphraseCheck.checked
                    }
                }

                onCheckedChanged: {
                    if (checked !== auth.bOldPassphrase) editStatus |= 0x80
                    else                                 editStatus &= ~0x80

                    auth.bUsePassphrase = checked
                }
            }

            RowLayout {
                id: passphraseRow
                width: parent.width
                visible: useSSLCheck.checked ? usePrivateKeyCheck.checked ? true : false : false
                spacing: 20

                Layout.alignment: Qt.AlignVCenter
                Layout.topMargin: 20
                Layout.leftMargin: (auth.width - width) / 2

                Label {
                    id: passphraseLabel
                    text: qsTr("Passphrase :")
                    font.pointSize: 12 + auth.fontPadding

                    textFormat: Label.RichText

                    Layout.fillHeight: true
                    horizontalAlignment: Label.AlignHCenter
                    verticalAlignment: Label.AlignVCenter
                }

                TextField {
                    id: passphraseEdit
                    text: ""
                    width: Math.round((auth.width - passphraseLabel.width - passphraseRow.spacing) * 0.35)
                    implicitWidth: Math.round((auth.width - passphraseLabel.width - passphraseRow.spacing) * 0.35)
                    font.pointSize: 12 + auth.fontPadding
                    placeholderText: qsTr("Passphrase")
                    echoMode: TextField.Password
                    passwordMaskDelay: 1000
                    selectByMouse: true
                    renderType: Text.QtRendering

                    horizontalAlignment: TextField.AlignRight
                    verticalAlignment: TextField.AlignVCenter

                    onTextEdited: {
                        auth.passphrase = text
                    }
                }
            }

            CheckBox {
                id: saveCheck
                text: qsTr("Save this setting")
                font.pointSize: 12 + auth.fontPadding
                enabled: auth.editStatus !== 0x00 ? true : false

                Layout.alignment: Qt.AlignVCenter
                Layout.leftMargin: (auth.width - width) / 2

                indicator: Rectangle {
                    y: (saveCheck.height - height) / 2
                    implicitWidth: 30
                    implicitHeight: 30
                    color: "transparent"
                    border.color: auth.bDark ? "white" : "black"
                    opacity: parent.enabled ? saveCheck.down ? 0.5 : 1.0 : 0.2
                    border.width: 2

                    Image {
                        id: imgSaveCheck
                        x: (parent.width - width) / 2
                        y: (parent.height - height) / 2
                        width: parent.width - 10
                        height: parent.height - 10
                        source: "qrc:/Image/Check.png"
                        visible: saveCheck.checked
                    }
                }

                onCheckedChanged: {
                    auth.bSave = checked
                }
            }

            RowLayout {
                width: parent.width
                spacing: 20

                Layout.alignment: Qt.AlignVCenter
                Layout.topMargin: 50
                Layout.leftMargin: (auth.width - width) / 2
                Layout.bottomMargin: 20

                Button {
                    id: nextBtn
                    text: qsTr("Next")
                    enabled: true
                    implicitWidth: 150
                    implicitHeight: 50

                    font.pointSize: 10 + auth.fontPadding

                    contentItem: Label {
                        text: parent.text
                        font: parent.font
                        opacity: enabled ? 1.0 : 0.3
                        color: auth.bDark ? parent.pressed ? "#cccccc" : "#ffffff" : parent.pressed ? "#333333" : "#000000"
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
                        // Save settings for connecting to remote server.
                        if (auth.bSave) {
                            windowState.saveRemoteInfo(auth.hostName, auth.port,           auth.bUseSSL,       auth.bUseCert,
                                                       auth.certFile, auth.bUsePrivateKey, auth.privateKeyFile, auth.bUsePassphrase)
                        }

                        // Next view (Remote Window).
                        parentName.nextViewChanged()
                    }

                    Keys.onReturnPressed: {
                        clicked()
                    }
                }

                Button {
                    id: cancelBtn
                    text: qsTr("Cancel")
                    implicitWidth: 150
                    implicitHeight: 50

                    font.pointSize: 10 + auth.fontPadding

                    contentItem: Label {
                        text: parent.text
                        font: parent.font
                        opacity: enabled ? 1.0 : 0.3
                        color: auth.bDark ? parent.pressed ? "#cccccc" : "#ffffff" : parent.pressed ? "#333333" : "#000000"
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
                        parentName.close()
                    }

                    Keys.onReturnPressed: {
                        clicked()
                    }
                }
            }
        }
    }
}
