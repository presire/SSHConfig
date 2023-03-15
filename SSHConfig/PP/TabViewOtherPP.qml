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
    // Get path to file on remote server.
    Connections {
        target: sshServerConfig
        function onGetDirectoryFromServer(directoryType: int, remoteDirecotry: string) {
            // Set file path for UI.
            if (directoryType === 0) {
                pidFileEdit.text = remoteDirecotry + "/" + "sshd.pid"
            }
            else if (directoryType === 1) {
                chrootDirectoryEdit.text = remoteDirecotry
            }
        }
    }

    signal readSuccess()
    onReadSuccess: {
        // Set "AllowAgentForwarding".
        let AllowAgentForwarding = sshValue.getItem("ALLOWAGENTFORWARDING")
        AllowAgentForwarding = String(AllowAgentForwarding).toUpperCase()
        boxAllowAgentForwarding.currentIndex = AllowAgentForwarding === "YES" ? 0 : 1

        // Set "AllowTcpForwarding".
        let AllowTcpForwarding = sshValue.getItem("ALLOWTCPFORWARDING")
        AllowTcpForwarding = String(AllowTcpForwarding).toUpperCase()
        boxAllowTcpForwarding.currentIndex = AllowTcpForwarding === "YES" ? 0 : 1

        // Set "GatewayPorts".
        let GatewayPorts = sshValue.getItem("GATEWAYPORTS")
        GatewayPorts = String(GatewayPorts).toUpperCase()
        boxGatewayPorts.currentIndex = GatewayPorts === "YES" ? 0 : 1

        // Set "X11Forwarding".
        let X11Forwarding = sshValue.getItem("X11FORWARDING")
        X11Forwarding = String(X11Forwarding).toUpperCase()
        boxX11Forwarding.currentIndex = X11Forwarding === "YES" ? 0 : 1

        // Set "X11DisplayOffset"
        x11DisplayOffsetEdit.text = sshValue.getItem("X11DISPLAYOFFSET")

        // Set "X11UseLocalhost".
        let X11UseLocalhost = sshValue.getItem("X11USELOCALHOST")
        X11UseLocalhost = String(X11UseLocalhost).toUpperCase()
        boxX11UseLocalhost.currentIndex = X11UseLocalhost === "YES" ? 0 : 1

        // Set "PermitTTY".
        let PermitTTY = sshValue.getItem("PERMITTTY")
        PermitTTY = String(PermitTTY).toUpperCase()
        boxPermitTTY.currentIndex = PermitTTY === "YES" ? 0 : 1

        // Set "PrintMotd".
        let PrintMotd = sshValue.getItem("PRINTMOTD")
        PrintMotd = String(PrintMotd).toUpperCase()
        boxPrintMotd.currentIndex = PrintMotd === "YES" ? 0 : 1

        // Set "PrintLastLog".
        let PrintLastLog = sshValue.getItem("PRINTLASTLOG")
        PrintLastLog = String(PrintLastLog).toUpperCase()
        boxPrintLastLog.currentIndex = PrintLastLog === "YES" ? 0 : 1

        // Set "TCPKeepAlive".
        let TCPKeepAlive = sshValue.getItem("TCPKEEPALIVE")
        TCPKeepAlive = String(TCPKeepAlive).toUpperCase()
        boxTCPKeepAlive.currentIndex = TCPKeepAlive === "YES" ? 0 : 1

        // Set "PermitUserEnvironment".
        let PermitUserEnvironment = sshValue.getItem("PERMITUSERENVIRONMENT")
        PermitUserEnvironment = String(PermitUserEnvironment).toUpperCase()
        boxPermitUserEnvironment.currentIndex = PermitUserEnvironment === "YES" ? 0 : 1

        // Set "Compression".
        let Compression = sshValue.getItem("COMPRESSION")
        Compression = String(Compression).toUpperCase()
        boxCompression.currentIndex = Compression === "YES" ? 0 : Compression === "DELAYED" ? 0 : 1

        // Set "ClientAliveInterval"
        clientAliveIntervalEdit.text = sshValue.getItem("CLIENTALIVEINTERVAL")

        // Set "ClientAliveCountMax"
        clientAliveCountMaxEdit.text = sshValue.getItem("CLIENTALIVECOUNTMAX")

        // Set "UseDNS"
        let UseDNS = sshValue.getItem("USEDNS")
        UseDNS = String(UseDNS).toUpperCase()
        boxUseDNS.currentIndex = UseDNS === "YES" ? 0 : 1

        // Set "PIDFile"
        pidFileEdit.text = sshValue.getItem("PIDFILE")

        // Set "MaxStartups"
        maxStartupsEdit.text = sshValue.getItem("MAXSTARTUPS")

        // Set "PermitTunnel"
        let PermitTunnel = sshValue.getItem("PERMITTUNNEL")
        PermitTunnel = String(PermitTunnel).toUpperCase()
        boxPermitTunnel.currentIndex = PermitTunnel === "YES" ? 0 : 1

        // Set "ChrootDirectory"
        chrootDirectoryEdit.text = sshValue.getItem("CHROOTDIRECTORY")

        // Set "Banner"
        bannerEdit.text = sshValue.getItem("BANNER")

        // Set "VersionAddendum"
        versionAddendumEdit.text = sshValue.getItem("VERSIONADDENDUM")
    }

    signal writeSuccess()
    onWriteSuccess: {
        // Write "AllowAgentForwarding".
        let AllowAgentForwarding = boxAllowAgentForwarding.currentIndex === 0 ? "yes" : "no"
        sshValue.setItem("ALLOWAGENTFORWARDING", AllowAgentForwarding)

        // Write "AllowTcpForwarding".
        let AllowTcpForwarding = boxAllowTcpForwarding.currentIndex === 0 ? "yes" : "no"
        sshValue.setItem("ALLOWTCPFORWARDING", AllowTcpForwarding)

        // Write "GatewayPorts".
        let GatewayPorts = boxGatewayPorts.currentIndex === 0 ? "yes" : "no"
        sshValue.setItem("GATEWAYPORTS", GatewayPorts)

        // Write "X11Forwarding".
        let X11Forwarding = boxX11Forwarding.currentIndex === 0 ? "yes" : "no"
        sshValue.setItem("X11FORWARDING", X11Forwarding)

        // Write "X11DisplayOffset".
        sshValue.setItem("X11DISPLAYOFFSET", x11DisplayOffsetEdit.text)

        // Write "X11UseLocalhost".
        let X11UseLocalhost = boxX11UseLocalhost.currentIndex === 0 ? "yes" : "no"
        sshValue.setItem("X11USELOCALHOST", X11UseLocalhost)

        // Write "PermitTTY".
        let PermitTTY = boxPermitTTY.currentIndex === 0 ? "yes" : "no"
        sshValue.setItem("PERMITTTY", PermitTTY)

        // Write "PrintMotd".
        let PrintMotd = boxPrintMotd.currentIndex === 0 ? "yes" : "no"
        sshValue.setItem("PRINTMOTD", PrintMotd)

        // Write "PrintLastLog".
        let PrintLastLog = boxPrintLastLog.currentIndex === 0 ? "yes" : "no"
        sshValue.setItem("PRINTLASTLOG", PrintLastLog)

        // Write "PrintMotd".
        let TCPKeepAlive = boxTCPKeepAlive.currentIndex === 0 ? "yes" : "no"
        sshValue.setItem("TCPKEEPALIVE", TCPKeepAlive)

        // Write "PermitUserEnvironment".
        let PermitUserEnvironment = boxPermitUserEnvironment.currentIndex === 0 ? "yes" : "no"
        sshValue.setItem("PERMITUSERENVIRONMENT", PermitUserEnvironment)

        // Write "Compression".
        let Compression = boxCompression.currentIndex === 0 ? "yes" : "no"
        sshValue.setItem("COMPRESSION", Compression)

        // Write "ClientAliveInterval".
        sshValue.setItem("CLIENTALIVEINTERVAL", clientAliveIntervalEdit.text)

        // Write "ClientAliveCountMax".
        sshValue.setItem("CLIENTALIVECOUNTMAX", clientAliveCountMaxEdit.text)

        // Write "UseDNS".
        let UseDNS = boxUseDNS.currentIndex === 0 ? "yes" : "no"
        sshValue.setItem("USEDNS", UseDNS)

        // Write "PIDFile".
        sshValue.setItem("PIDFILE", pidFileEdit.text)

        // Write "MaxStartups".
        sshValue.setItem("MAXSTARTUPS", maxStartupsEdit.text)

        // Write "PermitTunnel".
        let PermitTunnel = boxPermitTunnel.currentIndex === 0 ? "yes" : "no"
        sshValue.setItem("PERMITTUNNEL", PermitTunnel)

        // Write "ChrootDirectory".
        sshValue.setItem("CHROOTDIRECTORY", chrootDirectoryEdit.text)

        // Write "Banner".
        sshValue.setItem("BANNER", bannerEdit.text)

        // Write "VersionAddendum".
        sshValue.setItem("VERSIONADDENDUM", versionAddendumEdit.text)
    }

    signal clear()
    onClear: {
        // AllowAgentForwarding
        boxAllowAgentForwarding.currentIndex = 0

        // AllowTcpForwarding
        boxAllowTcpForwarding.currentIndex = 0

        // GatewayPorts
        boxGatewayPorts.currentIndex = 0

        // X11Forwarding
        boxX11Forwarding.currentIndex = 0

        // X11DisplayOffset
        x11DisplayOffsetEdit.text = ""

        // X11UseLocalhost
        boxX11UseLocalhost.currentIndex = 0

        // PermitTTY
        boxPermitTTY.currentIndex = 0

        // PrintMotd
        boxPrintMotd.currentIndex = 0

        // PrintLastLog
        boxPrintLastLog.currentIndex = 0

        // TCPKeepAlive
        boxTCPKeepAlive.currentIndex = 0

        // PermitUserEnvironment
        boxPermitUserEnvironment.currentIndex = 0

        // Compression
        boxCompression.currentIndex = 0

        // ClientAliveInterval
        clientAliveIntervalEdit.text = ""

        // ClientAliveCountMax
        clientAliveCountMaxEdit.text = ""

        // UseDNS
        boxUseDNS.currentIndex = 0

        // PIDFile
        pidFileEdit.text = ""

        // MaxStartups
        maxStartupsEdit.text = ""

        // PermitTunnel
        boxPermitTunnel.currentIndex = 0

        // ChrootDirectory
        chrootDirectoryEdit.text = ""

        // Banner
        bannerEdit.text = ""

        // VersionAddendum
        versionAddendumEdit.text = ""
    }

    ScrollView {
        id: scrollOther
        width: parent.width
        height : parent.height
        contentWidth: otherColumn.width    // The important part
        contentHeight: otherColumn.height  // Same
        clip: true                                  // Prevent drawing column outside the scrollview borders

        ScrollBar.vertical.policy: ScrollBar.AlwaysOn
        ScrollBar.vertical.visible: ScrollBar.vertical.size < 1
        ScrollBar.vertical.interactive: true

        Layout.alignment: Qt.AlignCenter
        Layout.fillWidth: true
        Layout.fillHeight: true

        ColumnLayout {
            id: otherColumn
            width: root.viewWidth

            // AllowAgentForwarding
            Label {
                id: allowAgentForwardingLabel
                text: qsTr("Allow agent forwarding by ssh-agent :") + "<br>" + "(AllowAgentForwarding)"
                font.pointSize: 12 + root.fontPadding

                wrapMode: Label.WordWrap

                Layout.preferredWidth: parent.width - 10
                Layout.fillHeight: true
                verticalAlignment: Label.AlignVCenter

                Layout.topMargin: 20
            }

            ComboBox {
                id: boxAllowAgentForwarding
                implicitWidth: 250
                font.pointSize: 12 + root.fontPadding

                delegate: ItemDelegate {
                    id: delegatePermitRoot
                    width: boxAllowAgentForwarding.implicitWidth
                    height: boxAllowAgentForwarding.implicitHeight
                    highlighted: boxAllowAgentForwarding.highlightedIndex === index

                    background: Rectangle {
                        color: highlighted ? root.bDark ? "steelblue" : "orchid" : "transparent"
                    }

                    contentItem: Rectangle {
                        id: delegateRectAllowAgentForwarding
                        width: parent.width
                        height: parent.height
                        color: "transparent"

                        Label {
                            id: textAllowAgentForwarding
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
                    id: allowAgentForwardingModel
                    ListElement { text: "Yes" }
                    ListElement { text: "No" }
                }
            }

            // AllowTcpForwarding
            Label {
                id: allowTcpForwardingLabel
                text: qsTr("Allow TCP forwarding :") + "<br>" + "(AllowTcpForwarding)"
                font.pointSize: 12 + root.fontPadding

                wrapMode: Label.WordWrap

                Layout.preferredWidth: parent.width - 10
                Layout.fillHeight: true
                verticalAlignment: Label.AlignVCenter

                Layout.topMargin: 30
            }

            ComboBox {
                id: boxAllowTcpForwarding
                implicitWidth: 250
                font.pointSize: 12 + root.fontPadding

                delegate: ItemDelegate {
                    id: delegateAllowTcpForwarding
                    width: boxAllowTcpForwarding.implicitWidth
                    height: boxAllowTcpForwarding.implicitHeight
                    highlighted: boxAllowTcpForwarding.highlightedIndex === index

                    background: Rectangle {
                        color: highlighted ? root.bDark ? "steelblue" : "orchid" : "transparent"
                    }

                    contentItem: Rectangle {
                        id: delegateRectAllowTcpForwarding
                        width: parent.width
                        height: parent.height
                        color: "transparent"

                        Label {
                            id: textAllowTcpForwarding
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
                    id: allowTcpForwardingModel
                    ListElement { text: "Yes" }
                    ListElement { text: "No" }
                }
            }

            // GatewayPorts
            Label {
                id: gatewayPortsLabel
                text: qsTr("Allow port relay :") + "<br>" + "(GatewayPorts)"
                font.pointSize: 12 + root.fontPadding

                wrapMode: Label.WordWrap

                Layout.fillHeight: true
                verticalAlignment: Label.AlignVCenter

                Layout.topMargin: 30
            }

            ComboBox {
                id: boxGatewayPorts
                implicitWidth: 250
                font.pointSize: 12 + root.fontPadding

                delegate: ItemDelegate {
                    id: delegateGatewayPorts
                    width: boxGatewayPorts.implicitWidth
                    height: boxGatewayPorts.implicitHeight
                    highlighted: boxGatewayPorts.highlightedIndex === index

                    background: Rectangle {
                        color: highlighted ? root.bDark ? "steelblue" : "orchid" : "transparent"
                    }

                    contentItem: Rectangle {
                        id: delegateRectGatewayPorts
                        width: parent.width
                        height: parent.height
                        color: "transparent"

                        Label {
                            id: textGatewayPorts
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
                    id: gatewayPortsModel
                    ListElement { text: "Yes" }
                    ListElement { text: "No" }
                }
            }

            // X11Forwarding
            Label {
                id: x11ForwardingLabel
                text: qsTr("Allow X11 transfer :") + "<br>" + "(X11Forwarding)"
                font.pointSize: 12 + root.fontPadding

                wrapMode: Label.WordWrap

                Layout.fillHeight: true
                verticalAlignment: Label.AlignVCenter

                Layout.topMargin: 30
            }

            ComboBox {
                id: boxX11Forwarding
                implicitWidth: 250
                font.pointSize: 12 + root.fontPadding

                delegate: ItemDelegate {
                    id: delegateX11Forwarding
                    width: boxX11Forwarding.implicitWidth
                    height: boxX11Forwarding.implicitHeight
                    highlighted: boxX11Forwarding.highlightedIndex === index

                    background: Rectangle {
                        color: highlighted ? root.bDark ? "steelblue" : "orchid" : "transparent"
                    }

                    contentItem: Rectangle {
                        id: delegateRectX11Forwarding
                        width: parent.width
                        height: parent.height
                        color: "transparent"

                        Label {
                            id: textX11Forwarding
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
                    id: x11ForwardingModel
                    ListElement { text: "Yes" }
                    ListElement { text: "No" }
                }
            }

            // X11DisplayOffset
            Label {
                id: x11DisplayOffsetLabel
                text: qsTr("Display number used for X11 transfers :") + "<br>" + "(X11DisplayOffset)"
                font.pointSize: 12 + root.fontPadding

                wrapMode: Label.WordWrap

                Layout.preferredWidth: parent.width - 10
                Layout.fillHeight: true
                verticalAlignment: Label.AlignVCenter

                Layout.topMargin: 30
            }

            TextField {
                id: x11DisplayOffsetEdit
                text: ""
                implicitWidth: Math.round((root.viewWidth - otherColumn.spacing * 2) * 0.2)
                font.pointSize: 12 + root.fontPadding
                placeholderText: qsTr("default is 10")

                horizontalAlignment: TextField.AlignRight
                verticalAlignment: TextField.AlignVCenter

                // Input limit (>= 0)
                validator: RegExpValidator {
                    regExp: /[0-9]*/
                }
            }

            // X11UseLocalhost
            Label {
                id: x11UseLocalhostLabel
                text: qsTr("Allow X11 on localhost only :") + "<br>" + "(X11UseLocalhost)"
                font.pointSize: 12 + root.fontPadding

                wrapMode: Label.WordWrap

                Layout.fillHeight: true
                verticalAlignment: Label.AlignVCenter

                Layout.topMargin: 30
            }

            ComboBox {
                id: boxX11UseLocalhost
                implicitWidth: 250
                font.pointSize: 12 + root.fontPadding

                delegate: ItemDelegate {
                    id: delegateX11UseLocalhost
                    width: boxX11UseLocalhost.implicitWidth
                    height: boxX11UseLocalhost.implicitHeight
                    highlighted: boxX11UseLocalhost.highlightedIndex === index

                    background: Rectangle {
                        color: highlighted ? root.bDark ? "steelblue" : "orchid" : "transparent"
                    }

                    contentItem: Rectangle {
                        id: delegateRectX11UseLocalhost
                        width: parent.width
                        height: parent.height
                        color: "transparent"

                        Label {
                            id: textX11UseLocalhost
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
                    id: x11UseLocalhostModel
                    ListElement { text: "Yes" }
                    ListElement { text: "No" }
                }
            }

            // PermitTTY
            Label {
                id: permitTTYLabel
                text: qsTr("Allow pty allocation :") + "<br>" + "(PermitTTY)"
                font.pointSize: 12 + root.fontPadding

                wrapMode: Label.WordWrap

                Layout.fillHeight: true
                verticalAlignment: Label.AlignVCenter

                Layout.topMargin: 30
            }

            ComboBox {
                id: boxPermitTTY
                implicitWidth: 250
                font.pointSize: 12 + root.fontPadding

                delegate: ItemDelegate {
                    id: delegatePermitTTY
                    width: boxPermitTTY.implicitWidth
                    height: boxPermitTTY.implicitHeight
                    highlighted: boxPermitTTY.highlightedIndex === index

                    background: Rectangle {
                        color: highlighted ? root.bDark ? "steelblue" : "orchid" : "transparent"
                    }

                    contentItem: Rectangle {
                        id: delegateRectPermitTTY
                        width: parent.width
                        height: parent.height
                        color: "transparent"

                        Label {
                            id: textPermitTTY
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
                    id: permitTTYModel
                    ListElement { text: "Yes" }
                    ListElement { text: "No" }
                }
            }

            // PrintMotd
            Label {
                id: printMotdLabel
                text: qsTr("Display contents of /etc/motd at login :") + "<br>" + "(PrintMotd)"
                font.pointSize: 12 + root.fontPadding

                wrapMode: Label.WordWrap

                Layout.fillHeight: true
                verticalAlignment: Label.AlignVCenter

                Layout.topMargin: 30
            }

            ComboBox {
                id: boxPrintMotd
                implicitWidth: 250
                font.pointSize: 12 + root.fontPadding

                delegate: ItemDelegate {
                    id: delegatePrintMotd
                    width: boxPrintMotd.implicitWidth
                    height: boxPrintMotd.implicitHeight
                    highlighted: boxPrintMotd.highlightedIndex === index

                    background: Rectangle {
                        color: highlighted ? root.bDark ? "steelblue" : "orchid" : "transparent"
                    }

                    contentItem: Rectangle {
                        id: delegateRectPrintMotd
                        width: parent.width
                        height: parent.height
                        color: "transparent"

                        Label {
                            id: textPrintMotd
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
                    id: printMotdModel
                    ListElement { text: "Yes" }
                    ListElement { text: "No" }
                }
            }

            // PrintLastLog
            Label {
                id: printLastLogLabel
                text: qsTr("Display the date and time of the last login when login :") + "<br>" +
                      "(PrintLastLog)"
                font.pointSize: 12 + root.fontPadding

                wrapMode: Label.WordWrap

                Layout.preferredWidth: parent.width - 10
                Layout.fillHeight: true
                verticalAlignment: Label.AlignVCenter

                Layout.topMargin: 30
            }

            ComboBox {
                id: boxPrintLastLog
                implicitWidth: 250
                font.pointSize: 12 + root.fontPadding

                delegate: ItemDelegate {
                    id: delegatePrintLastLog
                    width: boxPrintLastLog.implicitWidth
                    height: boxPrintLastLog.implicitHeight
                    highlighted: boxPrintLastLog.highlightedIndex === index

                    background: Rectangle {
                        color: highlighted ? root.bDark ? "steelblue" : "orchid" : "transparent"
                    }

                    contentItem: Rectangle {
                        id: delegateRectPrintLastLog
                        width: parent.width
                        height: parent.height
                        color: "transparent"

                        Label {
                            id: textPrintLastLog
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
                    id: printLastLogModel
                    ListElement { text: "Yes" }
                    ListElement { text: "No" }
                }
            }

            // TCPKeepAlive
            Label {
                id: tCPKeepAliveLabel
                text: qsTr("Send TCP keep-alive message :") + "<br>" + "(TCPKeepAlive)"
                font.pointSize: 12 + root.fontPadding

                wrapMode: Label.WordWrap

                Layout.fillHeight: true
                verticalAlignment: Label.AlignVCenter

                Layout.topMargin: 30
            }

            ComboBox {
                id: boxTCPKeepAlive
                implicitWidth: 250
                font.pointSize: 12 + root.fontPadding

                delegate: ItemDelegate {
                    id: delegateTCPKeepAlive
                    width: boxTCPKeepAlive.implicitWidth
                    height: boxTCPKeepAlive.implicitHeight
                    highlighted: boxTCPKeepAlive.highlightedIndex === index

                    background: Rectangle {
                        color: highlighted ? root.bDark ? "steelblue" : "orchid" : "transparent"
                    }

                    contentItem: Rectangle {
                        id: delegateRectTCPKeepAlive
                        width: parent.width
                        height: parent.height
                        color: "transparent"

                        Label {
                            id: textTCPKeepAlive
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
                    id: tCPKeepAliveModel
                    ListElement { text: "Yes" }
                    ListElement { text: "No" }
                }
            }

            // PermitUserEnvironment
            Label {
                id: permitUserEnvironmentLabel
                text: qsTr("Allow users to change environment variables :") + "<br>" + "(PermitUserEnvironment)"
                font.pointSize: 12 + root.fontPadding

                wrapMode: Label.WordWrap

                Layout.preferredWidth: parent.width - 10
                Layout.fillHeight: true
                verticalAlignment: Label.AlignVCenter

                Layout.topMargin: 30
            }

            ComboBox {
                id: boxPermitUserEnvironment
                implicitWidth: 250
                font.pointSize: 12 + root.fontPadding

                delegate: ItemDelegate {
                    id: delegatePermitUserEnvironment
                    width: boxPermitUserEnvironment.implicitWidth
                    height: boxPermitUserEnvironment.implicitHeight
                    highlighted: boxPermitUserEnvironment.highlightedIndex === index

                    background: Rectangle {
                        color: highlighted ? root.bDark ? "steelblue" : "orchid" : "transparent"
                    }

                    contentItem: Rectangle {
                        id: delegateRectPermitUserEnvironment
                        width: parent.width
                        height: parent.height
                        color: "transparent"

                        Label {
                            id: textPermitUserEnvironment
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
                    id: permitUserEnvironmentModel
                    ListElement { text: "Yes" }
                    ListElement { text: "No" }
                }
            }

            // Compression
            Label {
                id: compressionLabel
                text: qsTr("Allow compression :") + "<br>" + "(Compression)"
                font.pointSize: 12 + root.fontPadding

                wrapMode: Label.WordWrap

                Layout.fillHeight: true
                verticalAlignment: Label.AlignVCenter

                Layout.topMargin: 30
            }

            Label {
                text: qsTr("Allow compression after user is authenticated.")
                font.pointSize: 10 + root.fontPadding

                wrapMode: Label.WordWrap

                verticalAlignment: Label.AlignVCenter
                Layout.fillHeight: true
            }

            ComboBox {
                id: boxCompression
                implicitWidth: 250
                font.pointSize: 12 + root.fontPadding

                delegate: ItemDelegate {
                    id: delegateCompression
                    width: boxCompression.implicitWidth
                    height: boxCompression.implicitHeight
                    highlighted: boxCompression.highlightedIndex === index

                    background: Rectangle {
                        color: highlighted ? root.bDark ? "steelblue" : "orchid" : "transparent"
                    }

                    contentItem: Rectangle {
                        id: delegateRectCompression
                        width: parent.width
                        height: parent.height
                        color: "transparent"

                        Label {
                            id: textCompression
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
                    id: compressionModel
                    ListElement { text: "Yes (delayed)" }
                    ListElement { text: "No" }
                }
            }

            // ClientAliveInterval
            Label {
                id: clientAliveIntervalLabel
                text: qsTr("Interval to check for client :") + "<br>" + "(ClientAliveInterval)"
                font.pointSize: 12 + root.fontPadding

                wrapMode: Label.WordWrap

                Layout.preferredWidth: parent.width - 10
                Layout.fillHeight: true
                verticalAlignment: Label.AlignVCenter

                Layout.topMargin: 30
            }

            Label {
                text: qsTr("Set timeout interval before sshd sends message over encrypted channel and") + "<br>" +
                      qsTr("request response from client, if no data is received from client.") + "<br><br>" +
                      qsTr("<u><b>If 0 is specified, it means that message will not be sent to client.</b></u>")
                font.pointSize: 10 + root.fontPadding

                textFormat: Label.RichText
                wrapMode: Label.WordWrap

                verticalAlignment: Label.AlignVCenter
                Layout.preferredWidth: parent.width - 10
                Layout.fillHeight: true
            }

            TextField {
                id: clientAliveIntervalEdit
                text: ""
                implicitWidth: root.viewWidth * 0.6
                font.pointSize: 12 + root.fontPadding
                placeholderText: qsTr("default is 0")

                horizontalAlignment: TextField.AlignRight
                verticalAlignment: TextField.AlignVCenter

                // Input limit (>= 0)
                validator: RegExpValidator {
                    regExp: /[0-9]*/
                }
            }

            // ClientAliveCountMax
            Label {
                id: clientAliveCountMaxLabel
                text: qsTr("Number of alive confirmation message to be sent to client :") + "<br>" +
                      "(ClientAliveCountMax)"
                font.pointSize: 12 + root.fontPadding

                wrapMode: Label.WordWrap

                Layout.preferredWidth: parent.width - 10
                Layout.fillHeight: true
                verticalAlignment: Label.AlignVCenter

                Layout.topMargin: 30
            }

            Label {
                text: qsTr("If this threshold is reached in sending client alive confirmation message,") + "<br>" +
                      qsTr("sshd disconnects client session.")
                font.pointSize: 10 + root.fontPadding

                textFormat: Label.RichText
                wrapMode: Label.WordWrap

                verticalAlignment: Label.AlignVCenter
                Layout.preferredWidth: parent.width - 10
                Layout.fillHeight: true
            }

            TextField {
                id: clientAliveCountMaxEdit
                text: ""
                implicitWidth: root.viewWidth * 0.6
                font.pointSize: 12 + root.fontPadding
                placeholderText: qsTr("default is 3")

                horizontalAlignment: TextField.AlignRight
                verticalAlignment: TextField.AlignVCenter

                // Input limit (>= 0)
                validator: RegExpValidator {
                    regExp: /[0-9]*/
                }
            }

            // UseDNS
            Label {
                id: useDNSLabel
                text: qsTr("Check remote server name using DNS :") + "<br>" + "(UseDNS)"
                font.pointSize: 12 + root.fontPadding

                wrapMode: Label.WordWrap

                Layout.preferredWidth: parent.width - 10
                Layout.fillHeight: true
                verticalAlignment: Label.AlignVCenter

                Layout.topMargin: 30
            }

            ComboBox {
                id: boxUseDNS
                implicitWidth: 250
                font.pointSize: 12 + root.fontPadding

                delegate: ItemDelegate {
                    id: delegateUseDNS
                    width: boxUseDNS.implicitWidth
                    height: boxUseDNS.implicitHeight
                    highlighted: boxUseDNS.highlightedIndex === index

                    background: Rectangle {
                        color: highlighted ? root.bDark ? "steelblue" : "orchid" : "transparent"
                    }

                    contentItem: Rectangle {
                        id: delegateRectUseDNS
                        width: parent.width
                        height: parent.height
                        color: "transparent"

                        Label {
                            id: textUseDNS
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
                    id: useDNSModel
                    ListElement { text: "Yes" }
                    ListElement { text: "No" }
                }
            }

            // PIDFile
            Label {
                id: pidFileLabel
                text: qsTr("Path to PID file for SSH :") + "<br>" + "(PIDFile)"
                font.pointSize: 12 + root.fontPadding

                wrapMode: Label.WordWrap

                Layout.preferredWidth: parent.width - 10
                Layout.fillHeight: true
                verticalAlignment: Label.AlignVCenter

                Layout.topMargin: 30
            }

            RoundButton {
                id: btnPIDDirectorySelect
                text: ""
                width: 48
                height: 48

                icon.source: pressed ? "qrc:/Image/OpenDirectoryPressed.png" : "qrc:/Image/OpenDirectory.png"
                icon.width: width
                icon.height: height
                icon.color: "transparent"

                padding: 0

                background: Rectangle {
                    color: "transparent"
                }

                onClicked: {
                    let iRet = 0

                    if (root.bServerMode) selectPIDDirectoryDialog.open()
                    else                  iRet = sshServerConfig.getRemoteDirectory(root.width, root.height, root.bDark, root.fontPadding, 0)

                    if (iRet !== 0) {
                        // Display error message.
                        let errMsg = sshServerConfig.getErrorMessage()

                        let componentDialog = Qt.createComponent("qrc:/ExtendQML/ErrorDialogPP.qml");
                        if (componentDialog.status === Component.Ready) {
                            let errorDialog = componentDialog.createObject(root,
                                                                           {mainWidth: root.width, mainHeight: root.height, bDark: root.bDark,
                                                                            messageTitle: qsTr("Error"),
                                                                            messageText: qsTr("Failed to select directory for PID file.") + "<br>" + errMsg});
                            errorDialog.show();
                        }
                    }
                }

                SelectFolderDialog {
                    id: selectPIDDirectoryDialog
                    mainWidth: root.viewWidth
                    mainHeight: root.viewHeight

                    onAccepted: {
                        pidFileEdit.text = strDirPath + "/" + "sshd.pid"
                    }
                }
            }

            TextField {
                id: pidFileEdit
                text: ""
                implicitWidth: root.viewWidth * 0.85
                font.pointSize: 12 + root.fontPadding
                placeholderText: qsTr("default is /run/sshd.pid")

                horizontalAlignment: TextField.AlignRight
                verticalAlignment: TextField.AlignVCenter
            }

            // MaxStartups
            Label {
                id: maxStartupsLabel
                text: qsTr("Maximum number of connection accepted before successful authentication :") + "<br>" +
                      "(MaxStartups)"
                font.pointSize: 12 + root.fontPadding

                wrapMode: Label.WordWrap

                Layout.preferredWidth: parent.width - 10
                Layout.fillHeight: true
                verticalAlignment: Label.AlignVCenter

                Layout.topMargin: 30
            }

            Label {
                text: qsTr("In the case of 10:30:100, if there are start(10) unauthenticated connections,") + "<br>" +
                      qsTr("connection attempts are rejected with a probability of rate(30) / 100 = 30[%].") + "<br>" +
                      qsTr("This probability increases linearly, and when number of unauthenticated connections reaches full(100),") + "<br>" +
                      qsTr("all connection attempts are rejected.")
                font.pointSize: 10 + root.fontPadding

                textFormat: Label.RichText
                wrapMode: Label.WordWrap

                verticalAlignment: Label.AlignVCenter
                Layout.preferredWidth: parent.width - 10
                Layout.fillHeight: true
            }

            TextField {
                id: maxStartupsEdit
                text: ""
                implicitWidth: root.viewWidth * 0.6
                font.pointSize: 12 + root.fontPadding
                placeholderText: qsTr("default is 10:30:100")

                horizontalAlignment: TextField.AlignRight
                verticalAlignment: TextField.AlignVCenter

                // Input limit (>= 0)
                validator: RegExpValidator {
                    regExp: /[0-9][0-9:]*/
                }
            }

            // PermitTunnel
            Label {
                id: permitTunnelLabel
                text: qsTr("Allow tunneling :") + "<br>" + "(PermitTunnel)"
                font.pointSize: 12 + root.fontPadding

                wrapMode: Label.WordWrap

                Layout.fillHeight: true
                verticalAlignment: Label.AlignVCenter

                Layout.topMargin: 30
            }

            ComboBox {
                id: boxPermitTunnel
                implicitWidth: 250
                font.pointSize: 12 + root.fontPadding

                delegate: ItemDelegate {
                    id: delegatePermitTunnel
                    width: boxPermitTunnel.implicitWidth
                    height: boxPermitTunnel.implicitHeight
                    highlighted: boxPermitTunnel.highlightedIndex === index

                    background: Rectangle {
                        color: highlighted ? root.bDark ? "steelblue" : "orchid" : "transparent"
                    }

                    contentItem: Rectangle {
                        id: delegateRectPermitTunnel
                        width: parent.width
                        height: parent.height
                        color: "transparent"

                        Label {
                            id: textPermitTunnel
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
                    id: permitTunnelModel
                    ListElement { text: "Yes" }
                    ListElement { text: "No" }
                }
            }

            // ChrootDirectory
            Label {
                id: chrootDirectoryLabel
                text: qsTr("Path to directory for chroot :") + "<br>" + "(ChrootDirectory)"
                font.pointSize: 12 + root.fontPadding

                wrapMode: Label.WordWrap

                Layout.preferredWidth: parent.width - 10
                Layout.fillHeight: true
                verticalAlignment: Label.AlignVCenter

                Layout.topMargin: 30
            }

            RoundButton {
                id: btnChrootDirectorySelect
                text: ""
                width: 48
                height: 48

                icon.source: pressed ? "qrc:/Image/OpenDirectoryPressed.png" : "qrc:/Image/OpenDirectory.png"
                icon.width: width
                icon.height: height
                icon.color: "transparent"

                padding: 0

                background: Rectangle {
                    color: "transparent"
                }

                onClicked: {
                    let iRet = 0

                    if (root.bServerMode) selectChrootDirectoryDialog.open()
                    else                  iRet = sshServerConfig.getRemoteDirectory(root.width, root.height, root.bDark, root.fontPadding, 1)

                    if (iRet !== 0) {
                        // Display error message.
                        let errMsg = sshServerConfig.getErrorMessage()

                        let componentDialog = Qt.createComponent("qrc:/ExtendQML/ErrorDialogPP.qml");
                        if (componentDialog.status === Component.Ready) {
                            let errorDialog = componentDialog.createObject(root,
                                                                           {mainWidth: root.width, mainHeight: root.height, bDark: root.bDark,
                                                                            messageTitle: qsTr("Error"),
                                                                            messageText: qsTr("Failed to select directory for chroot.") + "<br>" + errMsg});
                            errorDialog.show();
                        }
                    }
                }

                SelectFolderDialog {
                    id: selectChrootDirectoryDialog
                    mainWidth: root.viewWidth
                    mainHeight: root.viewHeight

                    onAccepted: {
                        chrootDirectoryEdit.text = strDirPath
                    }
                }
            }

            TextField {
                id: chrootDirectoryEdit
                text: ""
                implicitWidth: root.viewWidth * 0.85
                font.pointSize: 12 + root.fontPadding
                placeholderText: qsTr("default is none")

                horizontalAlignment: TextField.AlignRight
                verticalAlignment: TextField.AlignVCenter
            }

            // Banner
            Label {
                id: bannerLabel
                text: qsTr("String to be displayed when session is established :") + "<br>" + "(Banner)"
                font.pointSize: 12 + root.fontPadding

                wrapMode: Label.WordWrap

                Layout.preferredWidth: parent.width - 10
                Layout.fillHeight: true
                verticalAlignment: Label.AlignVCenter

                Layout.topMargin: 30
            }

            TextArea {
                id: bannerEdit
                text: ""
                implicitWidth: root.viewWidth * 0.85
                font.pointSize: 12 + root.fontPadding
                placeholderText: qsTr("default is none")

                horizontalAlignment: TextArea.AlignLeft
                verticalAlignment: TextArea.AlignVCenter
            }

            // VersionAddendum
            Label {
                id: versionAddendumLabel
                text: qsTr("Text to append to SSH protocol banner sent when connecting :") + "<br>" +
                      "(VersionAddendum)"
                font.pointSize: 12 + root.fontPadding

                wrapMode: Label.WordWrap

                Layout.preferredWidth: parent.width - 10
                Layout.fillHeight: true
                verticalAlignment: Label.AlignVCenter

                Layout.topMargin: 30
            }

            TextArea {
                id: versionAddendumEdit
                text: ""
                implicitWidth: root.viewWidth * 0.85
                font.pointSize: 12 + root.fontPadding
                placeholderText: qsTr("default is none")

                horizontalAlignment: TextArea.AlignLeft
                verticalAlignment: TextArea.AlignVCenter

                Layout.bottomMargin: 50
            }
        }
    }
}
