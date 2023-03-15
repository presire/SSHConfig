import QtQuick 2.15
import QtQuick.Window 2.15
import Qt.labs.platform 1.1
import QtQuick.Dialogs 1.3
import QtQuick.Controls 2.15
import QtQml.Models 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Controls.Universal 2.15


FolderDialog {
    property int mainWidth:  640
    property int mainHeight: 480
    property string strDirPath: ""

    id: directorySelectDialog
    title: qsTr("Please select a Directory")

    visible: false
    currentFolder: ""
    folder: StandardPaths.standardLocations(StandardPaths.HomeLocation)[0]
    options: FolderDialog.ShowDirsOnly
    flags: Qt.Dialog
    modality: Qt.WindowModal


    acceptLabel: qsTr("Select")
    rejectLabel: qsTr("Cancel")

    onAccepted: {
        strDirPath = directorySelectDialog.folder.toString().replace("file://", "");
        directorySelectDialog.close();
    }
    onRejected: {
        directorySelectDialog.close();
    }
}
