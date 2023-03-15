import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Controls.Universal 2.15


Item {
    id: root
    objectName: "pageAboutQt"
    focus: true

    property var parentName:  null
    property var windowState: null
    property int fontPadding: 0

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.ForwardButton | Qt.BackButton  // Enable "ForwardButton" and "BackButton" on mouse

        // Single click
        onClicked: {
            if (mouse.button === Qt.ForwardButton) {
                parentName.screenMoved("", 1)
            }
            else if (mouse.button === Qt.BackButton) {
                parentName.screenMoved("", 0)
            }
        }
    }

    Rectangle {
        id: rootRect
        width: parent.width
        height: parent.height
        color: "transparent"
        clip: true
        anchors.centerIn: parent

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            onWheel: {
                // Manage the scrolling manual, here.
                if (vBar.height < aboutQtRow.height) {
                    if (wheel.angleDelta.y > 0) {
                        vBar.decrease()
                    }
                    else {
                        vBar.increase()
                    }
                }
                else {
                    vBar.position = 0
                }
            }
        }

        ScrollBar {
            id: vBar
            hoverEnabled: true
            active: hovered || pressed
            orientation: Qt.Vertical
            size: parent.height / aboutQtRow.height
            stepSize: 0.1
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.bottom: parent.bottom
        }

        RowLayout {
            id: aboutQtRow
            x: parent.x
            y: -vBar.position * height
            width: parent.width
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 20

            Image {
                id: imgQt
                source: "Image/Qt.png"
                Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
                fillMode: Image.PreserveAspectFit

                Layout.margins: 20
            }

            ColumnLayout {
                width: parent.width
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 5

                Label {
                    id: aboutQtLabelHeader
                    text: qsTr("About Qt")
                    width: aboutQtRow.width - imgQt.width - aboutQtRow.spacing * 2

                    font.pointSize: 20 + root.fontPadding
                    font.bold: true
                    wrapMode: Label.WordWrap
                    background: null

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignTop | Qt.AlignVCenter
                    Layout.topMargin: 20
                    Layout.leftMargin: 20
                    Layout.rightMargin: 20
                    verticalAlignment: Text.AlignVCenter
                }

                Label {
                    id: aboutQtLabel1
                    text: qsTr("This software is developed with Qt 5.15.") + "\n\n" +
                          "Qt is a C++ toolkit for cross-platform application development." + "\n" +
                          "Qt provides single-source portability across all major desktop operating systems." + "\n" +
                          "It is also available for embedded Linux and other embedded and mobile operating systems." + "\n\n" +
                          "Qt is available under multiple licensing options designed to accommodate the needs of our various users."  + "\n\n" +
                          "Qt licensed under our commercial license agreement is appropriate for development of proprietary/commercial software " +
                          "where you do not want to share any source code with third parties or otherwise cannot comply with the terms of GNU (L)GPL." + "\n\n" +
                          "Qt licensed under GNU (L)GPL is appropriate for the development of Qt applications provided you can comply with the terms and " +
                          "conditions of the respective licenses."

                    width: aboutQtRow.width - imgQt.width - aboutQtRow.spacing * 2

                    font.pointSize: 14 + root.fontPadding
                    wrapMode: Label.WordWrap
                    background: null

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignTop | Qt.AlignVCenter
                    Layout.topMargin: 20
                    Layout.leftMargin: 20
                    Layout.rightMargin: 20
                    verticalAlignment: Text.AlignVCenter
                }

                Label {
                    id: aboutQtLabel2
                    text: "<html><head/><body><p>Please see <a href=\"http://qt.io/licensing/\">qt.io/licensing</a> for an overview of Qt licensing.</p></body></html>"
                    width: aboutQtRow.width - imgQt.width - aboutQtRow.spacing * 2

                    font.pointSize: 14 + root.fontPadding
                    textFormat: Label.RichText
                    wrapMode: Label.WordWrap
                    background: null

                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignTop | Qt.AlignVCenter
                    Layout.topMargin: 30
                    Layout.leftMargin: 20
                    Layout.rightMargin: 20
                    verticalAlignment: Text.AlignVCenter

                    onLinkActivated: {
                        Qt.openUrlExternally(link)
                    }

                    MouseArea {
                        id: mouseArea1
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            aboutQtLabel2.linkActivated("http://qt.io/licensing/")
                        }
                    }
                }

                Label {
                    id: aboutQtLabel3
                    text: "Copyright (C) 2023 The Qt Company Ltd and other contributors." + "\n" +
                          "Qt and the Qt logo are trademarks of The Qt Company Ltd." + "\n" +
                          "Qt is The Qt Company Ltd product developed as an open source project."

                    width: aboutQtRow.width - imgQt.width - aboutQtRow.spacing * 2

                    font.pointSize: 14 + root.fontPadding
                    wrapMode: Label.WordWrap
                    background: null

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignTop | Qt.AlignVCenter
                    Layout.topMargin: 30
                    Layout.leftMargin: 20
                    Layout.rightMargin: 20
                    verticalAlignment: Text.AlignVCenter
                }

                Label {
                    id: aboutQtLabel4
                    text: "<html><head/><body><p>See <a href=\"http://qt.io/\">qt.io</a> for more information.</p></body></html>"
                    width: aboutQtRow.width - imgQt.width - aboutQtRow.spacing * 2

                    font.pointSize: 14 + root.fontPadding
                    textFormat: Label.RichText
                    wrapMode: Label.WordWrap
                    background: null

                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignTop | Qt.AlignVCenter
                    Layout.topMargin: 30
                    Layout.leftMargin: 20
                    Layout.rightMargin: 20
                    verticalAlignment: Text.AlignVCenter

                    onLinkActivated: {
                        Qt.openUrlExternally(link)
                    }

                    MouseArea {
                        id: mouseArea2
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            aboutQtLabel4.linkActivated("http://qt.io/")
                        }
                    }
                }
            }
        }
    }
}
