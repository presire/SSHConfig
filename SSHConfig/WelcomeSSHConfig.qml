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
    property var windowState: null
    property int fontPadding: 0

    MouseArea {
        id: mouseAreaWelcome
        anchors.fill: parent
        acceptedButtons: Qt.ForwardButton | Qt.BackButton  // Enable "ForwardButton" and "BackButton" on mouse
        hoverEnabled: true
        cursorShape: labelLink.hoverd ? Qt.PointingHandCursor : Qt.ArrowCursor
        z: 1

        // Single click
        onClicked: {
            if (mouse.button === Qt.ForwardButton) {
                parentName.screenMoved("", 1)
            }
            else if (mouse.button === Qt.BackButton) {
                parentName.screenMoved("", 0)
            }
        }

        onMouseXChanged: {
            let optionX = labelLink.mapToItem(root, 0, 0).x
            let optionY = labelLink.mapToItem(root, 0, 0).y
            if (mouseX >= optionX && mouseX <= (optionX + labelLink.width) &&
                mouseY >= optionY && mouseY <= (optionY + labelLink.height)) {
                    cursorShape = Qt.PointingHandCursor
            }
            else {
                cursorShape = Qt.ArrowCursor
            }
        }
    }

    ScrollView {
        id: scrollWelcome
        width: parent.width
        height : parent.height
        contentWidth: welcomeColumn.width    // The important part
        contentHeight: welcomeColumn.height  // Same
        anchors.fill: parent
        clip : false                          // Prevent drawing column outside the scrollview borders

        ColumnLayout {
            id: welcomeColumn
            x: parent.x
            width: root.width
            Layout.fillWidth: true
            Layout.fillHeight: true

            spacing: 5

            Label {
                text: qsTr("<h2>[ SSH Server ]</h2>")
                width: parent.availableWidth

                font.pointSize: 14 + root.fontPadding

                textFormat: Label.RichText
                wrapMode: Label.WordWrap

                horizontalAlignment: Label.AlignLeft
                verticalAlignment: Label.AlignVCenter
                Layout.topMargin: 50
                Layout.leftMargin: 50
                Layout.rightMargin: 50
                Layout.fillWidth: true
                Layout.fillHeight: true

                Rectangle {
                    y: parent.height
                    width: parent.width
                    height: 5
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "steelblue" }
                        GradientStop { position: 1.0; color: "black" }
                    }
                    radius: 10

                    opacity: 0.8
                }
            }

            Label {
                text: qsTr("You can configure items related to the SSH Server (\"sshd_config\" file).")
                width: parent.availableWidth

                font.pointSize: 14 + root.fontPadding

                textFormat: Label.RichText
                wrapMode: Label.WordWrap

                horizontalAlignment: Label.AlignLeft
                verticalAlignment: Label.AlignVCenter
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.topMargin: 10
                Layout.leftMargin: 50
                Layout.rightMargin: 50
            }

            Label {
                text: qsTr("<h2>[ SSH Test ]</h2>")
                width: parent.availableWidth

                font.pointSize: 14 + root.fontPadding

                textFormat: Label.RichText
                wrapMode: Label.WordWrap

                horizontalAlignment: Label.AlignLeft
                verticalAlignment: Label.AlignVCenter
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.topMargin: 80
                Layout.leftMargin: 50
                Layout.rightMargin: 50

                Rectangle {
                    y: parent.height
                    width: parent.width
                    height: 5
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "steelblue" }
                        GradientStop { position: 1.0; color: "black" }
                    }
                    radius: 10

                    opacity: 0.8
                }
            }

            Label {
                text: qsTr("You can test using the \"sshd -T\" command.")
                width: parent.availableWidth

                font.pointSize: 14 + root.fontPadding

                textFormat: Label.RichText
                wrapMode: Label.WordWrap

                horizontalAlignment: Label.AlignLeft
                verticalAlignment: Label.AlignVCenter
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.topMargin: 10
                Layout.leftMargin: 50
                Layout.rightMargin: 50
            }

            Label {
                text: qsTr("<h2>[ Mode ]</h2>")
                width: parent.availableWidth

                font.pointSize: 14 + root.fontPadding

                textFormat: Label.RichText
                wrapMode: Label.WordWrap

                horizontalAlignment: Label.AlignLeft
                verticalAlignment: Label.AlignVCenter
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.topMargin: 80
                Layout.leftMargin: 50
                Layout.rightMargin: 50

                Rectangle {
                    y: parent.height
                    width: parent.width
                    height: 5
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "steelblue" }
                        GradientStop { position: 1.0; color: "black" }
                    }
                    radius: 10

                    opacity: 0.8
                }
            }

            Label {
                text: qsTr("You can configure settings regarding this software.")
                width: parent.availableWidth

                font.pointSize: 14 + root.fontPadding

                textFormat: Label.RichText
                wrapMode: Label.WordWrap

                horizontalAlignment: Label.AlignLeft
                verticalAlignment: Label.AlignVCenter
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.topMargin: 10
                Layout.leftMargin: 50
                Layout.rightMargin: 50
            }

            Label {
                text: qsTr("<h2>[ About Qt ]</h2>")
                width: parent.availableWidth

                font.pointSize: 14 + root.fontPadding

                textFormat: Label.RichText
                wrapMode: Label.WordWrap

                horizontalAlignment: Label.AlignLeft
                verticalAlignment: Label.AlignVCenter
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.topMargin: 80
                Layout.leftMargin: 50
                Layout.rightMargin: 50

                Rectangle {
                    y: parent.height
                    width: parent.width
                    height: 5
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "steelblue" }
                        GradientStop { position: 1.0; color: "black" }
                    }
                    radius: 10

                    opacity: 0.8
                }
            }

            Label {
                text: qsTr("This section describes matters related to Qt.")
                width: parent.availableWidth

                font.pointSize: 14 + root.fontPadding

                textFormat: Label.RichText
                wrapMode: Label.WordWrap

                horizontalAlignment: Label.AlignLeft
                verticalAlignment: Label.AlignVCenter
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.topMargin: 10
                Layout.leftMargin: 50
                Layout.rightMargin: 50
            }

            Image {
                source: "Image/SSHConfig.png"
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                Layout.topMargin: 50
                fillMode: Image.PreserveAspectFit
            }

            Label {
                text: "SSHConfig" + "\t" + windowState.getVersion()
                width: parent.availableWidth

                font.pointSize: 12 + root.fontPadding

                textFormat: Label.RichText
                wrapMode: Label.WordWrap

                horizontalAlignment: Label.AlignHCenter
                verticalAlignment: Label.AlignVCenter
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.topMargin: 10
            }

            Label {
                text: qsTr("SSHConfig developed by Presire")
                width: parent.availableWidth

                font.pointSize: 12 + root.fontPadding
                wrapMode: Label.WordWrap

                horizontalAlignment: Label.AlignHCenter
                verticalAlignment: Label.AlignVCenter
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.topMargin: 10
            }

            Label {
                id: labelLink
                text: "<span style=\"color: #7f7faf;\">Visit Prersire Github</span>"
                width: parent.availableWidth

                font.pointSize: 12 + root.fontPadding
                textFormat: Label.RichText
                wrapMode: Label.WordWrap

                horizontalAlignment: Label.AlignHCenter
                verticalAlignment: Label.AlignVCenter
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.topMargin: 20

                onLinkActivated: {
                    Qt.openUrlExternally(link)
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        labelLink.linkActivated("https://github.com/presire")
                    }
                }
            }
        }
    }
}
