import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs 1.2
import QtQuick.Controls 2.15
import Qt.labs.settings 1.0
import QtQuick.Controls.Material 2.15
import QtQuick.Controls.Universal 2.15
import "../ExtendQML"
import WindowState 1.0
import SSHService  1.0
import SSHServer   1.0


ApplicationWindow {
    id: mainWindow
    width: 375
    height: 812
    visible: true
    title: qsTr("SSHConfig for PinePhone")

    property int  fontCheck:        1
    property int  fontPadding:      mainWindow.fontCheck === 0 ? -3 : mainWindow.fontCheck === 1 ? 0 : 3
    property bool bDark:            windowState.getColorMode()
    property bool bServerMode:      windowState.getServerMode()

    CWindowState {
        id: windowState;
    }

    CSSHService {
        id: sshService;
    }

    CSSHServer {
        id: sshServerConfig;
    }

    Settings {
        id: settings
        property string style: windowState.getColorMode() ? "Material" : "Universal"
    }

    Shortcut {
        sequences: ["Esc", "Back"]
        //enabled: stackView.depth > 1
        onActivated: navigateBackAction.trigger()
    }

    // Return to Welcome screen.
    Shortcut {
        sequences: ["Shift+Esc", "Home"]
        onActivated: {
            stackLayout.currentIndex = 0
        }
    }

    // Quit software.
    Shortcut {
        sequence: "Ctrl+Q"
        onActivated: {
            mainWindow.close()
        }
    }

    Component.onCompleted: {
        // If forgot to turn off the temporary overwrite flag for a theme, remove the flag.
        windowState.setColorModeOverWrite(false)

        // Load font size settings.
        mainWindow.fontCheck = windowState.getFontSize()

        // Load dark mode setting.
        mainWindow.bDark = windowState.getColorMode()

        // Load the welcome screen.
        stackLayout.currentIndex = 0
    }

    Action {
        id: navigateBackAction
        icon.source: "qrc:/Image/Drawer.png"
        icon.name: "Drawer"
        onTriggered: {
            drawer.open()
        }
    }

    // Open quit dialog.
    onClosing: {
        close.accepted = false

        let component = Qt.createComponent("qrc:/ExtendQML/QuitDialog.qml");
        if (component.status === Component.Ready) {
            let quitDialog = component.createObject(mainWindow, {mainWidth: mainWindow.width, windowState: windowState,
                                                                 bDark: mainWindow.bDark, bPP: true});
            quitDialogConnection.target = quitDialog
            quitDialog.show();
        }
    }

    Connections {
        id: quitDialogConnection
        function onVisibleChanged() {
            if(!target.visible) {
                if (target.returnValue === 0) {
                    // Remove tmp files.
                    windowState.removeTmpFiles()

                    // Save Window State
                    fnSaveApplicationState()

                    // Exit SSHConfig
                    Qt.quit()
                }
            }
        }
    }

    function fnSaveApplicationState() {
        // Save window state
        let bMaximized = false
        if(mainWindow.visibility === Window.Maximized) {
            bMaximized = true;
        }

        windowState.setMainWindowState(x, y, width, height, bMaximized)

        // Save color mode
        if (windowState.getColorMode() === false && windowState.getColorModeOverWrite() === 1) {
            windowState.setColorMode(true)
        }
        else if (windowState.getColorMode() === true && windowState.getColorModeOverWrite() === 1) {
            windowState.setColorMode(false)
        }

        windowState.setColorModeOverWrite(false)
    }

    // Restart or get its status SSH service on the remote server.
    function fnExecSSHServiceRemote(bStart: bool) {
        let iRet = sshService.executeRemoteSSHService(mainWindow.width, mainWindow.height, mainWindow.bDark, mainWindow.fontPadding,
                                                      bStart, false)

        if (iRet === 0) {
        }
        else {
            // Error.
            let errMsg = sshService.getErrorMessage()
            let componentDialog = Qt.createComponent("qrc:///ExtendQML/ErrorDialogPP.qml");
            if (componentDialog.status === Component.Ready) {
                let errorDialog = componentDialog.createObject(mainWindow,
                                                               {mainWidth: mainWindow.width, mainHeight: mainWindow.height,
                                                                bDark: mainWindow.bDark,
                                                                messageTitle: qsTr("Exec Error"),
                                                                messageText: qsTr("Failed to execute the sshd command.") + "<br>" + errMsg});
                errorDialog.show();
            }
        }
    }

    // Get Status for ssh(d).service on remote server.
    Connections {
        target: sshService
        function onResultGetSSHStatusRemoteHost(status) {
            if (status === 0) {
                // ssh(d).service is running.
                labelRemoteRestartSSH.text    = qsTr("Start / Restart") + "<br>" + qsTr("(running)")
                labelRemoteRestartSSH.enabled = true
                labelRemoteRestartSSH.color   = windowState.getColorMode() ? "steelblue" : "blue"

                labelRemoteStopSSH.text    = qsTr("Stop")
                labelRemoteStopSSH.enabled = true
                labelRemoteStopSSH.color   = windowState.getColorMode() ? "crimson" : "#a00000"
            }
            else if (status === 1) {
                // ssh(d).service is stop.
                labelRemoteRestartSSH.text    = qsTr("Start / Restart") + "<br>" + qsTr("(inactive)")
                labelRemoteRestartSSH.enabled = true
                labelRemoteRestartSSH.color   = windowState.getColorMode() ? "white" : "black"

                labelRemoteStopSSH.text    = qsTr("Stop")
                labelRemoteStopSSH.enabled = false
                labelRemoteStopSSH.color   = "grey"
            }
            else {
                // Error.
                labelRemoteRestartSSH.text    = qsTr("Start / Restart") + "<br>" + qsTr("(Unknown Status)")
                labelRemoteRestartSSH.enabled = false
                labelRemoteRestartSSH.color   = "grey"

                labelRemoteStopSSH.text    = qsTr("Stop") + "<br>" + qsTr("(Unknown Status)")
                labelRemoteStopSSH.enabled = false
                labelRemoteStopSSH.color   = "grey"

                let errMsg = sshService.getErrorMessage()
                let componentDialog = Qt.createComponent("qrc:/ExtendQML/ErrorDialogPP.qml");
                if (componentDialog.status === Component.Ready) {
                    let errorDialog = componentDialog.createObject(mainWindow,
                                                                   {mainWidth: mainWindow.width, mainHeight: mainWindow.height,
                                                                    bDark: mainWindow.bDark,
                                                                    messageTitle: qsTr("Exec Error"),
                                                                    messageText: qsTr("Failed to get ssh(d).service status.") + "<br>"});
                    errorDialog.show();
                }
            }
        }
    }

    header: Rectangle {
        id: headerColumn
        width: parent.width
        height: titleLabel.height + 10
        color: windowState.getColorMode() ? "#303030" : "#ffffff"

        Label {
            id: titleLabel
            width: parent.width

            text: stackLayout.currentIndex === 0 ? qsTr("SSHConfig for PinePhone") :
                  stackLayout.currentIndex === 1 ? qsTr("SSH Server") :
                  stackLayout.currentIndex === 2 ? qsTr("SSH Test") :
                  stackLayout.currentIndex === 3 ? qsTr("Mode") :
                  stackLayout.currentIndex === 4 ? qsTr("About Qt") : ""
            font.pointSize: 14
            elide: Label.ElideRight
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
        }

        ToolBar {
            width: height
            height: parent.height

            anchors.top: parent.top
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter

            background: Rectangle {
                color: windowState.getColorMode() ? "#303030" : "#ffffff"
            }

            ToolButton {
                action: navigateBackAction
            }
        }
    }

    Drawer {
        id: drawer
        width: (Math.max(mainWindow.width, mainWindow.height) / 3 * 1) > 300 ?
                Math.max(mainWindow.width, mainWindow.height) / 3 * 1 : 300
        height: mainWindow.height

//        ListView {
//            id: listView
//            width: parent.width
//            height: parent.height

//            focus: true
//            currentIndex: -1
//            anchors.fill: parent

//            delegate: ItemDelegate {
//                width: listView.width
//                text: model.title
//                font.pointSize: 14 + mainWindow.fontPadding
//                highlighted: ListView.isCurrentItem
//                onClicked: {
//                    if (index === 5) {
//                        mainWindow.close()
//                    }
//                    else {
//                        listView.currentIndex    = index
//                        stackLayout.currentIndex = listView.currentIndex
//                        drawer.close()
//                    }
//                }
//            }

//            model: ListModel {
//                ListElement { title: qsTr("Home")}
//                ListElement { title: qsTr("SSH Server")}
//                ListElement { title: qsTr("SSH Test")}
//                ListElement { title: qsTr("Mode")}
//                ListElement { title: qsTr("About Qt")}
//                ListElement { title: qsTr("Quit")}
//            }

//            ScrollIndicator.vertical: ScrollIndicator { }
//        }

        ScrollView {
            width: parent.width
            height : parent.height
            contentWidth: columnSSHServiceMenu.width    // The important part
            contentHeight: columnSSHServiceMenu.height  // Same
            clip: true                                  // Do not show areas beyond Drawer borders.

            anchors.fill: parent

            ColumnLayout {
                id: columnSSHServiceMenu
                x: parent.x
                width: parent.width
                spacing: 10

                Layout.alignment: Qt.AlignTop

                property bool bSSHService: false

                Label {
                    id: labelHome
                    text: qsTr("Home")
                    width: parent.availableWidth
                    font.pointSize: 14 + mainWindow.fontPadding

                    wrapMode: Label.WordWrap

                    horizontalAlignment: Label.AlignLeft
                    verticalAlignment: Label.AlignVCenter
                    Layout.fillWidth:  true
                    Layout.topMargin:  20
                    Layout.leftMargin: 20

                    Rectangle {
                        id: rectHome
                        width:   parent.width
                        height:  parent.height
                        color:   "transparent"
                        opacity: 0.0
                    }

                    MouseArea {
                        id: mouseAreaHome
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                        }

                        onPressed: {
                            parent.color     = Material.color(Material.LightBlue, Material.Shade200)
                            parent.font.bold = true
                            rectHome.color   = bDark ? "white" : "black"
                            rectHome.opacity = 0.1
                        }

                        onReleased: {
                            parent.color= bDark ? "white" : "black"
                            parent.font.bold = false
                            rectHome.color   = "transparent"
                            rectHome.opacity = 0.0

                            stackLayout.currentIndex = 0
                            drawer.close()
                        }
                    }
                }

                Label {
                    id: labelSSHServer
                    text: qsTr("SSH Server")
                    width: parent.availableWidth
                    font.pointSize: 14 + mainWindow.fontPadding

                    wrapMode: Label.WordWrap

                    horizontalAlignment: Label.AlignLeft
                    verticalAlignment: Label.AlignVCenter
                    Layout.fillWidth:  true
                    Layout.topMargin:  20
                    Layout.leftMargin: 20

                    Rectangle {
                        id: rectSSHServer
                        width:   parent.width
                        height:  parent.height
                        color:   "transparent"
                        opacity: 0.0
                    }

                    MouseArea {
                        id: mouseAreaSSHServer
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                        }

                        onPressed: {
                            parent.color     = Material.color(Material.LightBlue, Material.Shade200)
                            parent.font.bold = true
                            rectSSHServer.color   = bDark ? "white" : "black"
                            rectSSHServer.opacity = 0.1
                        }

                        onReleased: {
                            parent.color= bDark ? "white" : "black"
                            parent.font.bold = false
                            rectSSHServer.color   = "transparent"
                            rectSSHServer.opacity = 0.0

                            stackLayout.currentIndex = 1
                            drawer.close()
                        }
                    }
                }

                Label {
                    id: labelSSHTest
                    text: qsTr("SSH Test")
                    width: parent.availableWidth
                    font.pointSize: 14 + mainWindow.fontPadding

                    wrapMode: Label.WordWrap

                    horizontalAlignment: Label.AlignLeft
                    verticalAlignment: Label.AlignVCenter
                    Layout.fillWidth:  true
                    Layout.topMargin:  20
                    Layout.leftMargin: 20

                    Rectangle {
                        id: rectSSHTest
                        width:   parent.width
                        height:  parent.height
                        color:   "transparent"
                        opacity: 0.0
                    }

                    MouseArea {
                        id: mouseAreaSSHTest
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                        }

                        onPressed: {
                            parent.color     = Material.color(Material.LightBlue, Material.Shade200)
                            parent.font.bold = true
                            rectSSHTest.color   = bDark ? "white" : "black"
                            rectSSHTest.opacity = 0.1
                        }

                        onReleased: {
                            parent.color= bDark ? "white" : "black"
                            parent.font.bold = false
                            rectSSHTest.color   = "transparent"
                            rectSSHTest.opacity = 0.0

                            stackLayout.currentIndex = 2
                            drawer.close()
                        }
                    }
                }

                Label {
                    id: labelMode
                    text: qsTr("Mode")
                    width: parent.availableWidth
                    font.pointSize: 14 + mainWindow.fontPadding

                    wrapMode: Label.WordWrap

                    horizontalAlignment: Label.AlignLeft
                    verticalAlignment: Label.AlignVCenter
                    Layout.fillWidth:  true
                    Layout.topMargin:  20
                    Layout.leftMargin: 20

                    Rectangle {
                        id: rectMode
                        width:   parent.width
                        height:  parent.height
                        color:   "transparent"
                        opacity: 0.0
                    }

                    MouseArea {
                        id: mouseAreaMode
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                        }

                        onPressed: {
                            parent.color     = Material.color(Material.LightBlue, Material.Shade200)
                            parent.font.bold = true
                            rectMode.color   = bDark ? "white" : "black"
                            rectMode.opacity = 0.1
                        }

                        onReleased: {
                            parent.color= bDark ? "white" : "black"
                            parent.font.bold = false
                            rectMode.color   = "transparent"
                            rectMode.opacity = 0.0

                            stackLayout.currentIndex = 3
                            drawer.close()
                        }
                    }
                }

                Label {
                    id: labelAboutQt
                    text: qsTr("About Qt")
                    width: parent.availableWidth
                    font.pointSize: 14 + mainWindow.fontPadding

                    wrapMode: Label.WordWrap

                    horizontalAlignment: Label.AlignLeft
                    verticalAlignment: Label.AlignVCenter
                    Layout.fillWidth:  true
                    Layout.topMargin:  20
                    Layout.leftMargin: 20

                    Rectangle {
                        id: rectAboutQt
                        width:   parent.width
                        height:  parent.height
                        color:   "transparent"
                        opacity: 0.0
                    }

                    MouseArea {
                        id: mouseAreaAboutQt
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                        }

                        onPressed: {
                            parent.color     = Material.color(Material.LightBlue, Material.Shade200)
                            parent.font.bold = true
                            rectAboutQt.color   = bDark ? "white" : "black"
                            rectAboutQt.opacity = 0.1
                        }

                        onReleased: {
                            parent.color= bDark ? "white" : "black"
                            parent.font.bold = false
                            rectAboutQt.color   = "transparent"
                            rectAboutQt.opacity = 0.0

                            stackLayout.currentIndex = 4
                            drawer.close()
                        }
                    }
                }

                Label {
                    id: labelQuit
                    text: qsTr("Quit")
                    width: parent.availableWidth
                    font.pointSize: 14 + mainWindow.fontPadding

                    wrapMode: Label.WordWrap

                    horizontalAlignment: Label.AlignLeft
                    verticalAlignment: Label.AlignVCenter
                    Layout.fillWidth:  true
                    Layout.topMargin:  20
                    Layout.leftMargin: 20

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            mainWindow.close()
                        }
                    }
                }

                Label {
                    id: labelSSHService
                    text: {
                        if (mainWindow.bServerMode) {
                            qsTr("SSH Service :") + "<br>" + "<span style=\"color: #10980a;\"><b>" + qsTr("(this computer)") + "</b></span>"
                        }
                        else {
                            qsTr("SSH Service :") + "<br>" + "<span style=\"color: #10980a;\"><b>" + qsTr("(Remote server)") + "</b></span>"
                        }
                    }

                    font.pointSize: 12 + mainWindow.fontPadding

                    textFormat: Label.RichText
                    wrapMode: Label.WordWrap

                    horizontalAlignment: Label.AlignHCenter
                    verticalAlignment: Label.AlignVCenter
                    Layout.preferredWidth: drawer.width
                    Layout.topMargin: 20
                }

                Label {
                    id: labelStartSSH
                    text: qsTr("Start / Restart")
                    visible: mainWindow.bServerMode ? true : false

                    font.pointSize: 12 + mainWindow.fontPadding
                    color: windowState.getColorMode() ? columnSSHServiceMenu.bSSHService === false ? "white" : "steelblue" : columnSSHServiceMenu.bSSHService === false ? "black" : "blue"

                    textFormat: Label.RichText
                    wrapMode: Label.WordWrap

                    horizontalAlignment: Label.AlignHCenter
                    verticalAlignment: Label.AlignVCenter
                    Layout.preferredWidth: drawer.width
                    Layout.topMargin: 20

                    Rectangle {
                        y: parent.height
                        width: drawer.width
                        height: 3

                        color: windowState.getColorMode() ? "steelblue" : "blue"

                        radius: 10
                        opacity: 0.8
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            let ret = sshService.setSSHService("StartUnit")
                            if (ret === 0) {
                                labelStartSSH.text = qsTr("Start / Restart") + "<br>" + qsTr("(running)")
                                columnSSHServiceMenu.bSSHService = true
                            }
                        }
                    }

                    Component.onCompleted: {
                        let ret = sshService.getStateSSHService()
                        if (ret !== 0) {
                            text = qsTr("Start / Restart") + "<br>" + qsTr("(inactive)")
                        }
                        else {
                            columnSSHServiceMenu.bSSHService = true
                            text = qsTr("Start / Restart") + "<br>" + qsTr("(running)")
                        }
                    }
                }

                Label {
                    id: labelStopSSH
                    text: qsTr("Stop")
                    visible: mainWindow.bServerMode ? true : false

                    font.pointSize: 12 + mainWindow.fontPadding
                    color: columnSSHServiceMenu.bSSHService === false ? "grey" : windowState.getColorMode() ? "crimson" : "#a00000"

                    wrapMode: Label.WordWrap

                    horizontalAlignment: Label.AlignHCenter
                    verticalAlignment: Label.AlignVCenter
                    Layout.preferredWidth: drawer.width
                    Layout.topMargin: 20
                    Layout.bottomMargin: 30

                    Rectangle {
                        y: parent.height
                        width: drawer.width
                        height: 3

                        color: columnSSHServiceMenu.bSSHService === false ? "grey" : windowState.getColorMode() ? "crimson" : "#a00000"

                        radius: 10
                        opacity: 0.8
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: columnSSHServiceMenu.bSSHService ? Qt.PointingHandCursor : Qt.ArrowCursor
                        enabled: columnSSHServiceMenu.bSSHService ? true : false

                        onClicked: {
                            let ret = sshService.setSSHService("StopUnit")
                            if (ret === 0) {
                                labelStartSSH.text = qsTr("Start / Restart") + "<br>" + qsTr("(inactive)")
                                labelStartSSH.update()
                                columnSSHServiceMenu.bSSHService = false
                            }
                        }
                    }
                }

                Label {
                    id: labelRemoteRestartSSH
                    text: qsTr("Start / Restart") + "<br>" + qsTr("(Unknown Status)")
                    visible: mainWindow.bServerMode ? false : true
                    enabled: false

                    font.pointSize: 12 + mainWindow.fontPadding

                    wrapMode: Label.WordWrap

                    horizontalAlignment: Label.AlignHCenter
                    verticalAlignment: Label.AlignVCenter
                    Layout.preferredWidth: drawer.width
                    Layout.topMargin: 20

                    Rectangle {
                        y: parent.height
                        width: drawer.width
                        height: 3

                        color: parent.enabled ? windowState.getColorMode() ? "steelblue" : "blue" : parent.color

                        radius: 10
                        opacity: 0.8
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: parent.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                        enabled: parent.enabled ? true : false

                        onClicked: {
                            // Client Mode.
                            mainWindow.fnExecSSHServiceRemote(true)
                        }
                    }
                }

                Label {
                    id: labelRemoteStopSSH
                    text: qsTr("Stop") + "<br>" + qsTr("(Unknown Status)")
                    visible: mainWindow.bServerMode ? false : true
                    enabled: false

                    font.pointSize: 12 + mainWindow.fontPadding

                    wrapMode: Label.WordWrap

                    horizontalAlignment: Label.AlignHCenter
                    verticalAlignment: Label.AlignVCenter
                    Layout.preferredWidth: drawer.width
                    Layout.topMargin: 20

                    Rectangle {
                        y: parent.height
                        width: drawer.width
                        height: 3

                        color: parent.color

                        radius: 10
                        opacity: 0.8
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: parent.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                        enabled: parent.enabled ? true : false

                        onClicked: {
                            // Client Mode.
                            mainWindow.fnExecSSHServiceRemote(false)
                        }
                    }
                }

                Label {
                    id: labelRemoteStatusSSH
                    text: qsTr("Get Status")
                    visible: mainWindow.bServerMode ? false : true

                    font.pointSize: 12 + mainWindow.fontPadding

                    wrapMode: Label.WordWrap

                    horizontalAlignment: Label.AlignHCenter
                    verticalAlignment: Label.AlignVCenter
                    Layout.preferredWidth: drawer.width
                    Layout.topMargin: 20
                    Layout.bottomMargin: 30

                    Rectangle {
                        y: parent.height
                        width: drawer.width
                        height: 3

                        color: windowState.getColorMode() ? "steelblue" : "blue"

                        radius: 10
                        opacity: 0.8
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            // Client Mode.
                            let iRet = sshService.executeRemoteSSHService(mainWindow.width, mainWindow.height, mainWindow.bDark, mainWindow.fontPadding,
                                                                          false, true)

                            if (iRet === 0) {
                            }
                            else {
                                // Error.
                                let errMsg = sshService.getErrorMessage()
                                let componentDialog = Qt.createComponent("qrc:/ExtendQML/ErrorDialogPP.qml");
                                if (componentDialog.status === Component.Ready) {
                                    let errorDialog = componentDialog.createObject(mainWindow,
                                                                                   {mainWidth: mainWindow.width, mainHeight: mainWindow.height,
                                                                                       bDark: mainWindow.bDark,
                                                                                       messageTitle: qsTr("Exec Error"),
                                                                                       messageText: qsTr("Failed to get status for ssh(d).service.") + "<br>" + errMsg});
                                    errorDialog.show();
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    StackLayout {
        id: stackLayout
        y: headerColumn.y + headerColumn.height
        width: parent.width
        height: parent.height - y

        currentIndex: 0

        onCurrentIndexChanged: {
            animationLayout.start()
        }

        ParallelAnimation {
            id: animationLayout

            NumberAnimation {
                target: stackLayout
                properties: "x"
                from: stackLayout.width
                to: stackLayout.x
                duration: 150
                easing.type: Easing.OutQuad
            }
            NumberAnimation {
                target: stackLayout
                properties: "opacity"
                from: 0.0
                to: 1.0
                duration: 150
                easing.type: Easing.InOutQuad
            }
        }

        WelcomeSSHConfigPP {
            id: welcomeView
            parentName:  mainWindow
            windowState: windowState
            fontPadding: mainWindow.fontPadding
        }

        SSHServerPP {
            parentName:      mainWindow
            windowState:     windowState
            sshServerConfig: sshServerConfig
            fontPadding:     mainWindow.fontPadding
            bDark:           mainWindow.bDark
            bServerMode:     mainWindow.bServerMode
        }

        SSHTestPP {
            parentName:      mainWindow
            windowState:     windowState
            sshServerConfig: sshServerConfig
            fontPadding:     mainWindow.fontPadding
            bDark:           mainWindow.bDark
            bServerMode:     mainWindow.bServerMode
        }

        ModeSettingsPP {
            id: modeSettings
            parentName:   mainWindow
            windowState:  windowState
            sshService:   sshService
            oldFontCheck: mainWindow.fontCheck
        }

        AboutQtPP {
            parentName:  mainWindow
            windowState: windowState
            fontPadding: mainWindow.fontPadding
        }
    }
}
