import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Controls.Universal 2.15


ApplicationWindow {
    id: remoteWindow
    width:         viewWidth  < 1024 ? 1024 : viewWidth
    height:        viewHeight < 800  ? 800  : viewHeight
    minimumWidth:  viewWidth  < 1024 ? 1024 : viewWidth
    minimumHeight: viewHeight < 800  ? 800  : viewHeight
    visible: true
    title: bDirectory ? qsTr("Select Directory (Remote Server)") : qsTr("Select \"sshd_config\" (Remote Server)")

    property int  viewWidth:     1024
    property int  viewHeight:    800
    property bool bDark:         false
    property int  fontPadding:   0
    property int  fileMode:      0      // 0 : Download sshd_config file.
                                        // 1 : Get path to key file.
    property int  keyType:       0      // 0 : Host Key.
                                        // 1 : Authorized Key.
    property bool bDirectory:    false  // true : Select directory.
    property int  directoryType: 0      // 0 : Directory for PID file.
                                        // 1 : Directory for chroot.

    property var  authView:   null
    property var  selectView: null

    signal setRemoteInfo(string hostName,     string port,           bool bUseSSL,        bool bUseCert,    string certFile,
                         bool bUsePrivateKey, string privateKeyFile, bool bUsePassphrase, string passphrase)
    signal downloadSSHFile(string localFilePath, string remoteFilePath)
    signal getHostKey(string remoteFilePath)
    signal getAuthorizedKey(string remoteFilePath)
    signal getDirectory(int directoryType, string remoteDirPath)

    Component.onCompleted: {
        authView = mainView.push("Auth.qml", {parentName: remoteWindow,
                                              viewWidth: remoteWindow.viewWidth, viewHeight: remoteWindow.viewHeight,
                                              bDark: remoteWindow.bDark, fontPadding: remoteWindow.fontPadding})
    }

    onClosing: {
        if (selectView !== null) {
            selectView.remote.disConnectFromServer()
        }
    }

    signal prevViewChanged()
    onPrevViewChanged: {
        // Pop remote window.
        mainView.pop()

        // Prev auth window.
        mainView.get(1, StackView.ForceLoad)
    }

    signal nextViewChanged()
    onNextViewChanged: {
        if (bDirectory === false) {
            // Save remote server infomation.
            remoteWindow.setRemoteInfo(authView.hostName,       authView.port,           authView.bUseSSL,        authView.bUseCert,  authView.certFile,
                                       authView.bUsePrivateKey, authView.privateKeyFile, authView.bUsePassphrase, authView.passphrase)

            // Next view (Select Window).
            selectView = mainView.push("Select.qml", {parentName: remoteWindow,
                                       // Window settings.
                                       viewWidth: remoteWindow.viewWidth, viewHeight: remoteWindow.viewHeight, bDark: remoteWindow.bDark,
                                       fontPadding: remoteWindow.fontPadding, fileMode: remoteWindow.fileMode, keyType: remoteWindow.keyType,
                                       // Remote settings.
                                       hostName: authView.hostName,             port: authView.port,         bUseSSL: authView.bUseSSL,
                                       bUseCert: authView.bUseCert,             certFile: authView.certFile,
                                       bUsePrivateKey: authView.bUsePrivateKey, privateKeyFile: authView.privateKeyFile,
                                       bUsePassphrase: authView.bUsePassphrase, passphrase: authView.passphrase})
        }
        else {
            // Next view (Select Window).
            selectView = mainView.push("SelectDirectory.qml", {parentName: remoteWindow,
                                       // Window settings.
                                       viewWidth: remoteWindow.viewWidth, viewHeight: remoteWindow.viewHeight, bDark: remoteWindow.bDark,
                                       fontPadding: remoteWindow.fontPadding, directoryType: remoteWindow.directoryType,
                                       // Remote settings.
                                       hostName: authView.hostName,             port: authView.port,         bUseSSL: authView.bUseSSL,
                                       bUseCert: authView.bUseCert,             certFile: authView.certFile,
                                       bUsePrivateKey: authView.bUsePrivateKey, privateKeyFile: authView.privateKeyFile,
                                       bUsePassphrase: authView.bUsePassphrase, passphrase: authView.passphrase})
        }
    }

    StackView {
        id: mainView
        x: 0
        y: 0
        width: parent.width
        height: parent.height

        pushEnter: Transition {
            id: pushEnter

            ParallelAnimation {
                NumberAnimation {
                    property: "x"
                    from: remoteWindow.width / 5
                    to: 0
                    duration: 500
                    easing.type: Easing.OutCubic
                }

                NumberAnimation {
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: 500
                    easing.type: Easing.OutCubic
                }
            }
        }

        pushExit: Transition {
            id: pushExit

            PropertyAction {
                property: "x"
                value: pushExit.ViewTransition.item.pos
            }
        }

        popEnter: Transition {
            id: popEnter

            PropertyAction {
                property: "x"
                value: popEnter.ViewTransition.item.pos
            }
        }
    }
}
