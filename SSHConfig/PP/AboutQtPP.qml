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

    ScrollView {
        id: scrollAboutQt
        width: parent.width
        height : parent.height
        contentWidth: aboutQtRow.width    // The important part
        contentHeight: aboutQtRow.height  // Same
        anchors.fill: parent
        clip : true                       // Prevent drawing column outside the scrollview borders

        RowLayout {
            id: aboutQtRow
            x: parent.x
            width: parent.width
            spacing: 20

            Image {
                id: imgQt
                source: "qrc:/Image/Qt.png"
                sourceSize.width:  root.width / 15
                sourceSize.height: root.width / 15
                fillMode: Image.PreserveAspectFit

                Layout.alignment: Qt.AlignTop
                Layout.topMargin: 20
                Layout.leftMargin: ((root.width - imgQt.width - aboutQtLabel1.width - 40) / 2) > 20 ?
                                   (root.width - imgQt.width - aboutQtLabel1.width - 40) / 2 : 20
            }

            ColumnLayout {
                width: parent.width
                spacing: 5

                Layout.fillHeight: true

                Label {
                    id: aboutQtLabelHeader
                    text: qsTr("About Qt")

                    font.pointSize: 18 + root.fontPadding
                    font.bold: true
                    wrapMode: Label.WordWrap
                    background: null

                    Layout.preferredWidth: root.width - imgQt.x - imgQt.width - aboutQtRow.spacing - 20
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignTop | Qt.AlignVCenter
                    Layout.topMargin: 20
                    Layout.rightMargin: 20
                    verticalAlignment: Label.AlignVCenter
                }

                Label {
                    id: aboutQtLabel1
                    text: qsTr("This software is developed with Qt 5.15.") + "<br><br>" +
                          "Qt is a C++ toolkit for cross-platform application development." + "<br>" +
                          "Qt provides single-source portability across all major desktop operating systems." + "<br>" +
                          "It is also available for embedded Linux and other embedded and mobile operating systems." + "<br><br>" +
                          "Qt is available under multiple licensing options designed to accommodate the needs of our various users."  + "<br><br>" +
                          "Qt licensed under our commercial license agreement is appropriate for development of proprietary/commercial software " + "<br>" +
                          "where you do not want to share any source code with third parties or otherwise cannot comply with the terms of GNU (L)GPL." + "<br><br>" +
                          "Qt licensed under GNU (L)GPL is appropriate for the development of Qt applications provided you can comply with the terms and " + "<br>" +
                          "conditions of the respective licenses."

                    font.pointSize: 12 + root.fontPadding
                    textFormat: Label.RichText
                    wrapMode: Label.WordWrap
                    background: null

                    Layout.preferredWidth: root.width - imgQt.x - imgQt.width - aboutQtRow.spacing - 20
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignTop | Qt.AlignVCenter
                    Layout.topMargin: 20
                    Layout.rightMargin: 20
                    verticalAlignment: Label.AlignVCenter
                }

                Label {
                    id: aboutQtLabel2
                    text: "Please see <span style=\"color: #7f7faf;\">qt.io/licensing</span> for an overview of Qt licensing."

                    font.pointSize: 12 + root.fontPadding
                    textFormat: Label.RichText
                    wrapMode: Label.WordWrap
                    background: null

                    Layout.preferredWidth: root.width - imgQt.x - imgQt.width - aboutQtRow.spacing - 20
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignTop | Qt.AlignVCenter
                    Layout.topMargin: 30
                    Layout.rightMargin: 20
                    verticalAlignment: Label.AlignVCenter

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

                    font.pointSize: 12 + root.fontPadding
                    wrapMode: Label.WordWrap
                    background: null

                    Layout.preferredWidth: root.width - imgQt.x - imgQt.width - aboutQtRow.spacing - 20
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignTop | Qt.AlignVCenter
                    Layout.topMargin: 30
                    Layout.rightMargin: 20
                    verticalAlignment: Label.AlignVCenter
                }

                Label {
                    id: aboutQtLabel4
                    text: "See <span style=\"color: #7f7faf;\">qt.io</span> for more information."

                    font.pointSize: 12 + root.fontPadding
                    textFormat: Label.RichText
                    wrapMode: Label.WordWrap
                    background: null

                    Layout.preferredWidth: root.width - imgQt.x - imgQt.width - aboutQtRow.spacing - 20
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignTop | Qt.AlignVCenter
                    Layout.topMargin: 30
                    Layout.rightMargin: 20
                    Layout.bottomMargin: 30
                    verticalAlignment: Label.AlignVCenter

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
