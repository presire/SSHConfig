import QtQuick 2.15
import QtQuick.Window 2.15
import Qt.labs.platform 1.1
import QtQuick.Dialogs 1.3
import QtQuick.Controls 2.15
import QtQml.Models 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Controls.Universal 2.15


Item {
    id: root

    property int mainWidth:  1024
    property int mainHeight: 800
    property string filters: ""
    property string strFilePath: ""

    signal open()
    signal selectedFile(string strFilePath)

    onOpen: {
        fileSelectDialog.open()
    }

    FileDialog {
        id: fileSelectDialog
        title: qsTr("Please select a File")

        visible: false
        folder: StandardPaths.standardLocations(StandardPaths.HomeLocation)[0]
        modality: Qt.WindowModal

        width: root.mainWidth
        height: root.mainHeight

        nameFilters: [root.filters]//["SSH Config file (sshd_config)"]

        property string strEditType: ""

        onAccepted: {
            root.strFilePath = fileSelectDialog.fileUrl.toString().replace("file://", "");

            root.selectedFile(strFilePath)

            fileSelectDialog.close();
        }

        onRejected: {
            fileSelectDialog.close();
        }
    }
}
