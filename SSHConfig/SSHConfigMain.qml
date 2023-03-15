import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs 1.2
import QtQuick.Controls 2.15
import Qt.labs.settings 1.0
import QtQuick.Controls.Material 2.15
import QtQuick.Controls.Universal 2.15
import "ExtendQML"
import WindowState 1.0
import SSHService  1.0
import SSHServer   1.0


ApplicationWindow {
    id: mainWindow
    objectName: "MainWindow"

    x: windowState.getMainWindowX()
    y: windowState.getMainWindowY()
    width: windowState.getMainWindowWidth()
    minimumWidth: 1280
    height: windowState.getMainWindowHeight()
    minimumHeight: 800

    visible: true
    visibility: windowState.getMainWindowMaximized() ?  Window.Maximized : Window.Windowed
    title: qsTr("SSHConfig for PC")

    CWindowState {
        id: windowState;
    }

    CSSHService {
        id: sshService;
    }

    Settings {
        id: settings
        property string style: windowState.getColorMode() ? "Material" : "Universal"
    }

    CSSHServer {
        id: sshServerConfig;
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

    // Open quit dialog.
    onClosing: {
        close.accepted = false

        var component = Qt.createComponent("qrc:/ExtendQML/QuitDialog.qml");
        if (component.status === Component.Ready) {
            var quitDialog = component.createObject(mainWindow, {mainWidth: Math.round(Math.min(mainWindow.width, mainWindow.height) / 10 * 9),
                                                                 bDark: mainWindow.bDark, windowState: windowState});
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
                    saveApplicationState()

                    // Exit SSHConfig
                    Qt.quit()
                }
            }
        }
    }

    function saveApplicationState() {
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

    // Return to Welcome screen.
    Shortcut {
        sequences: ["Shift+Esc", "Home"]
        onActivated: {
            if (stackLayout.currentIndex !== 0) {
                if (stackLayout.currentIndex === 3) {
                    mainWindow.fnSaveModeSettings("", 2)
                }
                else {
                    aryFowardIndexes = []
                    aryPrevIndexes   = []
                    stackLayout.currentIndex = 0
                }
            }
        }
    }

    // Quit software.
    Shortcut {
        sequence: "Ctrl+Q"
        onActivated: {
            //saveApplicationState()
            mainWindow.close()
        }
    }

    property int  fontCheck:        1
    property int  fontPadding:      mainWindow.fontCheck === 0 ? -3 : mainWindow.fontCheck === 1 ? 0 : 3
    property bool bDark:            false
    property bool bServerMode:      windowState.getServerMode()
    property var  aryPrevIndexes:   []
    property var  aryFowardIndexes: []
    property int  nextIndex:        0

    // Press the [Back] or [Foward] button on the mouse to move to other screen from other screens.
    signal screenMoved(string _viewName, int move)
    onScreenMoved: {
        fnScreenMove(_viewName, move)
    }

    function fnScreenMove(_viewName, move) {
        // If changing settings on [Mode] screen.
        if (stackLayout.currentIndex === 3) {
            fontCheck   = windowState.getFontSize()
        }

        // Move screen.
        if (move === 0) {
            // Next screen.
            fnPrevIndex(stackLayout.currentIndex)
        }
        else if (move === 1) {
            // Previous screen.
            fnFowardIndex(stackLayout.currentIndex)
        }
        else if (move === 2) {
            // Back to [Welcome] screen.
            aryFowardIndexes = []
            aryPrevIndexes   = []
            stackLayout.currentIndex = 0
        }
        else if (move === 3) {
            // Move to specify screen using side button.
            stackLayout.currentIndex = mainWindow.nextIndex
        }
    }

    function fnSaveModeSettings(_viewName, move) {
        fontCheck = windowState.getFontSize()
        if (stackLayout.currentIndex === 3) {
            modeSettings.fnSaveModeSettings(_viewName, move)
        }
    }

    // When mouse back button is pressed, return to previous view.
    function fnPrevIndex(index) {
        if (aryPrevIndexes.length > 0) {
            let tmparyFowardIndexes = []
            tmparyFowardIndexes.push(index)

            if (aryFowardIndexes.length > 0) {
                for (let i = 0; i < aryFowardIndexes.length; i++) {
                    tmparyFowardIndexes.push(aryFowardIndexes[i])
                }
            }

            aryFowardIndexes = tmparyFowardIndexes

            stackLayout.currentIndex = aryPrevIndexes.pop()
        }
    }

    // When mouse foward button is pressed, advance to next view.
    function fnFowardIndex(index) {
        if (aryFowardIndexes.length > 0) {
            aryPrevIndexes.push(index)

            stackLayout.currentIndex = aryFowardIndexes.shift()
        }
    }

    // Index change using side button.
    function fnIndexChange(index: int) {
        aryFowardIndexes = []
        aryPrevIndexes.push(stackLayout.currentIndex)

        if (aryPrevIndexes[aryPrevIndexes.length - 1] === 3) {
            mainWindow.nextIndex = index
            modeSettings.fnSaveModeSettings("", 3)
        }
        else {
            stackLayout.currentIndex = index
        }
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
            let componentDialog = Qt.createComponent("qrc:///ExtendQML/ErrorDialog.qml");
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
                let componentDialog = Qt.createComponent("qrc:///ExtendQML/ErrorDialog.qml");
                if (componentDialog.status === Component.Ready) {
                    let errorDialog = componentDialog.createObject(mainWindow,
                                                                   {mainWidth: mainWindow.width, mainHeight: mainWindow.height,
                                                                    bDark: mainWindow.bDark,
                                                                    messageTitle: qsTr("Exec Error"),
                                                                    messageText: qsTr("Failed to get ssh(d).service status.") + "<br>" + errMsg});
                    errorDialog.show();
                }
            }
        }
    }

    Row {
        //x: 10
        //y: 0
        //width: mainWindow.width - 10
        //height: mainWindow.height
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10

        spacing: 0

        ColumnLayout {
            id: columnMenu
            width: Math.round(mainWindow.width / 7) < 250 ? 250 : Math.round(mainWindow.width / 7) < 300 ? Math.round(mainWindow.width / 7) : 300

            Layout.maximumWidth: 300
            //Layout.fillWidth: true
            //Layout.fillHeight: true
            Layout.alignment: Qt.AlignTop | Qt.AlignHCenter

            spacing: 30

            RoundButton {
                id: btnSSHServer
                text: qsTr("SSH Server")
                implicitWidth: parent.width

                font.pointSize: 15 + mainWindow.fontPadding
                flat: false

                Layout.fillWidth: true
                Layout.topMargin: 60

                contentItem: Label {
                    text: btnSSHServer.text
                    font: btnSSHServer.font
                    opacity: enabled ? 1.0 : 0.3
                    color: btnSSHServer.pressed ? "#6060ff" : windowState.getColorMode() ? "#ffffff" : "#000000"

                    horizontalAlignment: Label.AlignHCenter
                    verticalAlignment: Label.AlignVCenter
                    elide: Label.ElideRight
                }

                background: Rectangle {
                    opacity: enabled ? 1 : 0.3
                    color: "transparent"
                    border.color: btnSSHServer.pressed ? "#6060ff" : windowState.getColorMode() ? "#ffffff" : "#000000"
                    border.width: btnSSHServer.pressed ? 5 : 4
                    radius: 50
                }

                Connections {
                    target: btnSSHServer
                    function onClicked() {
                        if (stackLayout.currentIndex !== 1) {
                            mainWindow.fnIndexChange(1)
                        }
                    }
                }
            }

            RoundButton {
                id: btnSSHTest
                text: qsTr("SSH Test")
                width: parent.width

                font.pointSize: 15 + mainWindow.fontPadding
                flat: false

                Layout.fillWidth: true

                contentItem: Label {
                    text: btnSSHTest.text
                    font: btnSSHTest.font
                    opacity: enabled ? 1.0 : 0.3
                    color: btnSSHTest.pressed ? "#6060ff" : windowState.getColorMode() ? "#ffffff" : "#000000"

                    horizontalAlignment: Label.AlignHCenter
                    verticalAlignment: Label.AlignVCenter
                    elide: Label.ElideRight
                }

                background: Rectangle {
                    opacity: enabled ? 1 : 0.3
                    color: "transparent"
                    border.color: btnSSHTest.pressed ? "#6060ff" : windowState.getColorMode() ? "#ffffff" : "#000000"
                    border.width: btnSSHTest.pressed ? 5 : 4
                    radius: 50
                }

                Connections {
                    target: btnSSHTest
                    function onClicked() {
                        if (stackLayout.currentIndex !== 2) {
                            mainWindow.fnIndexChange(2)
                        }
                    }
                }
            }

            RoundButton {
                id: btnSettings
                text: qsTr("Mode")
                width: parent.availableWidth

                font.pointSize: 15 + mainWindow.fontPadding
                flat: false

                Layout.fillWidth: true

                contentItem: Label {
                    text: btnSettings.text
                    font: btnSettings.font
                    opacity: enabled ? 1.0 : 0.3
                    color: btnSettings.pressed ? "#6060ff" : windowState.getColorMode() ? "#ffffff" : "#000000"

                    horizontalAlignment: Label.AlignHCenter
                    verticalAlignment: Label.AlignVCenter
                    elide: Label.ElideRight
                }

                background: Rectangle {
                    opacity: enabled ? 1 : 0.3
                    color: "transparent"
                    border.color: btnSettings.pressed ? "#6060ff" : windowState.getColorMode() ? "#ffffff" : "#000000"
                    border.width: btnSettings.pressed ? 5 : 4
                    radius: 50
                }

                Connections {
                    target: btnSettings
                    function onClicked() {
                        if (stackLayout.currentIndex !== 3) {
                            mainWindow.fnIndexChange(3)
                        }
                    }
                }
            }

            RoundButton {
                id: btnAboutQt
                text: qsTr("About Qt")
                width: parent.width

                font.pointSize: 15 + mainWindow.fontPadding
                flat: false

                Layout.fillWidth: true

                contentItem: Label {
                    text: btnAboutQt.text
                    font: btnAboutQt.font
                    opacity: enabled ? 1.0 : 0.3
                    color: btnAboutQt.pressed ? "#6060ff" : windowState.getColorMode() ? "#ffffff" : "#000000"

                    horizontalAlignment: Label.AlignHCenter
                    verticalAlignment: Label.AlignVCenter
                    elide: Label.ElideRight
                }

                background: Rectangle {
                    opacity: enabled ? 1 : 0.3
                    color: "transparent"
                    border.color: btnAboutQt.pressed ? "#6060ff" : windowState.getColorMode() ? "#ffffff" : "#000000"
                    border.width: btnAboutQt.pressed ? 5 : 4
                    radius: 50
                }

                Connections {
                    target: btnAboutQt
                    function onClicked() {
                        if (stackLayout.currentIndex !== 4) {
                            mainWindow.fnIndexChange(4)
                        }
                    }
                }
            }

            RoundButton {
                id: btnQuit
                text: qsTr("Quit")
                width: parent.width

                font.pointSize: 15 + mainWindow.fontPadding
                flat: false

                Layout.fillWidth: true

                contentItem: Label {
                    text: btnQuit.text
                    font: btnQuit.font
                    opacity: enabled ? 1.0 : 0.3
                    color: btnQuit.pressed ? "#6060ff" : windowState.getColorMode() ? "#ffffff" : "#000000"

                    horizontalAlignment: Label.AlignHCenter
                    verticalAlignment: Label.AlignVCenter
                    elide: Label.ElideRight
                }

                background: Rectangle {
                    opacity: enabled ? 1 : 0.3
                    color: "transparent"
                    border.color: btnQuit.pressed ? "#6060ff" : windowState.getColorMode() ? "#ffffff" : "#000000"
                    border.width: btnQuit.pressed ? 5 : 4
                    radius: 50
                }

                Connections {
                    target: btnQuit
                    function onClicked() {
                        mainWindow.close()
                    }
                }
            }

            ColumnLayout {
                id: columnSSHServiceMenu
                width: parent.width

                Layout.alignment: Qt.AlignBottom | Qt.AlignHCenter
                Layout.topMargin: 50

                spacing: 20

                property bool bSSHService: false

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
                    width: parent.availableWidth
                    font.pointSize: 12 + mainWindow.fontPadding

                    textFormat: Label.RichText
                    wrapMode: Label.WordWrap

                    horizontalAlignment: Label.AlignHCenter
                    verticalAlignment: Label.AlignVCenter
                    Layout.fillWidth: true
                }

                Label {
                    id: labelStartSSH
                    text: qsTr("Start / Restart")
                    width: parent.availableWidth
                    visible: mainWindow.bServerMode ? true : false

                    font.pointSize: 12 + mainWindow.fontPadding
                    color: windowState.getColorMode() ? columnSSHServiceMenu.bSSHService === false ? "white" : "steelblue" : columnSSHServiceMenu.bSSHService === false ? "black" : "blue"

                    textFormat: Label.RichText
                    wrapMode: Label.WordWrap

                    horizontalAlignment: Label.AlignHCenter
                    verticalAlignment: Label.AlignVCenter
                    Layout.fillWidth: true

                    Rectangle {
                        y: parent.height
                        width: columnMenu.width
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
                    width: parent.availableWidth
                    visible: mainWindow.bServerMode ? true : false

                    font.pointSize: 12 + mainWindow.fontPadding
                    color: columnSSHServiceMenu.bSSHService === false ? "grey" : windowState.getColorMode() ? "crimson" : "#a00000"

                    wrapMode: Label.WordWrap

                    horizontalAlignment: Label.AlignHCenter
                    verticalAlignment: Label.AlignVCenter
                    Layout.fillWidth: true

                    Rectangle {
                        y: parent.height
                        width: columnMenu.width
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
                    width: parent.availableWidth
                    visible: mainWindow.bServerMode ? false : true
                    enabled: false

                    font.pointSize: 12 + mainWindow.fontPadding

                    wrapMode: Label.WordWrap

                    horizontalAlignment: Label.AlignHCenter
                    verticalAlignment: Label.AlignVCenter
                    Layout.fillWidth: true

                    Rectangle {
                        y: parent.height
                        width: columnMenu.width
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
                    width: parent.availableWidth
                    visible: mainWindow.bServerMode ? false : true
                    enabled: false

                    font.pointSize: 12 + mainWindow.fontPadding

                    wrapMode: Label.WordWrap

                    horizontalAlignment: Label.AlignHCenter
                    verticalAlignment: Label.AlignVCenter
                    Layout.fillWidth: true

                    Rectangle {
                        y: parent.height
                        width: columnMenu.width
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
                    width: parent.availableWidth
                    visible: mainWindow.bServerMode ? false : true

                    font.pointSize: 12 + mainWindow.fontPadding

                    wrapMode: Label.WordWrap

                    horizontalAlignment: Label.AlignHCenter
                    verticalAlignment: Label.AlignVCenter
                    Layout.fillWidth: true

                    Rectangle {
                        y: parent.height
                        width: columnMenu.width
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
                                let componentDialog = Qt.createComponent("qrc:///ExtendQML/ErrorDialog.qml");
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

            RoundButton {
                id: btnHome
                text: ""
                width: 80
                height: 80

                icon.source: pressed ? "Image/HomeButtonPressed.png" : "Image/HomeButton.png"
                icon.width: width
                icon.height: height
                icon.color: "transparent"

                padding: 0
                Layout.topMargin: Math.max(0, mainWindow.height - columnSSHServiceMenu.y - columnSSHServiceMenu.height -
                                               btnHome.height - columnMenu.spacing - 30)
                Layout.alignment: Qt.AlignHCenter

                background: Rectangle {
                    color: "transparent"
                }

                onClicked: {
                    aryFowardIndexes = []
                    aryPrevIndexes   = []

                    stackLayout.currentIndex = 0
                }
            }
        }

        StackLayout {
            id: stackLayout
            width: parent.width - columnMenu.width
            height: parent.height

            currentIndex: 0

            onCurrentIndexChanged: {
                animationLayout.start()
            }

            ParallelAnimation {
                id: animationLayout

                NumberAnimation {
                    target: stackLayout
                    properties: "x"
                    from: stackLayout.x + 500//(stackLayout.width) / 5
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

            WelcomeSSHConfig {
                id: welcomeView
                parentName:  mainWindow
                windowState: windowState
                fontPadding: mainWindow.fontPadding
            }

            SSHServer {
                parentName:      mainWindow
                windowState:     windowState
                sshServerConfig: sshServerConfig
                fontPadding:     mainWindow.fontPadding
                bDark:           mainWindow.bDark
                bServerMode:     mainWindow.bServerMode
            }

            SSHTest {
                parentName:      mainWindow
                windowState:     windowState
                sshServerConfig: sshServerConfig
                fontPadding:     mainWindow.fontPadding
                bDark:           mainWindow.bDark
                bServerMode:     mainWindow.bServerMode
            }

            ModeSettings {
                id: modeSettings
                parentName:   mainWindow
                windowState:  windowState
                sshService:   sshService
                oldFontCheck: mainWindow.fontCheck
            }

            AboutQt {
                parentName:  mainWindow
                windowState: windowState
                fontPadding: mainWindow.fontPadding
            }
        }
    }
}
