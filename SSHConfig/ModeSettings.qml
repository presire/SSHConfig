import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Controls.Universal 2.15
import "ExtendQML"


Item {
    id: root
    objectName: "root"

    focus: true

    property var parentName:  null
    property var sshService:  null
    property var windowState: null

    // Buffer for configuration information.
    property bool   bOldServerMode:    true
    property bool   bOldAdminPassword: true
    property int    oldFontCheck:      0
    property bool   bOldTheme:         false
    property int    oldLangIndex:      0

    // Edited the settings
    property bool   bServerMode:    true
    property bool   bAdminPassword: true
    property int    fontCheck:      0
    property int    fontPadding:    0
    property bool   bTheme:         false
    property int    langIndex:      0

    // Edit Flag
    property int    editStatus: 0

    // Save Flag
    property bool   bSaved: false

    // Return View Name
    property string viewName: ""

    Component.onCompleted: {
        // Set font size
        if (root.oldFontCheck === 0) {
            fontSmallBtn.checked = true
        }
        else if (root.oldFontCheck === 1) {
            fontMediumBtn.checked = true
        }
        else {
            fontLargeBtn.checked = true
        }

        // Read mode option.
        bOldServerMode    = windowState.getServerMode()
        bOldAdminPassword = windowState.getAdminPassword()
        bOldTheme         = windowState.getColorMode()
        oldLangIndex      = windowState.getLanguage()

        // Set edited mode option.
        bServerMode    = bOldServerMode
        bAdminPassword = bOldAdminPassword
        fontCheck      = oldFontCheck
        fontPadding    = root.oldFontCheck === 0 ? -3 : root.oldFontCheck === 1 ? 0 : 3
        bTheme         = bOldTheme
        langIndex      = oldLangIndex
    }

    // Reload settings, when pressed [Save] button or [Save & Restart] button.
    function fnReload() {
        // Reload settings.
        root.bServerMode  = windowState.getServerMode()
        root.oldFontCheck = windowState.getFontSize()
        root.fontPadding  = root.oldFontCheck === 0 ? -3 : root.oldFontCheck === 1 ? 0 : 3
        Component.completed()

        // Reflect the reloaded settings on the screen.
        parentName.bServerMode = windowState.getServerMode()
        parentName.fontCheck   = windowState.getFontSize()
    }

    function fnSaveModeSettings(_viewName, move) {
        root.viewName = _viewName

        //if (editStatus !== 0x00 && bSaved === false) {
        if (editStatus !== 0x00) {
            let componentDialog = Qt.createComponent("qrc:///ExtendQML/SaveDialog.qml");
            if (componentDialog.status === Component.Ready) {
                let saveDialog = componentDialog.createObject(root,
                                                              {mainWidth: root.width, mainHeight: root.height, windowState: windowState,
                                                               bServerMode: root.bServerMode, bAdminPassword: root.bAdminPassword,
                                                               iFont: root.fontCheck, bTheme: root.bTheme, move: move});
                saveDialogConnection.target = saveDialog
                saveDialog.show();
            }
        }
        else {
            root.parentName.screenMoved("", move)
        }
    }

    Connections {
        id: saveDialogConnection
        function onVisibleChanged() {
            if(!target.visible) {
                if (target.state === 0) {
                    // After Save the setting
                    root.editStatus = 0
                    root.fnReload()

                    root.parentName.screenMoved("", target.move)
                }
                else if (target.state === 1) {
                    // After do not save the setting
                    root.parentName.screenMoved("", target.move)
                }

                target = null
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.ForwardButton | Qt.BackButton  // Enable "ForwardButton" and "BackButton" on mouse
        z: 1

        // Single click
        onClicked: {
            if (mouse.button === Qt.ForwardButton) {
                fnSaveModeSettings("", 1)
            }
            else if (mouse.button === Qt.BackButton) {
                fnSaveModeSettings("", 0)
            }
        }
    }

    ScrollView {
        id: scrollModeSettings
        width: parent.width
        height : parent.height
        contentWidth: modeColumn.width    // The important part
        contentHeight: modeColumn.height  // Same
        anchors.fill: parent
        clip : true                       // Prevent drawing column outside the scrollview borders

        ColumnLayout {
            id: modeColumn
            width: parent.width
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 5

            // Select [Server Mode] or [Client Mode]
            Label {
                text: qsTr("Server Mode")
                font.pointSize: 16 + root.fontPadding

                wrapMode: Label.WordWrap

                verticalAlignment: Label.AlignVCenter
                Layout.fillHeight: true
                Layout.topMargin: 30
                Layout.leftMargin: (root.width - width) / 2
            }

            Label {
                text: qsTr("Server Mode edits the SSH settings installed on itself.") + "<br>" +
                      qsTr("When this is disabled, edits SSH settings for the server to which it connects.")

                textFormat: Label.RichText
                font.pointSize: 12 + root.fontPadding

                wrapMode: Label.WordWrap

                verticalAlignment: Label.AlignVCenter
                Layout.maximumWidth: root.width * 0.85
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignTop | Qt.AlignVCenter
                Layout.topMargin: 10
                Layout.leftMargin: (root.width - width) / 2
            }

            Switch {
                id: serverSwitch
                text: qsTr("Server Mode")
                font.pointSize: 12 + root.fontPadding
                indicator.width: 150
                indicator.height: 35
                enabled: true
                checked: root.bOldServerMode

                Layout.alignment: Qt.AlignVCenter
                Layout.topMargin: 10
                Layout.leftMargin: (root.width - width) / 2

                onToggled: {
                    if (checked !== bOldServerMode) editStatus |= 0x01
                    else                            editStatus = editStatus & ~0x01

                    root.bServerMode = checked
                }

                //            indicator: Rectangle {
                //                implicitWidth: Math.min(200, modeColumn.width / 2)
                //                implicitHeight: 35
                //                x: serverSwitch.width - width - serverSwitch.rightPadding
                //                y: (parent.height - height) / 2
                //                radius: 3
                //                color: serverSwitch.enabled ? serverSwitch.checked ? "steelblue" : "white" : "darkgrey"
                //                border.width: 2
                //                border.color: "black"

                //                Rectangle {
                //                    x: serverSwitch.checked ? parent.width - width : 0
                //                    width: parent.height
                //                    height: parent.height
                //                    color: "darkgrey"
                //                    radius: 3
                //                    border.width: 2
                //                    border.color: "black"
                //                }
                //            }
            }

            // Change [Need Administrator Password]
            Label {
                text: qsTr("Need Administrator Password")
                font.pointSize: 16 + root.fontPadding

                wrapMode: Label.WordWrap

                verticalAlignment: Label.AlignVCenter
                Layout.fillHeight: true
                Layout.topMargin: 50
                Layout.leftMargin: (root.width - width) / 2
            }

            Label {
                text: qsTr("By disabling this setting,") + "<br>" +
                      qsTr("you can read and write \"sshd_config\" without password,") + "<br>" +
                      qsTr("in situations where an administrator password is required.") + "<br><br>" +
                      qsTr("<u><B>This setting is valid only in Server Mode because related to Polkit Action.</B></u>") + "<br>" +
                      qsTr("<u><B>Note that disabling this setting may be a security risk.</B></u>")

                textFormat: Label.RichText
                font.pointSize: 12 + root.fontPadding

                wrapMode: Label.WordWrap

                verticalAlignment: Label.AlignVCenter
                Layout.maximumWidth: root.width * 0.85
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignTop | Qt.AlignVCenter
                Layout.topMargin: 10
                Layout.leftMargin: (root.width - width) / 2
            }

            Switch {
                id: adminPasswordSwitch
                text: ""
                font.pointSize: 12 + root.fontPadding
                indicator.width: 150
                indicator.height: 35
                enabled: true
                checked: root.bOldAdminPassword

                Layout.alignment: Qt.AlignVCenter
                Layout.topMargin: 10
                Layout.leftMargin: (root.width - width) / 2

                onToggled: {
                    let iRet = sshService.changeAdminPassword(!checked)
                    if (iRet === 0) {
                        // If settings are successfully changed.

                        // Save Need Administrator Password.
                        windowState.setAdminPassword(adminPasswordSwitch.checked)

                        root.bAdminPassword = checked
                    }
                    else if (iRet === -1) {
                        // If failure to change settings.
                        checked = !checked

                        let errMsg = windowState.getErrorMessage()

                        let componentDialog = Qt.createComponent("qrc:///ExtendQML/ErrorDialog.qml");
                        if (componentDialog.status === Component.Ready) {
                            var errorDialog = componentDialog.createObject(root,
                                                                           {mainWidth: root.width, mainHeight: root.height, bDark: root.bTheme,
                                                                            messageTitle: qsTr("Error"),
                                                                            messageText: qsTr("Failed to change the settings.") + "<br>" + errMsg});
                            errorDialog.show();
                        }
                    }
                    else {
                        // If the [Cancel] button is pressed, when entering the password for administrative privileges.
                        checked = !checked
                    }
                }
            }

            Label {
                text: qsTr("Font Size")
                font.pointSize: 16 + root.fontPadding
                color: windowState.getColorMode() ? "#ffffff" : "#000000"

                wrapMode: Label.WordWrap

                verticalAlignment: Label.AlignVCenter
                Layout.fillHeight: true

                Layout.topMargin: 50
                Layout.leftMargin: (root.width - width) / 2
            }

            RowLayout {
                id: fontRow
                width: parent.width
                Layout.fillWidth: true

                spacing: 20
                Layout.alignment: Qt.AlignVCenter
                Layout.leftMargin: (root.width - width) / 2

                ButtonGroup {
                    id: fontGroup
                    buttons: fontRow.children

                    onClicked: {
                        let checkFont = fontSmallBtn.checked ? 0 : fontMediumBtn.checked ? 1 : 2
                        if (checkFont !== root.oldFontCheck) editStatus |= 0x04
                        else                                             editStatus &= ~0x04
                    }
                }

                RadioButton {
                    id: fontSmallBtn
                    text: qsTr("Small")
                    font.pointSize: 14 + root.fontPadding
                    indicator.scale: 1.25

                    ButtonGroup.group: fontGroup

                    onClicked: {
                        root.fontCheck = 0
                    }
                }

                RadioButton {
                    id: fontMediumBtn
                    text: qsTr("Medium")
                    font.pointSize: 14 + root.fontPadding
                    indicator.scale: 1.25

                    ButtonGroup.group: fontGroup

                    onClicked: {
                        root.fontCheck = 1
                    }
                }

                RadioButton {
                    id: fontLargeBtn
                    text: qsTr("Large")
                    font.pointSize: 14 + root.fontPadding
                    indicator.scale: 1.25

                    ButtonGroup.group: fontGroup

                    onClicked: {
                        root.fontCheck = 2
                    }
                }
            }

            // Select Dark Theme.
            Label {
                text: qsTr("Dark Theme")
                font.pointSize: 16 + root.fontPadding

                wrapMode: Label.WordWrap

                verticalAlignment: Label.AlignVCenter
                Layout.fillHeight: true
                Layout.topMargin: 50
                Layout.leftMargin: (root.width - width) / 2
            }

            Label {
                text: qsTr("When you restart this software, the color theme will change.")
                font.pointSize: 12 + root.fontPadding

                wrapMode: Label.WordWrap

                verticalAlignment: Label.AlignVCenter
                Layout.maximumWidth: root.width * 0.85
                Layout.fillHeight: true
                Layout.topMargin: 10
                Layout.leftMargin: (root.width - width) / 2
            }

            Switch {
                id: themeSwitch
                text: qsTr("Dark")
                font.pointSize: 12 + root.fontPadding
                indicator.width: 150
                indicator.height: 35
                checked: root.bOldTheme

                Layout.alignment: Qt.AlignVCenter
                Layout.topMargin: 10
                Layout.leftMargin: (root.width - width) / 2

                onToggled: {
                    if (checked !== bOldTheme) editStatus |= 0x08
                    else                       editStatus &= ~0x08

                    root.bTheme = checked
                }
            }

            // Select Language.
            Label {
                text: qsTr("Language")
                font.pointSize: 16 + root.fontPadding

                wrapMode: Label.WordWrap

                verticalAlignment: Label.AlignVCenter
                Layout.fillHeight: true
                Layout.topMargin: 50
                Layout.leftMargin: (root.width - width) / 2
            }

            Label {
                text: qsTr("When you restart this software, the locale will change.")
                font.pointSize: 12 + root.fontPadding

                wrapMode: Label.WordWrap

                verticalAlignment: Label.AlignVCenter
                Layout.maximumWidth: root.width * 0.85
                Layout.fillHeight: true
                Layout.topMargin: 10
                Layout.leftMargin: (root.width - width) / 2
            }

            ComboBox {
                id: boxLanguage
                implicitWidth: 300
                font.pointSize: 14 + root.fontPadding
                currentIndex: root.oldLangIndex

                Layout.topMargin: 10
                Layout.leftMargin: (root.width - width) / 2

                delegate: ItemDelegate {
                    id: delegateLanguage
                    width: boxLanguage.implicitWidth
                    height: boxLanguage.implicitHeight
                    highlighted: boxLanguage.highlightedIndex === index

                    background: Rectangle {
                        color: highlighted ? root.bDark ? "steelblue" : "orchid" : "transparent"
                    }

                    contentItem: Rectangle {
                        id: delegateRectLanguage
                        width: parent.width
                        height: parent.height
                        color: "transparent"

                        Label {
                            id: textLanguage
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
                    id: languageModel
                    ListElement { text: qsTr("Default") }
                    ListElement { text: qsTr("Jap") }
                }

                onCurrentIndexChanged: {
                    if (root.oldLangIndex !== currentIndex) editStatus |= 0x10
                    else                                                editStatus &= ~0x10
                }
            }

            RowLayout {
                width: parent.width
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                Layout.topMargin: 50
                Layout.leftMargin: (root.width - width) / 2
                Layout.bottomMargin: 50

                spacing: 20

                Button {
                    id: modeSaveBtn
                    text: qsTr("Save")
                    font.pointSize: 12 + root.fontPadding
                    flat: true
                    enabled: root.editStatus !== 0x00 ? true : false

                    implicitWidth: Math.max(200, parent.width / 5)
                    implicitHeight: Math.max(50, parent.height / 5)

                    contentItem: Label {
                        text: parent.text
                        font: parent.font
                        opacity: enabled ? 1.0 : 0.3
                        color: windowState.getColorMode() ? parent.pressed ? "#cccccc" : "#ffffff" : parent.pressed ? "#333333" : "#000000"
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
                        root.bSaved     = true
                        root.editStatus = 0

                        // Save Server Mode.
                        windowState.setServerMode(serverSwitch.checked)

                        // Save Font.
                        let fontCheck = fontSmallBtn.checked ? 0 : fontMediumBtn.checked ? 1 : 2
                        windowState.setFontSize(fontCheck)

                        // Save ColorMode.
                        if (themeSwitch.checked !== bOldTheme) {
                            windowState.setColorModeOverWrite(true)
                        }

                        // Save language.
                        windowState.setLanguage(boxLanguage.currentIndex)

                        root.fnReload()

                        completePopup.open()
                    }
                }

                Button {
                    id: restartBtn
                    implicitWidth: Math.max(200, parent.width / 5)
                    implicitHeight: Math.max(50, parent.height / 5)
                    text: qsTr("Save & Restart")
                    font.pointSize: 12 + root.fontPadding
                    flat: true
                    enabled: root.editStatus !== 0x00 ? true : false

                    Layout.alignment: Qt.AlignHCenter

                    contentItem: Label {
                        text: parent.text
                        font: parent.font
                        opacity: enabled ? 1.0 : 0.3
                        color: windowState.getColorMode() ? parent.pressed ? "#cccccc" : "#ffffff" : parent.pressed ? "#333333" : "#000000"
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
                        // Save settings.
                        restartDialog.bServerMode = serverSwitch.checked
                        restartDialog.fontCheck   = fontSmallBtn.checked ? 0 : fontMediumBtn.checked ? 1 : 2
                        restartDialog.bTheme      = themeSwitch.checked
                        restartDialog.langIndex   = boxLanguage.currentIndex
                        restartDialog.show()
                    }

                    RestartDialog {
                        id: restartDialog
                        mainWidth: parentName.width
                        mainHeight: parentName.height

                        parentName: root.parentName
                        windowState: root.windowState
                    }
                }
            }
        }

        Popup {
            id: completePopup
            x: Math.round(root.width / 10) / 2
            y: 50
            width: Math.round(root.width / 10 * 9)

            modal: true
            focus: true
            closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside | Popup.CloseOnPressOutsideParent

            enter: Transition {
                NumberAnimation {
                    property: "opacity"
                    from: 0.0
                    to: 1.0
                    duration: 500
                }
            }

            exit: Transition {
                NumberAnimation {
                    property: "opacity"
                    from: 1.0
                    to: 0.0
                    duration: 500
                }
            }

            Overlay.modal: Item {
                Rectangle {
                    color: "black"
                    opacity: 0.3
                    anchors.fill: parent
                }
            }

            background: Rectangle {
                color: "#333333"
                border.color: "darkgrey"
                border.width: 0
                radius: 5
            }

            ColumnLayout {
                id: completeColumn
                x: parent.x
                width: parent.width
                spacing: 20

                Layout.margins: 50

                Label {
                    text: qsTr("Saved the settings")
                    font.pointSize: 16 + root.fontPadding
                    color: "white"

                    horizontalAlignment: Label.AlignHCenter
                    verticalAlignment: Label.AlignVCenter
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.topMargin: 20
                    Layout.bottomMargin: 20

                    wrapMode: Label.WordWrap
                }
            }

            onOpened: {
                completeTimer.start();
            }

            Timer {
                id: completeTimer

                interval: 3000
                repeat: false
                running: false

                onTriggered: {
                    completeTimer.stop();
                    completePopup.close();
                }
            }
        }
    }
}
