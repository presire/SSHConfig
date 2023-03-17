import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import Qt.labs.settings 1.0
import QtQuick.Controls.Material 2.15
import QtQuick.Controls.Universal 2.15


Popup {
     id: completePopup
     x: Math.round(viewWidth / 10) / 2
     y: positionY
     width: Math.round(viewWidth / 10 * 9)

     modal: true
     focus: true
     closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside | Popup.CloseOnPressOutsideParent

     property var    parentName:  null
     property int    positionX:   0
     property int    positionY:   0
     property int    viewWidth:   0
     property string viewTitle:   ""
     property int    fontPadding: 0
     property int    timerTime:   3000
     property bool   bAutoClose:   false

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
             text: completePopup.viewTitle
             font.pointSize: 16 + completePopup.fontPadding
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

     onClosed: {
         if (bAutoClose) {
             parentName.close()
         }
     }

     Timer {
         id: completeTimer

         interval: completePopup.timerTime
         repeat: false
         running: false

         onTriggered: {
             completeTimer.stop();
             completePopup.close();
         }
     }
 }
