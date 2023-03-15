import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Controls.Universal 2.15
import "../ExtendQML"
import WindowState 1.0
import SSHServer 1.0


Item {
    id: root

    property int  viewWidth:   0
    property int  viewHeight:  0
    property int  fontPadding: 0
    property bool bDark:       false
    property bool bServerMode: true

    property bool bReadSuccess:    false
    property var  sshServerConfig: null
    property var  sshValue:        null

    // Signal and Signal Handlers
    // Get path to host key file on remote server.
    Connections {
        target: sshServerConfig
        function onGetAuthorizedKeyFromServer(remoteFilePath) {
            // Set file path for UI.
            authorizedKeysFileList.appendModel(remoteFilePath)
        }
    }

    signal readSuccess()
    onReadSuccess: {
        // Set "PermitRootLogin".
        let PermitRootLogin = sshValue.getItem("PERMITROOTLOGIN")
        PermitRootLogin = String(PermitRootLogin).toUpperCase()
        boxPermitRoot.currentIndex = PermitRootLogin === "YES" ? 0 : 1

        // Set "MaxAuthTries".
        maxAuthTriesEdit.text = sshValue.getItem("MAXAUTHTRIES")

        // Set "MaxSessions"
        maxSessionsEdit.text = sshValue.getItem("MAXSESSIONS")

        // Set "PasswordAuthentication".
        let PasswordAuthentication = sshValue.getItem("PASSWORDAUTHENTICATION")
        PasswordAuthentication = String(PasswordAuthentication).toUpperCase()
        boxPasswordAuthentication.currentIndex = PasswordAuthentication === "YES" ? 0 : 1

        // Set "PermitEmptyPasswords".
        let PermitEmptyPasswords = sshValue.getItem("PERMITEMPTYPASSWORDS")
        PermitEmptyPasswords = String(PermitEmptyPasswords).toUpperCase()
        boxPermitEmptyPasswords.currentIndex = PermitEmptyPasswords === "YES" ? 0 : 1

        // Set "PubkeyAuthentication".
        let PubkeyAuthentication = sshValue.getItem("PUBKEYAUTHENTICATION")
        PubkeyAuthentication = String(PubkeyAuthentication).toUpperCase()
        boxPubkeyAuthentication.currentIndex = PubkeyAuthentication === "YES" ? 0 : 1

        // Set "AuthorizedKeysFile".
        let aryAuthorizedKeysFile = sshValue.getItems("AUTHORIZEDKEYSFILE")
        aryAuthorizedKeysFile.forEach(function(authorizedKeysFile) {
            authorizedKeysFileList.appendModel(authorizedKeysFile)
        });

        // Set "AuthorizedKeysCommand"
        authorizedKeysCommandEdit.text = sshValue.getItem("AUTHORIZEDKEYSCOMMAND")

        // Ser "AuthorizedKeysCommandUser"
        authorizedKeysCommandUserEdit.text = sshValue.getItem("AUTHORIZEDKEYSCOMMANDUSER")

        // Set "HostbasedAuthentication".
        let HostbasedAuthentication = sshValue.getItem("HOSTBASEDAUTHENTICATION")
        HostbasedAuthentication = String(HostbasedAuthentication).toUpperCase()
        boxHostbasedAuthentication.currentIndex = HostbasedAuthentication === "YES" ? 0 : 1

        // Set "IgnoreUserKnownHosts".
        let IgnoreUserKnownHosts = sshValue.getItem("IGNOREUSERKNOWNHOSTS")
        IgnoreUserKnownHosts = String(IgnoreUserKnownHosts).toUpperCase()
        boxIgnoreUserKnownHosts.currentIndex = IgnoreUserKnownHosts === "YES" ? 0 : 1

        // Set "IgnoreRhosts".
        let IgnoreRhosts = sshValue.getItem("IGNORERHOSTS")
        IgnoreRhosts = String(IgnoreRhosts).toUpperCase()
        boxIgnoreRhosts.currentIndex = IgnoreRhosts === "YES" ? 0 : 1

        // Set "ChallengeResponseAuthentication".
        let ChallengeResponseAuthentication = sshValue.getItem("CHALLENGERESPONSEAUTHENTICATION")
        ChallengeResponseAuthentication = String(ChallengeResponseAuthentication).toUpperCase()
        boxChallengeResponseAuthentication.currentIndex = ChallengeResponseAuthentication === "YES" ? 0 : 1

        // Set "UsePAM"
        let UsePAM = sshValue.getItem("USEPAM")
        UsePAM = String(UsePAM).toUpperCase()
        boxUsePAM.currentIndex = UsePAM === "YES" ? 0 : 1

        // Set "PubkeyAuthOptions"
        let PubkeyAuthOptions = sshValue.getItem("PUBKEYAUTHOPTIONS")
        PubkeyAuthOptions = String(PubkeyAuthOptions).toUpperCase()
        boxPubkeyAuthOptions.currentIndex = PubkeyAuthOptions === "NONE" ? 0 : PubkeyAuthOptions === "TOUCH-REQUIRED" ? 1 : 2

        // Set "FingerprintHash"
        let FingerprintHash = sshValue.getItem("FINGERPRINTHASH")
        FingerprintHash = String(FingerprintHash).toUpperCase()
        boxFingerprintHash.currentIndex = FingerprintHash === "SHA256" ? 0 : 1
    }

    signal writeSuccess()
    onWriteSuccess: {
        // Write "PermitRootLogin".
        let PermitRootLogin = boxPermitRoot.currentIndex === 0 ? "yes" : boxPermitRoot.currentIndex === 1 ? "no" :
                              boxPermitRoot.currentIndex === 2 ? "prohibit-password" : "forced-commands-only"
        sshValue.setItem("PERMITROOTLOGIN", PermitRootLogin)

        // Write "MaxAuthTries".
        sshValue.setItem("MAXAUTHTRIES", maxAuthTriesEdit.text)

        // Write "MaxSessions"
        sshValue.setItem("MAXSESSIONS", maxSessionsEdit.text)

        // Write "PasswordAuthentication"
        let PasswordAuthentication = boxPasswordAuthentication.currentIndex === 0 ? "yes" : "no"
        sshValue.setItem("PASSWORDAUTHENTICATION", PasswordAuthentication)

        // Write "PermitEmptyPasswords"
        let PermitEmptyPasswords = boxPermitEmptyPasswords.currentIndex === 0 ? "yes" : "no"
        sshValue.setItem("PERMITEMPTYPASSWORDS", PermitEmptyPasswords)

        // Write "PubkeyAuthentication"
        let PubkeyAuthentication = boxPubkeyAuthentication.currentIndex === 0 ? "yes" : "no"
        sshValue.setItem("PUBKEYAUTHENTICATION", PubkeyAuthentication)

        // Write "AuthorizedKeysFile".
        let aryAuthorizedKeysFile = authorizedKeysFileList.fnGetData()
        sshValue.setItems("AUTHORIZEDKEYSFILE", aryAuthorizedKeysFile)

        // Write "AuthorizedKeysCommand".
        let AuthorizedKeysCommand = authorizedKeysCommandEdit.text.trim()
        sshValue.setItems("AUTHORIZEDKEYSCOMMAND", AuthorizedKeysCommand)

        // Write "AuthorizedKeysCommandUser".
        let AuthorizedKeysCommandUser = authorizedKeysCommandUserEdit.text.trim()
        sshValue.setItems("AUTHORIZEDKEYSCOMMANDUSER", AuthorizedKeysCommandUser)

        // Write "HostbasedAuthentication"
        let HostbasedAuthentication = boxHostbasedAuthentication.currentIndex === 0 ? "yes" : "no"
        sshValue.setItem("HOSTBASEDAUTHENTICATION", HostbasedAuthentication)

        // Write "IgnoreUserKnownHosts"
        let IgnoreUserKnownHosts = boxIgnoreUserKnownHosts.currentIndex === 0 ? "yes" : "no"
        sshValue.setItem("IGNOREUSERKNOWNHOSTS", IgnoreUserKnownHosts)

        // Write "IgnoreRhosts"
        let IgnoreRhosts = boxIgnoreRhosts.currentIndex === 0 ? "yes" : "no"
        sshValue.setItem("IGNORERHOSTS", IgnoreRhosts)

        // Write "ChallengeResponseAuthentication"
        let ChallengeResponseAuthentication = boxChallengeResponseAuthentication.currentIndex === 0 ? "yes" : "no"
        sshValue.setItem("CHALLENGERESPONSEAUTHENTICATION", ChallengeResponseAuthentication)

        // Write "UsePAM"
        let UsePAM = boxUsePAM.currentIndex === 0 ? "yes" : "no"
        sshValue.setItem("USEPAM", UsePAM)

        // Write "PubkeyAuthOptions".
        let PubkeyAuthOptions = boxPubkeyAuthOptions.currentIndex === 0 ? "none" :
                                boxPubkeyAuthOptions.currentIndex === 1 ? "touch-required" : "verify-required"
        sshValue.setItem("PUBKEYAUTHOPTIONS", PubkeyAuthOptions)

        // Write "FingerprintHash"
        let FingerprintHash = boxFingerprintHash.currentIndex === 0 ? "SHA256" : "MD5"
        sshValue.setItem("FINGERPRINTHASH", FingerprintHash)
    }

    signal clear()
    onClear: {
        // PermitRootLogin
        boxPermitRoot.currentIndex = 0

        // MaxAuthTries
        maxAuthTriesEdit.text = ""

        // MaxSessions
        maxSessionsEdit.text = ""

        // PasswordAuthentication
        boxPasswordAuthentication.currentIndex = 0

        // PermitEmptyPasswords
        boxPermitEmptyPasswords.currentIndex = 0

        // PubkeyAuthentication
        boxPubkeyAuthentication.currentIndex = 0

        // AuthorizedKeysFile
        authorizedKeysFileList.clearModel()

        // AuthorizedKeysCommand
        authorizedKeysCommandEdit.text = ""

        // AuthorizedKeysCommandUser
        authorizedKeysCommandUserEdit.text = ""

        // HostbasedAuthentication
        boxHostbasedAuthentication.currentIndex = 0

        // IgnoreUserKnownHosts
        boxIgnoreUserKnownHosts.currentIndex = 0

        // IgnoreRhosts
        boxIgnoreRhosts.currentIndex = 0

        // ChallengeResponseAuthentication
        boxChallengeResponseAuthentication.currentIndex = 0

        // UsePAM
        boxUsePAM.currentIndex = 0

        // PubkeyAuthOptions
        boxPubkeyAuthOptions.currentIndex = 0

        // FingerprintHash
        boxFingerprintHash.currentIndex = 0
    }

    ScrollView {
        id: scrollAuthentication
        width: parent.width
        height : parent.height
        contentWidth: authenticationColumn.width    // The important part
        contentHeight: authenticationColumn.height  // Same
        clip: true                                  // Prevent drawing column outside the scrollview borders

        ScrollBar.vertical.policy: ScrollBar.AlwaysOn
        ScrollBar.vertical.visible: ScrollBar.vertical.size < 1
        ScrollBar.vertical.interactive: true

        Layout.alignment: Qt.AlignCenter
        Layout.fillWidth: true
        Layout.fillHeight: true

        ColumnLayout {
            id: authenticationColumn
            width: root.viewWidth

            // PermitRootLogin
            Label {
                id: permitRootLabel
                text: qsTr("Allow root login :") + "<br>" + "(PermitRootLogin)"
                font.pointSize: 12 + root.fontPadding

                wrapMode: Label.WordWrap

                Layout.fillHeight: true
                verticalAlignment: Label.AlignVCenter

                Layout.topMargin: 20
            }

            Label {
                text: "<b><u>prohibit-password</u></b> :" + "<br>" +
                      qsTr("Disable password and keyboard interactive authentication.") + "<br><br>" +
                      "<b><u>forced-commands-only</u></b> :" + "<br>" +
                      qsTr("Deny direct login, but allow access to commands that use root privileges.") + "<br>" +
                      qsTr("(root login with public key authentication is allowed.)")
                font.pointSize: 10 + root.fontPadding

                textFormat: Label.RichText
                wrapMode: Label.WordWrap

                verticalAlignment: Label.AlignVCenter
                Layout.preferredWidth: parent.width - 10
                Layout.fillHeight: true
            }

            ComboBox {
                id: boxPermitRoot
                implicitWidth: 380
                font.pointSize: 12 + root.fontPadding

                delegate: ItemDelegate {
                    id: delegatePermitRoot
                    width: boxPermitRoot.implicitWidth
                    height: boxPermitRoot.implicitHeight
                    highlighted: boxPermitRoot.highlightedIndex === index

                    background: Rectangle {
                        color: highlighted ? root.bDark ? "steelblue" : "orchid" : "transparent"
                    }

                    contentItem: Rectangle {
                        id: delegateRectPermitRoot
                        width: parent.width
                        height: parent.height
                        color: "transparent"

                        Label {
                            id: textPermitRoot
                            text: modelData
                            font.pointSize: 12 + root.fontPadding
                            elide: Label.ElideRight
                            verticalAlignment: Label.AlignVCenter
                            horizontalAlignment: Label.AlignLeft
                        }
                    }
                }

                contentItem: Label {
                    text: parent.displayText
                    font: parent.font
                    padding: 10
                    verticalAlignment: Label.AlignVCenter
                }

                background: Rectangle {
                    color: "transparent"
                    border.width: 2
                    border.color: "grey"
                }

                model: ListModel {
                    id: permitRootModel
                    ListElement { text: "Yes" }
                    ListElement { text: "No" }
                    ListElement { text: "prohibit-password" }
                    ListElement { text: "forced-commands-only" }
                }
            }

            // MaxAuthTries
            Label {
                id: maxAuthTriesLabel
                text: qsTr("Retry Maximum number of authentication :") + "<br>" + "(MaxAuthTries)"
                font.pointSize: 12 + root.fontPadding

                wrapMode: Label.WordWrap

                Layout.fillHeight: true
                verticalAlignment: Label.AlignVCenter

                Layout.topMargin: 30
            }

            Label {
                text: qsTr("When more than half of the specified values of authentication fail, subsequent failures are logged.")
                font.pointSize: 10 + root.fontPadding

                wrapMode: Label.WordWrap

                verticalAlignment: Label.AlignVCenter
                Layout.preferredWidth: parent.width - 10
                Layout.fillHeight: true
            }

            TextField {
                id: maxAuthTriesEdit
                text: ""
                implicitWidth: root.viewWidth * 0.35
                font.pointSize: 12 + root.fontPadding
                placeholderText: qsTr("default is 6")

                horizontalAlignment: TextField.AlignRight
                verticalAlignment: TextField.AlignVCenter

                // Input limit (>= 1)
                validator: RegExpValidator {
                    regExp: /[1-9][0-9]*/
                }
            }

            // MaxSessions
            Label {
                id: maxSessionsLabel
                text: qsTr("Maximum simultaneous connections :") + "<br>" + "(MaxSessions)"
                font.pointSize: 12 + root.fontPadding

                wrapMode: Label.WordWrap

                Layout.fillHeight: true
                verticalAlignment: Label.AlignVCenter

                Layout.topMargin: 30
            }

            Label {
                text: qsTr("Specifies the maximum number of shell, login, subsystem(e.g. sftp) sessions permitted per network connection.") + "<br>" +
                      qsTr("MaxSessions to \"1\" will effectively disable session multiplexing.") + "<br>" +
                      qsTr("MaxSessions to \"0\" disables all shell, login, and subsystem sessions, but allows transfers.")
                font.pointSize: 10 + root.fontPadding

                textFormat: Label.RichText
                wrapMode: Label.WordWrap

                verticalAlignment: Label.AlignVCenter
                Layout.preferredWidth: parent.width - 10
                Layout.fillHeight: true
            }

            TextField {
                id: maxSessionsEdit
                text: ""
                implicitWidth: root.viewWidth * 0.35
                font.pointSize: 12 + root.fontPadding
                placeholderText: qsTr("default is 10")

                horizontalAlignment: TextField.AlignRight
                verticalAlignment: TextField.AlignVCenter

                // Input limit (>= 0)
                validator: RegExpValidator {
                    regExp: /[0-9]*/
                }
            }

            // PasswordAuthentication
            Label {
                id: passwordAuthenticationLabel
                text: qsTr("Allow password authentication :") + "<br>" + "(PasswordAuthentication)"
                font.pointSize: 12 + root.fontPadding

                wrapMode: Label.WordWrap

                Layout.fillHeight: true
                verticalAlignment: Label.AlignVCenter

                Layout.topMargin: 30
            }

            ComboBox {
                id: boxPasswordAuthentication
                implicitWidth: 300
                font.pointSize: 12 + root.fontPadding

                delegate: ItemDelegate {
                    id: delegatePasswordAuthentication
                    width: boxPasswordAuthentication.implicitWidth
                    height: boxPasswordAuthentication.implicitHeight
                    highlighted: boxPasswordAuthentication.highlightedIndex === index

                    background: Rectangle {
                        color: highlighted ? root.bDark ? "steelblue" : "orchid" : "transparent"
                    }

                    contentItem: Rectangle {
                        id: delegateRectPasswordAuthentication
                        width: parent.width
                        height: parent.height
                        color: "transparent"

                        Label {
                            id: textPasswordAuthentication
                            text: modelData
                            font.pointSize: 12 + root.fontPadding
                            elide: Label.ElideRight
                            verticalAlignment: Label.AlignVCenter
                            horizontalAlignment: Label.AlignLeft
                        }
                    }
                }

                contentItem: Label {
                    text: parent.displayText
                    font: parent.font
                    padding: 10
                    verticalAlignment: Label.AlignVCenter
                }

                background: Rectangle {
                    color: "transparent"
                    border.width: 2
                    border.color: "grey"
                }

                model: ListModel {
                    id: passwordAuthenticationModel
                    ListElement { text: "Yes" }
                    ListElement { text: "No" }
                }
            }

            // PermitEmptyPasswords
            Label {
                id: permitEmptyPasswordsLabel
                text: qsTr("Allow login for accounts with empty passwords :") + "<br>" + "(PermitEmptyPasswords)"
                font.pointSize: 12 + root.fontPadding

                wrapMode: Label.WordWrap

                verticalAlignment: Label.AlignVCenter
                Layout.preferredWidth: parent.width - 10
                Layout.fillHeight: true

                Layout.topMargin: 30
            }

            ComboBox {
                id: boxPermitEmptyPasswords
                implicitWidth: 300
                font.pointSize: 12 + root.fontPadding

                delegate: ItemDelegate {
                    id: delegatePermitEmptyPasswords
                    width: boxPermitEmptyPasswords.implicitWidth
                    height: boxPermitEmptyPasswords.implicitHeight
                    highlighted: boxPermitEmptyPasswords.highlightedIndex === index

                    background: Rectangle {
                        color: highlighted ? root.bDark ? "steelblue" : "orchid" : "transparent"
                    }

                    contentItem: Rectangle {
                        id: delegateRectPermitEmptyPasswords
                        width: parent.width
                        height: parent.height
                        color: "transparent"

                        Label {
                            id: textPermitEmptyPasswords
                            text: modelData
                            font.pointSize: 12 + root.fontPadding
                            elide: Label.ElideRight
                            verticalAlignment: Label.AlignVCenter
                            horizontalAlignment: Label.AlignLeft
                        }
                    }
                }

                contentItem: Label {
                    text: parent.displayText
                    font: parent.font
                    padding: 10
                    verticalAlignment: Label.AlignVCenter
                }

                background: Rectangle {
                    color: "transparent"
                    border.width: 2
                    border.color: "grey"
                }

                model: ListModel {
                    id: permitEmptyPasswordsModel
                    ListElement { text: "Yes" }
                    ListElement { text: "No" }
                }
            }

            // PubkeyAuthentication
            Label {
                id: pubkeyAuthenticationLabel
                text: qsTr("Allow public key authentication :") + "<br>" + "(PubkeyAuthentication)"
                font.pointSize: 12 + root.fontPadding

                wrapMode: Label.WordWrap

                verticalAlignment: Label.AlignVCenter
                Layout.preferredWidth: parent.width - 10
                Layout.fillHeight: true

                Layout.topMargin: 30
            }

            ComboBox {
                id: boxPubkeyAuthentication
                implicitWidth: 300
                font.pointSize: 12 + root.fontPadding

                delegate: ItemDelegate {
                    id: delegatePubkeyAuthentication
                    width: boxPubkeyAuthentication.implicitWidth
                    height: boxPubkeyAuthentication.implicitHeight
                    highlighted: boxPubkeyAuthentication.highlightedIndex === index

                    background: Rectangle {
                        color: highlighted ? root.bDark ? "steelblue" : "orchid" : "transparent"
                    }

                    contentItem: Rectangle {
                        id: delegateRectPubkeyAuthentication
                        width: parent.width
                        height: parent.height
                        color: "transparent"

                        Label {
                            id: textPubkeyAuthentication
                            text: modelData
                            font.pointSize: 12 + root.fontPadding
                            elide: Label.ElideRight
                            verticalAlignment: Label.AlignVCenter
                            horizontalAlignment: Label.AlignLeft
                        }
                    }
                }

                contentItem: Label {
                    text: parent.displayText
                    font: parent.font
                    padding: 10
                    verticalAlignment: Label.AlignVCenter
                }

                background: Rectangle {
                    color: "transparent"
                    border.width: 2
                    border.color: "grey"
                }

                model: ListModel {
                    id: pubkeyAuthenticationModel
                    ListElement { text: "Yes" }
                    ListElement { text: "No" }
                }
            }

            // AuthorizedKeysFile
            Label {
                id: authorizedKeysFileLabel
                text: qsTr("Path to public key file stored on SSH server :") + "<br>" + "(AuthorizedKeysFile)"
                font.pointSize: 12 + root.fontPadding

                textFormat: Label.RichText
                wrapMode: Label.WordWrap

                verticalAlignment: Label.AlignVCenter
                Layout.preferredWidth: parent.width - 10
                Layout.fillHeight: true
                Layout.topMargin: 30
            }

            Label {
                text: qsTr("Specify file name that contains public key used for authentication.") + "<br>" +
                      qsTr("Input absolute path or relative path from the user's home directory.")
                font.pointSize: 10 + root.fontPadding

                textFormat: Label.RichText
                wrapMode: Label.WordWrap

                verticalAlignment: Label.AlignVCenter
                Layout.preferredWidth: parent.width - 10
                Layout.fillHeight: true
            }

            RowLayout {
                id: authorizedKeysFileRow
                spacing: 20

                RoundButton {
                    id: btnFileSelect
                    text: ""
                    width: 48
                    height: 48

                    icon.source: pressed ? "qrc:/Image/KeyFileButtonPressed.png" : "qrc:/Image/KeyFileButton.png"
                    icon.width: width
                    icon.height: height
                    icon.color: "transparent"

                    padding: 0

                    background: Rectangle {
                        color: "transparent"
                    }

                    onClicked: {
                        let iRet = 0

                        if (root.bServerMode) selectAuthorizedKeysFileDialog.open()
                        else                  iRet = sshServerConfig.getAuthorizedKeyFile(root.width, root.height, root.bDark, root.fontPadding)

                        if (iRet !== 0) {
                            // Display error message.
                            let errMsg = sshServerConfig.getErrorMessage()

                            let componentDialog = Qt.createComponent("qrc:/ExtendQML/ErrorDialogPP.qml");
                            if (componentDialog.status === Component.Ready) {
                                let errorDialog = componentDialog.createObject(root,
                                                                               {mainWidth: root.width, mainHeight: root.height, bDark: root.bDark,
                                                                                messageTitle: qsTr("Error"),
                                                                                messageText: qsTr("Failed to download key file.") + "<br>" + errMsg});
                                errorDialog.show();
                            }
                        }
                    }

                    SelectFileDialog {
                        id: selectAuthorizedKeysFileDialog
                        mainWidth: root.viewWidth
                        mainHeight: root.viewHeight
                        filters: "Authorized key file (*)"

                        onSelectedFile: {
                            authorizedKeysFileList.appendModel(strFilePath)
                        }
                    }
                }

                RoundButton {
                    id: btnAddAuthorizedKeysFile
                    text: ""
                    width: 48
                    height: 48

                    icon.source: pressed ? "qrc:/Image/AddPressed.png" : "qrc:/Image/Add.png"
                    icon.width: width
                    icon.height: height
                    icon.color: "transparent"

                    padding: 0

                    background: Rectangle {
                        color: "transparent"
                    }

                    onClicked: {
                        authorizedKeysFileList.appendModel("")
                    }
                }
            }

            SSHOptionListViewPP {
                id: authorizedKeysFileList
                width: parent.width * 0.85
                implicitWidth: parent.width * 0.85
                fontPadding: root.fontPadding
                bDark: root.bDark
            }

            // AuthorizedKeysCommand
            Label {
                id: authorizedKeysCommandLabel
                text: qsTr("Specify command used to get public key :") + "<br>" + "(AuthorizedKeysCommand)"
                font.pointSize: 12 + root.fontPadding

                wrapMode: Label.WordWrap

                Layout.fillHeight: true
                verticalAlignment: Label.AlignVCenter

                Layout.topMargin: 30
            }

            TextField {
                id: authorizedKeysCommandEdit
                text: ""
                implicitWidth: root.viewWidth * 0.8
                font.pointSize: 12 + root.fontPadding
                placeholderText: qsTr("default is none")

                horizontalAlignment: TextField.AlignRight
                verticalAlignment: TextField.AlignVCenter
            }

            // AuthorizedKeysCommandUser
            Label {
                id: authorizedKeysCommandUserLabel
                text: qsTr("Specify user that execute command used to get public key :") + "<br>" +
                      "(AuthorizedKeysCommandUser)"
                font.pointSize: 12 + root.fontPadding

                wrapMode: Label.WordWrap

                verticalAlignment: Label.AlignVCenter
                Layout.preferredWidth: parent.width - 10
                Layout.fillHeight: true

                Layout.topMargin: 30
            }

            TextField {
                id: authorizedKeysCommandUserEdit
                text: ""
                implicitWidth: root.viewWidth * 0.8
                font.pointSize: 12 + root.fontPadding
                placeholderText: qsTr("default is none")

                horizontalAlignment: TextField.AlignRight
                verticalAlignment: TextField.AlignVCenter
            }

            // HostbasedAuthentication
            Label {
                id: hostbasedAuthenticationLabel
                text: qsTr("Allow rhosts or /etc/hosts.equiv authentication upon successful public key authentication :") + "<br>" +
                      "(HostbasedAuthentication)"
                font.pointSize: 12 + root.fontPadding

                wrapMode: Label.WordWrap

                verticalAlignment: Label.AlignVCenter
                Layout.preferredWidth: parent.width - 10
                Layout.fillHeight: true

                Layout.topMargin: 30
            }

            ComboBox {
                id: boxHostbasedAuthentication
                implicitWidth: 300
                font.pointSize: 12 + root.fontPadding

                delegate: ItemDelegate {
                    id: delegateHostbasedAuthentication
                    width: boxHostbasedAuthentication.implicitWidth
                    height: boxHostbasedAuthentication.implicitHeight
                    highlighted: boxHostbasedAuthentication.highlightedIndex === index

                    background: Rectangle {
                        color: highlighted ? root.bDark ? "steelblue" : "orchid" : "transparent"
                    }

                    contentItem: Rectangle {
                        id: delegateRectHostbasedAuthentication
                        width: parent.width
                        height: parent.height
                        color: "transparent"

                        Label {
                            id: textHostbasedAuthentication
                            text: modelData
                            font.pointSize: 12 + root.fontPadding
                            elide: Label.ElideRight
                            verticalAlignment: Label.AlignVCenter
                            horizontalAlignment: Label.AlignLeft
                        }
                    }
                }

                contentItem: Label {
                    text: parent.displayText
                    font: parent.font
                    padding: 10
                    verticalAlignment: Label.AlignVCenter
                }

                background: Rectangle {
                    color: "transparent"
                    border.width: 2
                    border.color: "grey"
                }

                model: ListModel {
                    id: hostbasedAuthenticationModel
                    ListElement { text: "Yes" }
                    ListElement { text: "No" }
                }
            }

            // IgnoreUserKnownHosts
            Label {
                id: ignoreUserKnownHostsLabel
                text: qsTr("Do not use ~/.ssh/known_hosts file for RhostsRSAAuthentication or HostbasedAuthentication authentication :") + "<br>" +
                      "(IgnoreUserKnownHosts)"
                font.pointSize: 12 + root.fontPadding

                wrapMode: Label.WordWrap

                verticalAlignment: Label.AlignVCenter
                Layout.preferredWidth: parent.width - 10
                Layout.fillHeight: true

                Layout.topMargin: 30
            }

            ComboBox {
                id: boxIgnoreUserKnownHosts
                implicitWidth: 300
                font.pointSize: 12 + root.fontPadding

                delegate: ItemDelegate {
                    id: delegateIgnoreUserKnownHosts
                    width: boxIgnoreUserKnownHosts.implicitWidth
                    height: boxIgnoreUserKnownHosts.implicitHeight
                    highlighted: boxIgnoreUserKnownHosts.highlightedIndex === index

                    background: Rectangle {
                        color: highlighted ? root.bDark ? "steelblue" : "orchid" : "transparent"
                    }

                    contentItem: Rectangle {
                        id: delegateRectIgnoreUserKnownHosts
                        width: parent.width
                        height: parent.height
                        color: "transparent"

                        Label {
                            id: textIgnoreUserKnownHosts
                            text: modelData
                            font.pointSize: 12 + root.fontPadding
                            elide: Label.ElideRight
                            verticalAlignment: Label.AlignVCenter
                            horizontalAlignment: Label.AlignLeft
                        }
                    }
                }

                contentItem: Label {
                    text: parent.displayText
                    font: parent.font
                    padding: 10
                    verticalAlignment: Label.AlignVCenter
                }

                background: Rectangle {
                    color: "transparent"
                    border.width: 2
                    border.color: "grey"
                }

                model: ListModel {
                    id: ignoreUserKnownHostsModel
                    ListElement { text: "Yes" }
                    ListElement { text: "No" }
                }
            }

            // IgnoreRhosts
            Label {
                id: ignoreRhostsLabel
                text: qsTr("Do not use .rhosts and .shosts in RhostsRSAAuthentication or HostbasedAuthentication authentication :") + "<br>" +
                      "(IgnoreRhosts)"
                font.pointSize: 12 + root.fontPadding

                wrapMode: Label.WordWrap

                verticalAlignment: Label.AlignVCenter
                Layout.preferredWidth: parent.width - 10
                Layout.fillHeight: true

                Layout.topMargin: 30
            }

            ComboBox {
                id: boxIgnoreRhosts
                implicitWidth: 300
                font.pointSize: 12 + root.fontPadding

                delegate: ItemDelegate {
                    id: delegateIgnoreRhosts
                    width: boxIgnoreRhosts.implicitWidth
                    height: boxIgnoreRhosts.implicitHeight
                    highlighted: boxIgnoreRhosts.highlightedIndex === index

                    background: Rectangle {
                        color: highlighted ? root.bDark ? "steelblue" : "orchid" : "transparent"
                    }

                    contentItem: Rectangle {
                        id: delegateRectIgnoreRhosts
                        width: parent.width
                        height: parent.height
                        color: "transparent"

                        Label {
                            id: textIgnoreRhosts
                            text: modelData
                            font.pointSize: 12 + root.fontPadding
                            elide: Label.ElideRight
                            verticalAlignment: Label.AlignVCenter
                            horizontalAlignment: Label.AlignLeft
                        }
                    }
                }

                contentItem: Label {
                    text: parent.displayText
                    font: parent.font
                    padding: 10
                    verticalAlignment: Label.AlignVCenter
                }

                background: Rectangle {
                    color: "transparent"
                    border.width: 2
                    border.color: "grey"
                }

                model: ListModel {
                    id: ignoreRhostsModel
                    ListElement { text: "Yes" }
                    ListElement { text: "No" }
                }
            }

            // ChallengeResponseAuthentication (KbdInteractiveAuthentication)
            Label {
                id: challengeResponseAuthenticationLabel
                text: qsTr("Allow challenge response authentication") + "<br>" +
                      "(ChallengeResponseAuthentication) or (KbdInteractiveAuthentication)"
                font.pointSize: 12 + root.fontPadding

                wrapMode: Label.WordWrap

                verticalAlignment: Label.AlignVCenter
                Layout.preferredWidth: parent.width - 10
                Layout.fillHeight: true

                Layout.topMargin: 30
            }

            Label {
                text: qsTr("Allow keyboard interactive authentication.") + "<br>" +
                      qsTr("All authentication in login.conf is supported.") + "<br>" +
                      "<u>" + qsTr("Note : UsePAM must be set to \"Yes\", in order to authenticate using PAM.") + "</u>"
                font.pointSize: 10 + root.fontPadding

                textFormat: Label.RichText
                wrapMode: Label.WordWrap

                verticalAlignment: Label.AlignVCenter
                Layout.preferredWidth: parent.width - 10
                Layout.fillHeight: true
            }

            ComboBox {
                id: boxChallengeResponseAuthentication
                implicitWidth: 300
                font.pointSize: 12 + root.fontPadding

                delegate: ItemDelegate {
                    id: delegateChallengeResponseAuthentication
                    width: boxChallengeResponseAuthentication.implicitWidth
                    height: boxChallengeResponseAuthentication.implicitHeight
                    highlighted: boxChallengeResponseAuthentication.highlightedIndex === index

                    background: Rectangle {
                        color: highlighted ? root.bDark ? "steelblue" : "orchid" : "transparent"
                    }

                    contentItem: Rectangle {
                        id: delegateRectChallengeResponseAuthentication
                        width: parent.width
                        height: parent.height
                        color: "transparent"

                        Label {
                            id: textChallengeResponseAuthentication
                            text: modelData
                            font.pointSize: 12 + root.fontPadding
                            elide: Label.ElideRight
                            verticalAlignment: Label.AlignVCenter
                            horizontalAlignment: Label.AlignLeft
                        }
                    }
                }

                contentItem: Label {
                    text: parent.displayText
                    font: parent.font
                    padding: 10
                    verticalAlignment: Label.AlignVCenter
                }

                background: Rectangle {
                    color: "transparent"
                    border.width: 2
                    border.color: "grey"
                }

                model: ListModel {
                    id: challengeResponseAuthenticationModel
                    ListElement { text: "Yes" }
                    ListElement { text: "No" }
                }
            }

            // UsePAM
            Label {
                id: usePAMLabel
                text: qsTr("Allow authentication by PAM (Pluggable Authentication Module) interface :")  + "<br>" +
                      "(UsePAM)"
                font.pointSize: 12 + root.fontPadding

                wrapMode: Label.WordWrap

                verticalAlignment: Label.AlignVCenter
                Layout.preferredWidth: parent.width - 10
                Layout.fillHeight: true

                Layout.topMargin: 30
            }

            Label {
                text: qsTr("If set to yes, either \"PasswordAuthentication\" or \"ChallengeResponseAuthentication\" must be set to yes.") + "<br>" +
                      qsTr("Note : Then, \"sshd\" command cannot be run as non-root user.")
                font.pointSize: 10 + root.fontPadding

                textFormat: Label.RichText
                wrapMode: Label.WordWrap

                verticalAlignment: Label.AlignVCenter
                Layout.preferredWidth: parent.width - 10
                Layout.fillHeight: true
            }

            ComboBox {
                id: boxUsePAM
                implicitWidth: 300
                font.pointSize: 12 + root.fontPadding

                delegate: ItemDelegate {
                    id: delegateUsePAM
                    width: boxUsePAM.implicitWidth
                    height: boxUsePAM.implicitHeight
                    highlighted: boxUsePAM.highlightedIndex === index

                    background: Rectangle {
                        color: highlighted ? root.bDark ? "steelblue" : "orchid" : "transparent"
                    }

                    contentItem: Rectangle {
                        id: delegateRectUsePAM
                        width: parent.width
                        height: parent.height
                        color: "transparent"

                        Label {
                            id: textUsePAM
                            text: modelData
                            font.pointSize: 12 + root.fontPadding
                            elide: Label.ElideRight
                            verticalAlignment: Label.AlignVCenter
                            horizontalAlignment: Label.AlignLeft
                        }
                    }
                }

                contentItem: Label {
                    text: parent.displayText
                    font: parent.font
                    padding: 10
                    verticalAlignment: Label.AlignVCenter
                }

                background: Rectangle {
                    color: "transparent"
                    border.width: 2
                    border.color: "grey"
                }

                model: ListModel {
                    id: usePAMModel
                    ListElement { text: "Yes" }
                    ListElement { text: "No" }
                }
            }

            // PubkeyAuthOptions
            Label {
                id: pubkeyAuthOptionsLabel
                text: qsTr("Public key authentication option :") + "<br>" + "(PubkeyAuthOptions)"
                font.pointSize: 12 + root.fontPadding

                wrapMode: Label.WordWrap

                Layout.fillHeight: true
                verticalAlignment: Label.AlignVCenter

                Layout.topMargin: 30
            }

            Label {
                text: "<b><u>none</u></b> :" + "<br>" +
                      qsTr("Require user unless overridden by \"AuthorizedKeysFile\" option.") + "<br><br>" +
                      "<b><u>touch-required</u></b> :" + "<br>" +
                      qsTr("Public key authentication using FIDO authentication algorithm (ecdsa-sk or ed25519-sk),") + "<br>" +
                      qsTr("which always requires signature attesting that user present has explicitly confirmed authentication.") + "<br>" +
                      qsTr("In this case, overriding with the \"AuthorizedKeysFile\" option is disabled.") + "<br><br>" +
                      "<b><u>verify-required</u></b> :" + "<br>" +
                      qsTr("Require FIDO key signature that proves that user has been authenticated with PIN, etc.")
                font.pointSize: 10 + root.fontPadding

                textFormat: Label.RichText
                wrapMode: Label.WordWrap

                verticalAlignment: Label.AlignVCenter
                Layout.preferredWidth: parent.width - 10
                Layout.fillHeight: true
            }

            ComboBox {
                id: boxPubkeyAuthOptions
                implicitWidth: 300
                font.pointSize: 12 + root.fontPadding

                delegate: ItemDelegate {
                    id: delegatePubkeyAuthOptions
                    width: boxPubkeyAuthOptions.implicitWidth
                    height: boxPubkeyAuthOptions.implicitHeight
                    highlighted: boxPubkeyAuthOptions.highlightedIndex === index

                    background: Rectangle {
                        color: highlighted ? root.bDark ? "steelblue" : "orchid" : "transparent"
                    }

                    contentItem: Rectangle {
                        id: delegateRectPubkeyAuthOptions
                        width: parent.width
                        height: parent.height
                        color: "transparent"

                        Label {
                            id: textPubkeyAuthOptions
                            text: modelData
                            font.pointSize: 12 + root.fontPadding
                            elide: Label.ElideRight
                            verticalAlignment: Label.AlignVCenter
                            horizontalAlignment: Label.AlignLeft
                        }
                    }
                }

                contentItem: Label {
                    text: parent.displayText
                    font: parent.font
                    padding: 10
                    verticalAlignment: Label.AlignVCenter
                }

                background: Rectangle {
                    color: "transparent"
                    border.width: 2
                    border.color: "grey"
                }

                model: ListModel {
                    id: pubkeyAuthOptionsModel
                    ListElement { text: "none" }
                    ListElement { text: "touch-required" }
                    ListElement { text: "verify-required" }
                }
            }

            // FingerprintHash
            Label {
                id: fingerprintHashLabel
                text: qsTr("Hash algorithm used when logging fingerprint :") + "<br>" + "(FingerprintHash)"
                font.pointSize: 12 + root.fontPadding

                wrapMode: Label.WordWrap

                verticalAlignment: Label.AlignVCenter
                Layout.preferredWidth: parent.width - 10
                Layout.fillHeight: true

                Layout.topMargin: 30
            }

            ComboBox {
                id: boxFingerprintHash
                implicitWidth: 300
                font.pointSize: 12 + root.fontPadding

                Layout.bottomMargin: 50

                delegate: ItemDelegate {
                    id: delegateFingerprintHash
                    width: boxFingerprintHash.implicitWidth
                    height: boxFingerprintHash.implicitHeight
                    highlighted: boxFingerprintHash.highlightedIndex === index

                    background: Rectangle {
                        color: highlighted ? root.bDark ? "steelblue" : "orchid" : "transparent"
                    }

                    contentItem: Rectangle {
                        id: delegateRectFingerprintHash
                        width: parent.width
                        height: parent.height
                        color: "transparent"

                        Label {
                            id: textFingerprintHash
                            text: modelData
                            font.pointSize: 12 + root.fontPadding
                            elide: Label.ElideRight
                            verticalAlignment: Label.AlignVCenter
                            horizontalAlignment: Label.AlignLeft
                        }
                    }
                }

                contentItem: Label {
                    text: parent.displayText
                    font: parent.font
                    padding: 10
                    verticalAlignment: Label.AlignVCenter
                }

                background: Rectangle {
                    color: "transparent"
                    border.width: 2
                    border.color: "grey"
                }

                model: ListModel {
                    id: fingerprintHashModel
                    ListElement { text: "SHA256" }
                    ListElement { text: "MD5" }
                }
            }
        }
    }
}
