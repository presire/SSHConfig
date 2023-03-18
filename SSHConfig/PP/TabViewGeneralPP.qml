import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Controls.Universal 2.15
import "../ExtendQML"
import "../SSHServerQML"


Item {
    id: root

    property int  viewWidth:    0
    property int  viewHeight:   0
    property int  headerHeight: 0
    property int  fontPadding:  0
    property bool bDark:        false
    property bool bServerMode:  true

    property bool bReadSuccess:    false
    property var  sshServerConfig: null
    property var  sshValue:        null

    // Signal and Signal Handlers
    // Get path to host key file on remote server.
    Connections {
        target: sshServerConfig
        function onGetHostKeyFromServer(remoteFilePath) {
            // Set file path for UI.
            hostKeyList.appendModel(remoteFilePath)
        }
    }

    signal readSuccess()
    onReadSuccess: {
        // Set "Port".
        portEdit.text = sshValue.getItem("PORT")

        // Set "AddressFamily".
        let AddressFamily = sshValue.getItem("ADDRESSFAMILY")
        AddressFamily = String(AddressFamily).toUpperCase()
        boxAddressFamily.currentIndex = AddressFamily === "ANY" ? 0 : AddressFamily === "INET" ? 1 : 2

        // Set "RekeyLimit"
        let aryRekeyLimit = sshValue.getItems("REKEYLIMIT")
        let data    = aryRekeyLimit[0]
        let maxTime = aryRekeyLimit[1]

        if (String(data).toLowerCase() === "default") {
            boxRekeyLimit.currentIndex = 0
        }
        else {
            let rekeyLimitValue = String(data).length === 1 ? String(data).substring(0, String(data).length) :
                                  String(data).length >=  2 ? String(data).substring(0, String(data).length - 1) : 0
            rekeyLimitEdit.text = rekeyLimitValue

            let rekeyLimitsuffix = String(data).length === 1 ? "" :
                                   String(data).length >=  2 ? String(data).charAt(String(data).length - 1) : ""
            rekeyLimitsuffix     = String(rekeyLimitsuffix).toUpperCase()
            boxRekeyLimit.currentIndex = rekeyLimitsuffix === "K" ? 2 : rekeyLimitsuffix === "M" ? 3 : rekeyLimitsuffix === "G" ? 4 : 1
        }

        if (String(maxTime).toLowerCase() === "none") {
            checkRekeyLimitTime.checked = true
        }
        else {
            rekeyLimitTimeEdit.text = maxTime
        }

        // Set "HostKey".
        let aryHOSTKEY = sshValue.getItems("HOSTKEY")
        aryHOSTKEY.forEach(function(hostKey) {
            hostKeyList.appendModel(hostKey)
        });

        // Set "ListenAddress".
        let aryListenAddress = sshValue.getItems("LISTENADDRESS")
        aryListenAddress.forEach(function(listenAddress) {
            listenAddressList.appendModel(listenAddress)
        });

        // Set "SyslogFacility".
        let syslogFacility = sshValue.getItem("SYSLOGFACILITY")
        syslogFacility = String(syslogFacility).toUpperCase()
        boxSyslogFacility.currentIndex = syslogFacility === "DAEMON" ? 0 : syslogFacility === "USER" ? 1 : syslogFacility === "AUTH" ? 2 : syslogFacility === "LOCAL0"
                                         ? 3 : syslogFacility === "LOCAL1" ? 4 : syslogFacility === "LOCAL2" ? 5 : syslogFacility === "LOCAL3" ? 6 : syslogFacility === "LOCAL4"
                                         ? 7 : syslogFacility === "LOCAL5" ? 8 : syslogFacility === "LOCAL6" ? 9 : 10

        // Set "LogLevel".
        let logLevel = sshValue.getItem("LOGLEVEL")
        logLevel = String(logLevel).toUpperCase()
        boxLogLevel.currentIndex = logLevel === "QUITE" ? 0 : logLevel === "FATAL" ? 1 : logLevel === "ERROR" ? 2 : logLevel === "INFO"
                                   ? 3 : logLevel === "VERBOSE" ? 4 : logLevel === "DEBUG" ? 5 : logLevel === "DEBUG1"
                                   ? 6 : logLevel === "DEBUG2" ? 7 : 8

        // Set "LoginGraceTime".
        let loginGraceTime      = sshValue.getItem("LOGINGRACETIME")
        loginGraceTimeEdit.text = loginGraceTime

        // Set "StrictModes".
        let strictModes = sshValue.getItem("STRICTMODES")
        strictModes = String(strictModes).toUpperCase()
        boxStrictModes.currentIndex = strictModes === "YES" ? 0 : 1
    }

    signal writeSuccess()
    onWriteSuccess: {
        // Write "Port".
        let PORT = portEdit.text.trim()
        sshValue.setItem("PORT", PORT)

        // Write "AddressFamily".
        let AddressFamily = boxAddressFamily.currentIndex === 0 ? "any" : boxAddressFamily.currentIndex === 1 ? "inet" : "inet6"
        sshValue.setItem("ADDRESSFAMILY", AddressFamily)

        // Write "RekeyLimit"
        let RekeyLimit = boxRekeyLimit.currentIndex === 0 ? "default" : boxRekeyLimit.currentIndex === 1 ? "" :
                         boxRekeyLimit.currentIndex === 2 ? "K" : boxRekeyLimit.currentIndex === 3 ? "M" : "G"
        if (RekeyLimit !== "default") {
            RekeyLimit = rekeyLimitEdit.text + RekeyLimit
        }

        let RekeyLimitTime = checkRekeyLimitTime.checked ? "none" : rekeyLimitTimeEdit.text

        let aryRekeyLimit = []
        aryRekeyLimit[0] = RekeyLimit
        aryRekeyLimit[1] = RekeyLimitTime

        sshValue.setItems("REKEYLIMIT", aryRekeyLimit)

        // Write "HostKey".
        let aryHOSTKEY = hostKeyList.fnGetData()
        sshValue.setItems("HOSTKEY", aryHOSTKEY)

        // Write "ListenAddress".
        let aryData = listenAddressList.fnGetData()
        let aryListenAddress = []
        for(let i = 0; i < aryData.length; i++) {
            aryListenAddress.push(aryData[i].trim())
        }
        sshValue.setItems("LISTENADDRESS", aryListenAddress)

        // Write "SyslogFacility".
        let SyslogFacility = boxSyslogFacility.currentIndex === 0 ? "DAEMON" : boxSyslogFacility.currentIndex === 1 ? "USER"   :
                             boxSyslogFacility.currentIndex === 2 ? "AUTH"   : boxSyslogFacility.currentIndex === 3 ? "LOCAL0" :
                             boxSyslogFacility.currentIndex === 4 ? "LOCAL1" : boxSyslogFacility.currentIndex === 5 ? "LOCAL2" :
                             boxSyslogFacility.currentIndex === 6 ? "LOCAL3" : boxSyslogFacility.currentIndex === 7 ? "LOCAL4" :
                             boxSyslogFacility.currentIndex === 8 ? "LOCAL5" : boxSyslogFacility.currentIndex === 9 ? "LOCAL6" : "LOCAL7"
        sshValue.setItem("SYSLOGFACILITY", SyslogFacility)

        // Write "LogLevel".
        let LogLevel = boxLogLevel.currentIndex === 0 ? "QUITE"   : boxLogLevel.currentIndex === 1 ? "FATAL"  :
                       boxLogLevel.currentIndex === 2 ? "ERROR"   : boxLogLevel.currentIndex === 3 ? "INFO"   :
                       boxLogLevel.currentIndex === 4 ? "VERBOSE" : boxLogLevel.currentIndex === 5 ? "DEBUG"  :
                       boxLogLevel.currentIndex === 6 ? "DEBUG1"  : boxLogLevel.currentIndex === 7 ? "DEBUG2" : "DEBUG3"
        sshValue.setItem("LOGLEVEL", LogLevel)

        // Write "LoginGraceTime".
        sshValue.setItem("LOGINGRACETIME", loginGraceTimeEdit.text)

        // Write "StrictModes".
        let StrictModes = boxStrictModes.currentIndex === 0 ? "yes" : "no"
        sshValue.setItem("STRICTMODES", StrictModes)
    }

    signal clear()
    onClear: {
        // Clear "Port".
        portEdit.text = ""

        // Clear "AddressFamily".
        boxAddressFamily.currentIndex = 0

        // Clear "RekeyLimit"
        boxRekeyLimit.currentIndex = 0
        rekeyLimitEdit.text = ""

        checkRekeyLimitTime.checked = true
        rekeyLimitTimeEdit.text = ""

        // Clear "HostKey".
        hostKeyList.clearModel()

        // Clear "ListenAddress".
        listenAddressList.clearModel()

        // Clear "SyslogFacility".
        boxSyslogFacility.currentIndex = 0

        // Clear "LogLevel".
        boxLogLevel.currentIndex = 0

        // Clear "LoginGraceTime".
        loginGraceTimeEdit.text = ""

        // Clear "StrictModes".
        boxStrictModes.currentIndex = 0
    }

    ScrollView {
        id: scrollAuthentication
        width: parent.viewWidth
        height : parent.viewHeight
        contentWidth: tabGeneralColumn.width    // The important part
        contentHeight: tabGeneralColumn.height  // Same
        clip: true                              // Prevent drawing column outside the scrollview borders

        ScrollBar.vertical.interactive: true

        ColumnLayout {
            id: tabGeneralColumn
            width: root.viewWidth

            // "Port"
            RowLayout {
                id: portRow
                x: parent.x
                width: parent.width
                spacing: 20

                Layout.fillWidth: true
                Layout.topMargin: 20

                Label {
                    id: portLabel
                    text: qsTr("Port :")
                    font.pointSize: 12 + root.fontPadding

                    wrapMode: Label.WordWrap

                    Layout.fillHeight: true
                    verticalAlignment: Label.AlignVCenter
                }

                TextField {
                    id: portEdit
                    text: ""
                    implicitWidth: Math.round((root.viewWidth - portLabel.width - tabGeneralColumn.spacing * 2 - portRow.spacing) * 0.8)
                    font.pointSize: 12 + root.fontPadding
                    placeholderText: qsTr("Specify SSH Port Number")

                    horizontalAlignment: TextField.AlignRight
                    verticalAlignment: TextField.AlignVCenter

                    // Input limit (1 - 65535)
                    validator: RegularExpressionValidator {
                        regularExpression: /[1-9][0-9, ]*|65535/
                    }

                    // Input limit (No input allowed for 65536 or higher)
                    onTextEdited: {
                        if (acceptableInput) {
                            let ary = text.split(",")
                            for (let i = 0; i < ary.length; i++) {
                                let value = ary[i].replace(" ", "")

                                if (value === "0" || value > 65535) {
                                    text = displayText
                                    break
                                }

                                let firstCharacter = value.charAt(0)
                                if (firstCharacter === "0") {
                                    text = displayText
                                    break
                                }
                            }
                        }
                    }
                }
            }

            Label {
                text: qsTr("If specify multiple ports, input separated by commas(,).") + "<br>" +
                      qsTr("Example. 22, 49152, 65000")
                font.pointSize: 10 + root.fontPadding

                textFormat: Label.RichText
                wrapMode: Label.WordWrap

                verticalAlignment: Label.AlignVCenter
                Layout.preferredWidth: parent.width - 10
                Layout.fillHeight: true
            }

            // AddressFamily
            Label {
                id: labelAddressFamily
                text: qsTr("Protocols that allow connections :") + "<br>" +
                      "(AddressFamily)"
                font.pointSize: 12 + root.fontPadding

                textFormat: Label.RichText
                wrapMode: Label.WordWrap

                verticalAlignment: Label.AlignVCenter
                Layout.preferredWidth: parent.width - 10
                Layout.fillHeight: true

                Layout.topMargin: 30
            }

            Label {
                text: "<b><u>any (default)</u></b> :" + "<br>" +
                      qsTr("Allow both IPv4 and IPv6.") + "<br><br>" +
                      "<b><u>inet</u></b> :" + "<br>" +
                      qsTr("Allow IPv4 only.") + "<br><br>" +
                      "<b><u>inet6</u></b> :" + "<br>" +
                      qsTr("Allow IPv6 only.")

                font.pointSize: 10 + root.fontPadding

                textFormat: Label.RichText
                wrapMode: Label.WordWrap

                verticalAlignment: Label.AlignVCenter
                Layout.preferredWidth: parent.width - 10
                Layout.fillHeight: true
            }

            ComboBox {
                id: boxAddressFamily
                implicitWidth: 300
                font.pointSize: 12 + root.fontPadding

                delegate: ItemDelegate {
                    id: delegateAddressFamily
                    width: boxAddressFamily.implicitWidth
                    height: boxAddressFamily.implicitHeight
                    highlighted: boxAddressFamily.highlightedIndex === index

                    background: Rectangle {
                        color: highlighted ? root.bDark ? "steelblue" : "orchid" : "transparent"
                    }

                    contentItem: Rectangle {
                        id: delegateRectAddressFamily
                        width: parent.width
                        height: parent.height
                        color: "transparent"

                        Label {
                            id: textAddressFamily
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
                    id: addressFamilyModel
                    ListElement { text: "any (IPv4 and IPv6)" }
                    ListElement { text: "inet (IPv4)" }
                    ListElement { text: "inet6 (IPv6)" }
                }
            }

            // "RekeyLimit"
            Label {
                id: labelRekeyLimit
                width: parent.width - parent.spacing
                text: qsTr("Session key regeneration :") + "<br>" +
                      "(RekeyLimit)"
                font.pointSize: 12 + root.fontPadding
                wrapMode: Label.WordWrap

                background: null

                verticalAlignment: Label.AlignVCenter
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.topMargin: 30
            }

            Label {
                width: parent.width - parent.spacing
                text: qsTr("If too small, performance may be adversely affected.") + "<br>" +
                      qsTr("\"default\"(Initial setting) is to regenerate at appropriate times between 1[GB] and 4[GB].")
                font.pointSize: 10 + root.fontPadding
                wrapMode: Label.WordWrap

                background: null

                verticalAlignment: Label.AlignVCenter
                Layout.preferredWidth: parent.width - 10
                Layout.fillHeight: true
            }

            TextField {
                id: rekeyLimitEdit
                text: ""
                implicitWidth: root.viewWidth * 0.5
                font.pointSize: 12 + root.fontPadding
                placeholderText: enabled ? "" : qsTr("\"default\" is selected")

                horizontalAlignment: TextField.AlignRight
                verticalAlignment: TextField.AlignVCenter

                // Input limit (>= 0)
                validator: RegExpValidator {
                    regExp: /[0]|[1-9][0-9]*/
                }
            }

            ComboBox {
                id: boxRekeyLimit
                implicitWidth: 200
                font.pointSize: 12 + root.fontPadding

                delegate: ItemDelegate {
                    id: itemDlgt
                    width: boxRekeyLimit.implicitWidth
                    height: boxRekeyLimit.implicitHeight
                    highlighted: boxRekeyLimit.highlightedIndex === index

                    background: Rectangle {
                        color: highlighted ? root.bDark ? "steelblue" : "orchid" : "transparent"
                    }

                    contentItem: Rectangle {
                        id: rectDlgt
                        width: parent.width
                        height: parent.height
                        color: "transparent"

                        Label {
                            id:textItem
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
                    id: rekeyLimitModel
                    ListElement { text: "default" }
                    ListElement { text: "[Byte]" }
                    ListElement { text: "[KB]" }
                    ListElement { text: "[MB]" }
                    ListElement { text: "[GB]" }
                }

                onCurrentIndexChanged: {
                    if (currentIndex <= 0) {
                        rekeyLimitEdit.enabled = false
                    }
                    else {
                        rekeyLimitEdit.enabled = true
                    }
                }
            }

            Label {
                id: labelRekeyLimitTime
                text: qsTr("Exchange key Time [sec] :")
                font.pointSize: 12 + root.fontPadding

                wrapMode: Label.WordWrap

                Layout.fillHeight: true
                verticalAlignment: Label.AlignVCenter
            }

            RowLayout {
                id: rekeyLimitTimeRow
                width: parent.width
                Layout.fillWidth: true
                spacing: 20

                CheckBox {
                    id: checkRekeyLimitTime
                    width: parent.height
                    height: parent.height
                    text: "none"
                    font.pointSize: 12 + root.fontPadding
                    checked: false

                    Layout.alignment: Qt.AlignVCenter
                }

                TextField {
                    id: rekeyLimitTimeEdit
                    implicitWidth: Math.round((root.viewWidth - tabGeneralColumn.spacing * 2 - rekeyLimitTimeRow.spacing) * 0.5)
                    text: ""
                    font.pointSize: 12 + root.fontPadding
                    placeholderText: ""
                    enabled: checkRekeyLimitTime.checked ? false : true

                    horizontalAlignment: TextField.AlignRight
                    verticalAlignment: TextField.AlignVCenter

                    // Input limit (Ex. 0 or 10s or 10m or 1h30m)
                    validator: RegExpValidator {
                        regExp: /[0]|[1-9]+[0-9sSmMhHdDwW]+/
                    }
                }
            }

            // "HostKey"
            ColumnLayout {
                id: hostKeyColumn
                width: root.width
                spacing: 20

                Layout.topMargin: 30

                RowLayout {
                    id: hostKeyRow
                    spacing: 20

                    Label {
                        id: labelHostKey
                        text: qsTr("Path to private key for host authentication :") + "<br>" + "(HostKey)"
                        font.pointSize: 12 + root.fontPadding

                        textFormat: Label.RichText
                        wrapMode: Label.WordWrap

                        verticalAlignment: Label.AlignVCenter
                        Layout.maximumWidth: root.width - btnFileSelect.width - btnAddHostKey.width - 60
                        Layout.fillHeight: true
                    }

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

                            if (root.bServerMode) selectHostKeyDialog.open()
                            else                  iRet = sshServerConfig.getHostKeyFile(root.width, root.height, root.bDark, root.fontPadding)

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
                            id: selectHostKeyDialog
                            mainWidth: root.viewWidth
                            mainHeight: root.viewHeight
                            filters: "Host Key file (*)"

                            onSelectedFile: {
                                hostKeyList.appendModel(strFilePath)
                            }
                        }
                    }

                    RoundButton {
                        id: btnAddHostKey
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
                            hostKeyList.appendModel("")
                        }
                    }
                }

                SSHOptionListViewPP {
                    id: hostKeyList
                    width: root.width * 0.85
                    implicitWidth: root.width * 0.85

                    headerHeight:  root.headerHeight
                    fontPadding:   root.fontPadding
                    bDark:         root.bDark
                    parentName:    root
                }
            }

            // "ListenAddress"
            ColumnLayout {
                id: listenAddressColumn
                width: root.width
                spacing: 20

                Layout.topMargin: 30

                RowLayout {
                    id: listenAddressRow
                    spacing: 20

                    Label {
                        id: labelListenAddress
                        text: qsTr("Interface to accept connections :") + "<br>" + "(ListenAddress)"
                        font.pointSize: 12 + root.fontPadding

                        textFormat: Label.RichText
                        wrapMode: Label.WordWrap

                        verticalAlignment: Label.AlignVCenter
                        Layout.fillHeight: true
                    }

                    RoundButton {
                        id: btnAddListenAddress
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
                            listenAddressList.appendModel("")
                        }
                    }
                }

                SSHOptionListViewPP {
                    id: listenAddressList
                    width: root.width * 0.85
                    implicitWidth: root.width * 0.85

                    headerHeight: root.headerHeight
                    fontPadding:  root.fontPadding
                    bDark:        root.bDark
                    parentName:   root
                }
            }

            // Logging
            //// SyslogFacility
            Label {
                id: labelSyslogFacility
                text: qsTr("Facility for log messages output to syslog server :") + "<br>" + "(SyslogFacility)"
                font.pointSize: 12 + root.fontPadding

                textFormat: Label.RichText
                wrapMode: Label.WordWrap

                verticalAlignment: Label.AlignVCenter
                Layout.preferredWidth: parent.width - 10
                Layout.fillHeight: true

                Layout.topMargin: 30
            }

            Label {
                text: qsTr("Default is \"AUTH\"")
                font.pointSize: 10 + root.fontPadding

                textFormat: Label.RichText
                wrapMode: Label.WordWrap

                verticalAlignment: Label.AlignVCenter
                Layout.fillHeight: true
            }

            ComboBox {
                id: boxSyslogFacility
                implicitWidth: 300
                font.pointSize: 12 + root.fontPadding

                delegate: ItemDelegate {
                    id: delegateSyslogFacility
                    width: boxSyslogFacility.implicitWidth
                    height: boxSyslogFacility.implicitHeight
                    highlighted: boxSyslogFacility.highlightedIndex === index

                    background: Rectangle {
                        color: highlighted ? root.bDark ? "steelblue" : "orchid" : "transparent"
                    }

                    contentItem: Rectangle {
                        id: delegateRectSyslogFacility
                        width: parent.width
                        height: parent.height
                        color: "transparent"

                        Label {
                            id: textSyslogFacility
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
                    id: addressSyslogFacilityModel
                    ListElement { text: "DAEMON" }
                    ListElement { text: "USER" }
                    ListElement { text: "AUTH" }
                    ListElement { text: "LOCAL0" }
                    ListElement { text: "LOCAL1" }
                    ListElement { text: "LOCAL2" }
                    ListElement { text: "LOCAL3" }
                    ListElement { text: "LOCAL4" }
                    ListElement { text: "LOCAL5" }
                    ListElement { text: "LOCAL6" }
                    ListElement { text: "LOCAL7" }
                }
            }

            //// LogLevel
            Label {
                id: labelLogLevel
                text: qsTr("Level of log output by sshd :") + "<br>" + "(LogLevel)"
                font.pointSize: 12 + root.fontPadding

                textFormat: Label.RichText
                wrapMode: Label.WordWrap

                verticalAlignment: Label.AlignVCenter
                Layout.preferredWidth: parent.width - 10
                Layout.fillHeight: true

                Layout.topMargin: 30
            }

            Label {
                text: qsTr("Default is \"INFO\"")
                font.pointSize: 10 + root.fontPadding

                textFormat: Label.RichText
                wrapMode: Label.WordWrap

                verticalAlignment: Label.AlignVCenter
                Layout.fillHeight: true
            }

            ComboBox {
                id: boxLogLevel
                implicitWidth: 300
                font.pointSize: 12 + root.fontPadding

                delegate: ItemDelegate {
                    id: delegateLogLevel
                    width: boxLogLevel.implicitWidth
                    height: boxLogLevel.implicitHeight
                    highlighted: boxLogLevel.highlightedIndex === index

                    background: Rectangle {
                        color: highlighted ? root.bDark ? "steelblue" : "orchid" : "transparent"
                    }

                    contentItem: Rectangle {
                        id: delegateRectLogLevel
                        width: parent.width
                        height: parent.height
                        color: "transparent"

                        Label {
                            id: textLogLevel
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
                    id: addressLogLevelModel
                    ListElement { text: "QUITE" }
                    ListElement { text: "FATAL" }
                    ListElement { text: "ERROR" }
                    ListElement { text: "INFO" }
                    ListElement { text: "VERBOSE" }
                    ListElement { text: "DEBUG" }
                    ListElement { text: "DEBUG1" }
                    ListElement { text: "DEBUG2" }
                    ListElement { text: "DEBUG3" }
                }
            }

            // LoginGraceTime
            Label {
                text: qsTr("Time to automatically disconnect the server, if a user fails to log in within the specified time [sec] :") + "<br>" +
                      "(LoginGraceTime)"
                font.pointSize: 12 + root.fontPadding

                textFormat: Label.RichText
                wrapMode: Label.WordWrap

                verticalAlignment: Label.AlignVCenter
                Layout.preferredWidth: parent.width - 10
                Layout.fillHeight: true
                Layout.topMargin: 30
            }

            Label {
                id: loginGraceTimeLabel
                text: qsTr("<u>If the value is 0, there is no time limit</u>.") + "<br>" +
                      qsTr("Default is 120 [sec]")
                font.pointSize: 10 + root.fontPadding

                textFormat: Label.RichText
                wrapMode: Label.WordWrap

                Layout.preferredWidth: parent.width - 10
                Layout.fillHeight: true
                verticalAlignment: Label.AlignVCenter
            }

            TextField {
                id: loginGraceTimeEdit
                text: ""
                implicitWidth: root.viewWidth * 0.35 > 300 ? root.viewWidth * 0.35 : 300
                font.pointSize: 12 + root.fontPadding
                placeholderText: ""

                horizontalAlignment: TextField.AlignRight
                verticalAlignment: TextField.AlignVCenter

                // Input limit (Ex. 0 or 10s or 10m or 1h30m)
                validator: RegExpValidator {
                    regExp: /[0]|[1-9]+[0-9sSmMhHdDwW]+/
                }

                // Input limit
                onTextEdited: {
                }
            }

            // StrictModes
            Label {
                id: strictModesLabel
                text: qsTr("Check directory and file permissions for logged-in users before login :") + "<br>" +
                      "(StrictModes)"
                font.pointSize: 12 + root.fontPadding

                textFormat: Label.RichText
                wrapMode: Label.WordWrap

                Layout.preferredWidth: parent.width - 10
                Layout.fillHeight: true
                verticalAlignment: Label.AlignVCenter

                Layout.topMargin: 30
            }

            Label {
                text: qsTr("Default is \"yes\"")
                font.pointSize: 10 + root.fontPadding

                textFormat: Label.RichText
                wrapMode: Label.WordWrap

                Layout.fillHeight: true
                verticalAlignment: Label.AlignVCenter
            }

            ComboBox {
                id: boxStrictModes
                implicitWidth: 300
                font.pointSize: 12 + root.fontPadding

                Layout.bottomMargin: 50

                delegate: ItemDelegate {
                    id: delegateStrictModes
                    width: boxStrictModes.implicitWidth
                    height: boxStrictModes.implicitHeight
                    highlighted: boxStrictModes.highlightedIndex === index

                    background: Rectangle {
                        color: highlighted ? root.bDark ? "steelblue" : "orchid" : "transparent"
                    }

                    contentItem: Rectangle {
                        id: delegateRectStrictModes
                        width: parent.width
                        height: parent.height
                        color: "transparent"

                        Label {
                            id: textStrictModes
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
                    id: addressStrictModes
                    ListElement { text: "Yes" }
                    ListElement { text: "No" }
                }
            }
        }
    }
}
