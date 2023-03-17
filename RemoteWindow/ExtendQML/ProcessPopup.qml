import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import Qt.labs.settings 1.0
import QtQuick.Controls.Material 2.15
import QtQuick.Controls.Universal 2.15


Popup {
     id: processPopup
     x:     0
     y:     (viewHeight - processPopup.height) / 2
     width: viewWidth

     modal: true
     focus: true

     property string viewTitle:    ""
     property int    positionY:    0
     property int    viewWidth:    640
     property int    viewHeight:   480
     property bool   bDark:        false
     property int    fontPadding:  0
     property int    timerTime:    500
     property var    parentName:   null
     property var    remoteClient: null
     property int    returnValue:  0
     property string errMsg:       ""

     function fnCloseTimerStart() {
         startTimer.start()
     }

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
         id: processColumn
         x: parent.x
         width: parent.width
         spacing: 20

         Layout.margins: 50

         Label {
             text: processPopup.viewTitle
             font.pointSize: 16 + processPopup.fontPadding
             color: "white"

             verticalAlignment:   Label.AlignVCenter
             Layout.maximumWidth: processPopup.width - 100
             Layout.fillHeight:   true
             Layout.topMargin:    20
             Layout.leftMargin:   (processPopup.width - width) / 2
             Layout.bottomMargin: 20

             wrapMode: Label.WordWrap
         }
     }

     Component.onCompleted: {
         startTimer.start();
     }

     Timer {
         id: startTimer

         interval: processPopup.timerTime
         repeat: false
         running: false

         onTriggered: {
             startTimer.stop();

             // Connect remote server.
             let bConnect = remoteClient.connectToServer(parentName.hostName, parentName.port,           parentName.bUseSSL,        parentName.bUseCert,
                                                         parentName.certFile, parentName.bUsePrivateKey, parentName.privateKeyFile, parentName.bUsePassphrase,
                                                         parentName.passphrase, 0)

             let componentDialog = null
             let errorDialog     = null
             if (bConnect === false) {
                 errMsg      = qsTr("Connection failed.") + "<br>" + remoteClient.getErrorMessage()
                 returnValue = 1

                 processPopup.close()
                 return
             }

             let iRet = 0;
             let command = ""
             if (!parentName.bStatus) {
                 // Start(Restart) or Stop ssh(d) service.
                 let startstop = parentName.bActionFlag ? 6 : 7
                 command       = parentName.bActionFlag ? "sshrestart" : "sshstop"
                 iRet = remoteClient.writeToServer(command, startstop)
                 if (iRet === -1) {
                     errMsg      = qsTr("Failed to send packet.") + "<br>" + remoteClient.getErrorMessage()
                     returnValue = 1

                     processPopup.close()
                     return
                 }
             }
             else {
                 // Get status of ssh(d) service.
                 command = "sshstatus"
                 iRet = remoteClient.writeToServer(command, 8)
                 if (iRet === -1) {
                     errMsg      = qsTr("Failed to send packet.") + "<br>" + remoteClient.getErrorMessage()
                     returnValue = 1

                     processPopup.close()
                     return
                 }
             }

             returnValue = 0
             processPopup.close();
         }
     }
 }
