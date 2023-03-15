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

    property bool bReadSuccess: false
    property var  sshValue:     null

    // Signal and Signal Handlers
    signal readSuccess()
    onReadSuccess: {
        // Set "KerberosAuthentication".
        let KerberosAuthentication = sshValue.getItem("KERBEROSAUTHENTICATION")
        KerberosAuthentication = String(KerberosAuthentication).toUpperCase()
        boxKerberosAuthentication.currentIndex = KerberosAuthentication === "YES" ? 0 : 1

        // Set "KerberosOrLocalPasswd".
        let KerberosOrLocalPasswd = sshValue.getItem("KERBEROSORLOCALPASSWD")
        KerberosOrLocalPasswd = String(KerberosOrLocalPasswd).toUpperCase()
        boxKerberosOrLocalPasswd.currentIndex = KerberosOrLocalPasswd === "YES" ? 0 : 1

        // Set "KerberosTicketCleanup".
        let KerberosTicketCleanup = sshValue.getItem("KERBEROSTICKETCLEANUP")
        KerberosTicketCleanup = String(KerberosTicketCleanup).toUpperCase()
        boxKerberosTicketCleanup.currentIndex = KerberosTicketCleanup === "YES" ? 0 : 1

        // Set "GSSAPIAuthentication".
        let GSSAPIAuthentication = sshValue.getItem("GSSAPIAUTHENTICATION")
        GSSAPIAuthentication = String(GSSAPIAuthentication).toUpperCase()
        boxGSSAPIAuthentication.currentIndex = GSSAPIAuthentication === "YES" ? 0 : 1

        // Set "GSSAPICleanupCredentials".
        let GSSAPICleanupCredentials = sshValue.getItem("GSSAPICLEANUPCREDENTIALS")
        GSSAPICleanupCredentials = String(GSSAPICleanupCredentials).toUpperCase()
        boxGSSAPICleanupCredentials.currentIndex = GSSAPICleanupCredentials === "YES" ? 0 : 1

        // Set "GSSAPIStrictAcceptorCheck".
        let GSSAPIStrictAcceptorCheck = sshValue.getItem("GSSAPISTRICTACCEPTORCHECK")
        GSSAPIStrictAcceptorCheck = String(GSSAPIStrictAcceptorCheck).toUpperCase()
        boxGSSAPIStrictAcceptorCheck.currentIndex = GSSAPIStrictAcceptorCheck === "YES" ? 0 : 1

        // Set "GSSAPIKeyExchange".
        let GSSAPIKeyExchange = sshValue.getItem("GSSAPIKEYEXCHANGE")
        GSSAPIKeyExchange = String(GSSAPIKeyExchange).toUpperCase()
        boxGSSAPIKeyExchange.currentIndex = GSSAPIKeyExchange === "YES" ? 0 : 1

        // Set "GSSAPIStoreCredentialSonreKey".
        let GSSAPIStoreCredentialSonreKey = sshValue.getItem("GSSAPISTORECREDENTIALSONREKEY")
        GSSAPIStoreCredentialSonreKey = String(GSSAPIStoreCredentialSonreKey).toUpperCase()
        boxGSSAPIStoreCredentialSonreKey.currentIndex = GSSAPIStoreCredentialSonreKey === "YES" ? 0 : 1

        // Set "GSSAPIKexAlgorithms".
        let GSSAPIKexAlgorithms = sshValue.getItems("GSSAPIKEXALGORITHMS")
        let aryGSSAPIKexAlgorithms = String(GSSAPIKexAlgorithms).split(",")
        aryGSSAPIKexAlgorithms.forEach(function(Value) {
            gSSAPIKexAlgorithmsList.appendModel(Value)
        });
    }

    signal writeSuccess()
    onWriteSuccess: {
        // Write "KerberosAuthentication".
        let KerberosAuthentication = boxKerberosAuthentication.currentIndex === 0 ? "yes" : "no"
        sshValue.setItem("KERBEROSAUTHENTICATION", KerberosAuthentication)

        // Write "KerberosOrLocalPasswd".
        let KerberosOrLocalPasswd = boxKerberosOrLocalPasswd.currentIndex === 0 ? "yes" : "no"
        sshValue.setItem("KERBEROSORLOCALPASSWD", KerberosOrLocalPasswd)

        // Write "KerberosTicketCleanup".
        let KerberosTicketCleanup = boxKerberosTicketCleanup.currentIndex === 0 ? "yes" : "no"
        sshValue.setItem("KERBEROSTICKETCLEANUP", KerberosTicketCleanup)

        // Write "GSSAPIAuthentication".
        let GSSAPIAuthentication = boxGSSAPIAuthentication.currentIndex === 0 ? "yes" : "no"
        sshValue.setItem("GSSAPIAUTHENTICATION", GSSAPIAuthentication)

        // Write "GSSAPICleanupCredentials".
        let GSSAPICleanupCredentials = boxGSSAPICleanupCredentials.currentIndex === 0 ? "yes" : "no"
        sshValue.setItem("GSSAPICLEANUPCREDENTIALS", GSSAPICleanupCredentials)

        // Write "GSSAPIStrictAcceptorCheck".
        let GSSAPIStrictAcceptorCheck = boxGSSAPIStrictAcceptorCheck.currentIndex === 0 ? "yes" : "no"
        sshValue.setItem("GSSAPISTRICTACCEPTORCHECK", GSSAPIStrictAcceptorCheck)

        // Write "GSSAPIKeyExchange".
        let GSSAPIKeyExchange = boxGSSAPIKeyExchange.currentIndex === 0 ? "yes" : "no"
        sshValue.setItem("GSSAPIKEYEXCHANGE", GSSAPIKeyExchange)

        // Write "GSSAPIStoreCredentialSonreKey".
        let GSSAPIStoreCredentialSonreKey = boxGSSAPIStoreCredentialSonreKey.currentIndex === 0 ? "yes" : "no"
        sshValue.setItem("GSSAPISTORECREDENTIALSONREKEY", GSSAPIStoreCredentialSonreKey)

        // Write "GSSAPIKexAlgorithms".
        let aryData                = gSSAPIKexAlgorithmsList.fnGetData()
        let aryGSSAPIKexAlgorithms = aryData.join(",")
        sshValue.setItem("GSSAPIKEXALGORITHMS", aryGSSAPIKexAlgorithms)
    }

    signal clear()
    onClear: {
        // KerberosAuthentication
        boxKerberosAuthentication.currentIndex = 0

        // KerberosOrLocalPasswd
        boxKerberosOrLocalPasswd.currentIndex = 0

        // KerberosTicketCleanup
        boxKerberosTicketCleanup.currentIndex = 0

        // GSSAPIAuthentication
        boxGSSAPIAuthentication.currentIndex = 0

        // GSSAPICleanupCredentials
        boxGSSAPICleanupCredentials.currentIndex = 0

        // GSSAPIStrictAcceptorCheck
        boxGSSAPIStrictAcceptorCheck.currentIndex = 0

        // GSSAPIKeyExchange
        boxGSSAPIKeyExchange.currentIndex = 0

        // GSSAPIStoreCredentialSonreKey
        boxGSSAPIStoreCredentialSonreKey.currentIndex = 0

        // GSSAPIKexAlgorithms
        gSSAPIKexAlgorithmsList.clearModel()
    }

    ScrollView {
        id: scrollKerberos
        width: parent.width
        height : parent.height
        contentWidth: keroberosColumn.width    // The important part
        contentHeight: keroberosColumn.height  // Same
        clip: true                                  // Prevent drawing column outside the scrollview borders

        ScrollBar.vertical.policy: ScrollBar.AlwaysOn
        ScrollBar.vertical.visible: ScrollBar.vertical.size < 1
        ScrollBar.vertical.interactive: true

        Layout.alignment: Qt.AlignCenter
        Layout.fillWidth: true
        Layout.fillHeight: true

        ColumnLayout {
            id: keroberosColumn
            width: root.viewWidth

            // KerberosAuthentication
            Label {
                id: kerberosAuthenticationLabel
                text: qsTr("Allow Kerberos authentication :") + " (KerberosAuthentication)"
                font.pointSize: 14 + root.fontPadding

                wrapMode: Label.WordWrap

                Layout.fillHeight: true
                verticalAlignment: Label.AlignVCenter

                Layout.topMargin: 20
            }

            ComboBox {
                id: boxKerberosAuthentication
                implicitWidth: 300
                font.pointSize: 14 + root.fontPadding

                delegate: ItemDelegate {
                    id: delegateKerberosAuthentication
                    width: boxKerberosAuthentication.implicitWidth
                    height: boxKerberosAuthentication.implicitHeight
                    highlighted: boxKerberosAuthentication.highlightedIndex === index

                    background: Rectangle {
                        color: highlighted ? root.bDark ? "steelblue" : "orchid" : "transparent"
                    }

                    contentItem: Rectangle {
                        id: delegateRectKerberosAuthentication
                        width: parent.width
                        height: parent.height
                        color: "transparent"

                        Label {
                            id: textKerberosAuthentication
                            text: modelData
                            font.pointSize: 14 + root.fontPadding
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
                    id: kerberosAuthenticationModel
                    ListElement { text: "Yes" }
                    ListElement { text: "No" }
                }
            }

            // KerberosOrLocalPasswd
            Label {
                id: kerberosOrLocalPasswdLabel
                text: qsTr("If Kerberos authentication fails, authenticate with password :") + "<br>" +
                      "(KerberosOrLocalPasswd)"
                font.pointSize: 14 + root.fontPadding

                wrapMode: Label.WordWrap

                Layout.fillHeight: true
                verticalAlignment: Label.AlignVCenter

                Layout.topMargin: 30
            }

            ComboBox {
                id: boxKerberosOrLocalPasswd
                implicitWidth: 300
                font.pointSize: 14 + root.fontPadding

                delegate: ItemDelegate {
                    id: delegateKerberosOrLocalPasswd
                    width: boxKerberosOrLocalPasswd.implicitWidth
                    height: boxKerberosOrLocalPasswd.implicitHeight
                    highlighted: boxKerberosOrLocalPasswd.highlightedIndex === index

                    background: Rectangle {
                        color: highlighted ? root.bDark ? "steelblue" : "orchid" : "transparent"
                    }

                    contentItem: Rectangle {
                        id: delegateRectKerberosOrLocalPasswd
                        width: parent.width
                        height: parent.height
                        color: "transparent"

                        Label {
                            id: textKerberosOrLocalPasswd
                            text: modelData
                            font.pointSize: 14 + root.fontPadding
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
                    id: kerberosOrLocalPasswdModel
                    ListElement { text: "Yes" }
                    ListElement { text: "No" }
                }
            }

            // KerberosTicketCleanup
            Label {
                id: kerberosTicketCleanupLabel
                text: qsTr("Delete cache for Kerberos authentication when logout :") + "<br>" +
                      "(KerberosTicketCleanup)"
                font.pointSize: 14 + root.fontPadding

                wrapMode: Label.WordWrap

                Layout.fillHeight: true
                verticalAlignment: Label.AlignVCenter

                Layout.topMargin: 30
            }

            ComboBox {
                id: boxKerberosTicketCleanup
                implicitWidth: 300
                font.pointSize: 14 + root.fontPadding

                delegate: ItemDelegate {
                    id: delegateKerberosTicketCleanup
                    width: boxKerberosTicketCleanup.implicitWidth
                    height: boxKerberosTicketCleanup.implicitHeight
                    highlighted: boxKerberosTicketCleanup.highlightedIndex === index

                    background: Rectangle {
                        color: highlighted ? root.bDark ? "steelblue" : "orchid" : "transparent"
                    }

                    contentItem: Rectangle {
                        id: delegateRectKerberosTicketCleanup
                        width: parent.width
                        height: parent.height
                        color: "transparent"

                        Label {
                            id: textKerberosTicketCleanup
                            text: modelData
                            font.pointSize: 14 + root.fontPadding
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
                    id: kerberosTicketCleanupModel
                    ListElement { text: "Yes" }
                    ListElement { text: "No" }
                }
            }

            // GSSAPIAuthentication
            Label {
                id: gSSAPIAuthenticationLabel
                text: qsTr("Authenticate using GSSAPI (Generic Security Services API) :") + "<br>" +
                      "(GSSAPIAuthentication)"
                font.pointSize: 14 + root.fontPadding

                wrapMode: Label.WordWrap

                Layout.fillHeight: true
                verticalAlignment: Label.AlignVCenter

                Layout.topMargin: 30
            }

            Label {
                text: qsTr("This authentication uses Kerberos tokens instead of username and password.")
                font.pointSize: 12 + root.fontPadding

                textFormat: Label.RichText
                wrapMode: Label.WordWrap

                verticalAlignment: Label.AlignVCenter
                Layout.fillHeight: true
            }

            ComboBox {
                id: boxGSSAPIAuthentication
                implicitWidth: 300
                font.pointSize: 14 + root.fontPadding

                delegate: ItemDelegate {
                    id: delegateGSSAPIAuthentication
                    width: boxGSSAPIAuthentication.implicitWidth
                    height: boxGSSAPIAuthentication.implicitHeight
                    highlighted: boxGSSAPIAuthentication.highlightedIndex === index

                    background: Rectangle {
                        color: highlighted ? root.bDark ? "steelblue" : "orchid" : "transparent"
                    }

                    contentItem: Rectangle {
                        id: delegateRectGSSAPIAuthentication
                        width: parent.width
                        height: parent.height
                        color: "transparent"

                        Label {
                            id: textGSSAPIAuthentication
                            text: modelData
                            font.pointSize: 14 + root.fontPadding
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
                    id: gSSAPIAuthenticationModel
                    ListElement { text: "Yes" }
                    ListElement { text: "No" }
                }
            }

            // GSSAPICleanupCredentials
            Label {
                id: gSSAPICleanupCredentialsLabel
                text: qsTr("Delete authenticate cache when logout :") + "<br>" +
                      "(GSSAPICleanupCredentials)"
                font.pointSize: 14 + root.fontPadding

                wrapMode: Label.WordWrap

                Layout.fillHeight: true
                verticalAlignment: Label.AlignVCenter

                Layout.topMargin: 30
            }

            ComboBox {
                id: boxGSSAPICleanupCredentials
                implicitWidth: 300
                font.pointSize: 14 + root.fontPadding

                delegate: ItemDelegate {
                    id: delegateGSSAPICleanupCredentials
                    width: boxGSSAPICleanupCredentials.implicitWidth
                    height: boxGSSAPICleanupCredentials.implicitHeight
                    highlighted: boxGSSAPICleanupCredentials.highlightedIndex === index

                    background: Rectangle {
                        color: highlighted ? root.bDark ? "steelblue" : "orchid" : "transparent"
                    }

                    contentItem: Rectangle {
                        id: delegateRectGSSAPICleanupCredentials
                        width: parent.width
                        height: parent.height
                        color: "transparent"

                        Label {
                            id: textGSSAPICleanupCredentials
                            text: modelData
                            font.pointSize: 14 + root.fontPadding
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
                    id: gSSAPICleanupCredentialsModel
                    ListElement { text: "Yes" }
                    ListElement { text: "No" }
                }
            }

            // GSSAPIStrictAcceptorCheck
            Label {
                id: gSSAPIStrictAcceptorCheckLabel
                text: qsTr("Strictly check GSSAPI acceptors :") + "<br>" +
                      "(GSSAPIStrictAcceptorCheck)"
                font.pointSize: 14 + root.fontPadding

                wrapMode: Label.WordWrap

                Layout.fillHeight: true
                verticalAlignment: Label.AlignVCenter

                Layout.topMargin: 30
            }

            ComboBox {
                id: boxGSSAPIStrictAcceptorCheck
                implicitWidth: 300
                font.pointSize: 14 + root.fontPadding

                delegate: ItemDelegate {
                    id: delegateGSSAPIStrictAcceptorCheck
                    width: boxGSSAPIStrictAcceptorCheck.implicitWidth
                    height: boxGSSAPIStrictAcceptorCheck.implicitHeight
                    highlighted: boxGSSAPIStrictAcceptorCheck.highlightedIndex === index

                    background: Rectangle {
                        color: highlighted ? root.bDark ? "steelblue" : "orchid" : "transparent"
                    }

                    contentItem: Rectangle {
                        id: delegateRectGSSAPIStrictAcceptorCheck
                        width: parent.width
                        height: parent.height
                        color: "transparent"

                        Label {
                            id: textGSSAPIStrictAcceptorCheck
                            text: modelData
                            font.pointSize: 14 + root.fontPadding
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
                    id: gSSAPIStrictAcceptorCheckModel
                    ListElement { text: "Yes" }
                    ListElement { text: "No" }
                }
            }

            // GSSAPIKeyExchange
            Label {
                id: gSSAPIKeyExchangeLabel
                text: qsTr("Key exchange to allow GSSAPI :") + "<br>" +
                      "(GSSAPIKeyExchange)"
                font.pointSize: 14 + root.fontPadding

                wrapMode: Label.WordWrap

                Layout.fillHeight: true
                verticalAlignment: Label.AlignVCenter

                Layout.topMargin: 30
            }

            ComboBox {
                id: boxGSSAPIKeyExchange
                implicitWidth: 300
                font.pointSize: 14 + root.fontPadding

                delegate: ItemDelegate {
                    id: delegateGSSAPIKeyExchange
                    width: boxGSSAPIKeyExchange.implicitWidth
                    height: boxGSSAPIKeyExchange.implicitHeight
                    highlighted: boxGSSAPIKeyExchange.highlightedIndex === index

                    background: Rectangle {
                        color: highlighted ? root.bDark ? "steelblue" : "orchid" : "transparent"
                    }

                    contentItem: Rectangle {
                        id: delegateRectGSSAPIKeyExchange
                        width: parent.width
                        height: parent.height
                        color: "transparent"

                        Label {
                            id: textGSSAPIKeyExchange
                            text: modelData
                            font.pointSize: 14 + root.fontPadding
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
                    id: gSSAPIKeyExchangeModel
                    ListElement { text: "Yes" }
                    ListElement { text: "No" }
                }
            }

            // GSSAPIStoreCredentialSonreKey
            Label {
                id: gSSAPIStoreCredentialSonreKeyLabel
                text: qsTr("Store authentication information obtained by GSSAPI for future key exchange :") + "<br>" +
                      "(GSSAPIStoreCredentialSonreKey)"
                font.pointSize: 14 + root.fontPadding

                wrapMode: Label.WordWrap

                Layout.fillHeight: true
                verticalAlignment: Label.AlignVCenter

                Layout.topMargin: 30
            }

            Label {
                text: "<b><u>Yes</u></b> :" + "<br>" +
                      "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + qsTr("Client reuses stored credentials for next connection to the same host, rather than asking for authentication each time.") + "<br>" +
                      "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + qsTr("This improves the authentication process by reducing the number of authentication requests,") + "<br>" +
                      "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + qsTr("and security by securely storing authentication information on the client.") + "<br><br>" +
                      "<b><u>No</u></b> :" + "<br>" +
                      "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + qsTr("Authentication information obtained by GSSAPI is not saved, authentication is requested each time.")
                font.pointSize: 12 + root.fontPadding

                textFormat: Label.RichText
                wrapMode: Label.WordWrap

                verticalAlignment: Label.AlignVCenter
                Layout.fillHeight: true
            }

            ComboBox {
                id: boxGSSAPIStoreCredentialSonreKey
                implicitWidth: 300
                font.pointSize: 14 + root.fontPadding

                delegate: ItemDelegate {
                    id: delegateGSSAPIStoreCredentialSonreKey
                    width: boxGSSAPIStoreCredentialSonreKey.implicitWidth
                    height: boxGSSAPIStoreCredentialSonreKey.implicitHeight
                    highlighted: boxGSSAPIStoreCredentialSonreKey.highlightedIndex === index

                    background: Rectangle {
                        color: highlighted ? root.bDark ? "steelblue" : "orchid" : "transparent"
                    }

                    contentItem: Rectangle {
                        id: delegateRectGSSAPIStoreCredentialSonreKey
                        width: parent.width
                        height: parent.height
                        color: "transparent"

                        Label {
                            id: textGSSAPIStoreCredentialSonreKey
                            text: modelData
                            font.pointSize: 14 + root.fontPadding
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
                    id: gSSAPIStoreCredentialSonreKeyModel
                    ListElement { text: "Yes" }
                    ListElement { text: "No" }
                }
            }

            // GSSAPIKexAlgorithms
            ColumnLayout {
                id: gSSAPIKexAlgorithmsColumn
                width: Math.round(root.width * 0.6)

                Layout.topMargin: 30
                Layout.bottomMargin: 50

                RowLayout {
                    id: gSSAPIKexAlgorithmsRow
                    spacing: 20

                    Label {
                        id: gSSAPIKexAlgorithmsLabel
                        text: qsTr("Specify algorithm for key exchange in GSSAPI (Generic Security Services API) :") + "<br>" +
                              "(GSSAPIKexAlgorithms)"
                        font.pointSize: 14 + root.fontPadding

                        textFormat: Label.RichText
                        wrapMode: Label.WordWrap

                        verticalAlignment: Label.AlignVCenter
                        Layout.fillHeight: true
                    }


                    RoundButton {
                        id: btnGSSAPIKexAlgorithms
                        text: ""
                        width: 48
                        height: 48

                        icon.source: pressed ? "../Image/AddPressed.png" : "../Image/Add.png"
                        icon.width: width
                        icon.height: height
                        icon.color: "transparent"

                        padding: 0

                        background: Rectangle {
                            color: "transparent"
                        }

                        onClicked: {
                            gSSAPIKexAlgorithmsList.appendModel("")
                        }
                    }
                }

                Label {
                    text: "<b><u>" + qsTr("Must be set up on both server and client.") + "</u></b>" + "<br>" +
                          qsTr("Note that compatibility issues may arise depending on type of algorithm.") + "<br><br>" +
                          "<b><u>" + qsTr("Also, note that \"gss-group1-sha1-*\" algorithm may be vulnerable.") + "</u></b>"
                    font.pointSize: 12 + root.fontPadding

                    textFormat: Label.RichText
                    wrapMode: Label.WordWrap

                    verticalAlignment: Label.AlignVCenter
                    Layout.fillHeight: true
                }

                ComboBox {
                    id: boxGSSAPIKexAlgorithms
                    implicitWidth: 500
                    font.pointSize: 14 + root.fontPadding

                    currentIndex: 0

                    delegate: ItemDelegate {
                        id: delegateGSSAPIKexAlgorithms
                        width: boxGSSAPIKexAlgorithms.implicitWidth
                        height: boxGSSAPIKexAlgorithms.implicitHeight
                        highlighted: boxGSSAPIKexAlgorithms.highlightedIndex === index

                        background: Rectangle {
                            color: highlighted ? root.bDark ? "steelblue" : "orchid" : "transparent"
                        }

                        contentItem: Rectangle {
                            id: delegateRectGSSAPIKexAlgorithms
                            width: parent.width
                            height: parent.height
                            color: "transparent"

                            Label {
                                id: textGSSAPIKexAlgorithms
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
                        id: gSSAPIKexAlgorithmsModel
                        ListElement { text: "gss-group14-sha1-*" }
                        ListElement { text: "gss-gex-sha1-*" }
                        ListElement { text: "gss-nistp256-sha256-*" }
                        ListElement { text: "gss-nistp384-sha384-*" }
                        ListElement { text: "gss-nistp521-sha512-*" }
                        ListElement { text: "gss-curve25519-sha256-*" }
                        ListElement { text: "gss-curve448-sha512-*" }
                        ListElement { text: "gss-group1-sha1-* (depracated)" }
                    }

                    onActivated: {
                        gSSAPIKexAlgorithmsList.appendModel(boxGSSAPIKexAlgorithms.currentText)
                    }
                }

                SSHOptionListView {
                    id: gSSAPIKexAlgorithmsList
                    width: parent.width
                    implicitWidth: parent.width
                    fontPadding: root.fontPadding
                    bDark: root.bDark
                }
            }
        }
    }
}
