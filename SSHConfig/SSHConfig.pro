# Error Windows, MacOS, Android, iOS
if(!equals(QMAKE_HOST.os, Linux)) {
   error("I apologize, $${TARGET} runs only on Linux.")
}
else {
   message("OK. Your PC is Linux, so you can build it.")
}

message("Host Architecture: $${QMAKE_HOST.arch}")

# At least Qt 5.15 is required.
lessThan(QT_MAJOR_VERSION, 5) {
   lessThan(QT_MINOR_VERSION, 15) {
      message("You use Qt version" $$[QT_VERSION])
      error("Error! you need at least Qt version 5.15")
   }
}

# Show message, Debug or Release.
CONFIG(debug, debug|release) {
    message("$${TARGET} : Debug Build.")
}
else {
    message("$${TARGET} : Release Build.")
}

QT += core widgets qml quick quickcontrols2 dbus

CONFIG += c++17

# Specify Compiler
!isEmpty(CC) {
   QMAKE_CC  = $${CC}
}

!isEmpty(CXX) {
   QMAKE_CXX = $${CXX}
}

# Config optimization
CONFIG(release, debug|release) {
    CONFIG += optimize_full
}

# Target PC or PinePhone
!isEmpty(machine) {
    TargetMachine = $$upper($${machine})
    if(equals(TargetMachine, PINEPHONE)) {
        CONFIG(release, debug|release) {
            # Check Architecture.
            ARCH = $${QMAKE_CXXFLAGS}
            !contains(ARCH, ^.*-march[= ]arm([^ ]+).*$) {
                ARCH = $$system(uname -m)
                if(!equals(ARCH, aarch64)) {
                    error("The compiler you are using is not for AArch64. PinePhone is for AArch64.")
                }
            }
       }

       system(echo)
       message("You can build this software for PinePhone.")
       system(echo)
       DEFINES += "PINEPHONE"
    }
    else {
       system(echo)
       error("The \"machine\" option can be \"pinephone\" or \"PINEPHONE\".")
       system(echo)
    }
}
else {
   system(echo)
   message("You will be compile PC.")
   system(echo)
}

CONFIG(debug, release|debug): {
   DEFINES += _DEBUG
}

# You can make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

CONFIG(debug, debug|release): {
    LIBS        += -L$$PWD/../RemoteWindow/Debug/ -lRemoteWindow
    INCLUDEPATH += $$PWD/../RemoteWindow
    #DEPENDPATH  += $$PWD/../RemoteWindow
}
else {
    LIBS        += -L$$OUT_PWD/../RemoteWindow -lRemoteWindow
    INCLUDEPATH += $$PWD/../RemoteWindow
    #DEPENDPATH  += $$PWD/../RemoteWindow
}

SOURCES += \
        CSSHServer.cpp \
        CSSHService.cpp \
        CSSHTest.cpp \
        CSSHValue.cpp \
        CWindowState.cpp \
        main.cpp

HEADERS += \
    CSSHServer.h \
    CSSHService.h \
    CSSHTest.h \
    CSSHValue.h \
    CWindowState.h \

RESOURCES += \
    SSHConfig.qrc \
    Image/Add.png \
    Image/AddPressed.png \
    Image/Back.png \
    Image/Check.png \
    Image/Critical.png \
    Image/Drawer.png \
    Image/Directory.png \
    Image/File.png \
    Image/FileButton.png \
    Image/FileButtonPressed.png \
    Image/FileNetworkButton.png \
    Image/FileNetworkButtonPressed.png \
    Image/Key.png \
    Image/KeyFileButton.png \
    Image/KeyFileButtonPressed.png \
    Image/Lock.png \
    Image/OpenDirectory.png \
    Image/OpenDirectoryPressed.png \
    Image/HomeButton.png \
    Image/HomeButtonPressed.png \
    Image/RemoteWindow.png \
    Image/SSHConfig.png \
    Image/Qt.png \
    Image/UpDirectory.png \
    Image/UpDirectoryPressed.png \
    Image/Warning.png \

DISTFILES += \
    Image/Add.png \
    Image/AddPressed.png \
    Image/Back.png \
    Image/Check.png \
    Image/Critical.png \
    Image/Drawer.png \
    Image/Directory.png \
    Image/File.png \
    Image/FileButton.png \
    Image/FileButtonPressed.png \
    Image/FileNetworkButton.png \
    Image/FileNetworkButtonPressed.png \
    Image/Key.png \
    Image/KeyFileButton.png \
    Image/KeyFileButtonPressed.png \
    Image/Lock.png \
    Image/OpenDirectory.png \
    Image/OpenDirectoryPressed.png \
    Image/HomeButton.png \
    Image/HomeButtonPressed.png \
    Image/RemoteWindow.png \
    Image/SSHConfig.png \
    Image/Qt.png \
    Image/UpDirectory.png \
    Image/UpDirectoryPressed.png \
    Image/Warning.png \

# If exist TS file, translate.
EXISTTSFILE = $$system(test -f SSHConfig_ja_JP.ts && echo 'true')
if(equals(EXISTTSFILE, true)) {
    # Tranlation File.
    TRANSLATIONS += \
        SSHConfig_ja_JP.ts

    # Command to generate the QM file
    CONFIG += lrelease
    CONFIG += embed_translations

    LRELEASE = $$system(type -P lrelease > /dev/null && echo 'true')
    if(!equals(LRELEASE, true)) {
        LRELEASE = $$system(type -P lrelease-qt5 > /dev/null && echo 'true')
        if(equals(LRELEASE, true)) {
            system(lrelease-qt5 $$PWD/$${TARGET}_ja_JP.ts -qm $$PWD/i18n/$${TARGET}_ja_JP.qm)
        }
    }
    else {
        system(lrelease $$PWD/$${TARGET}_ja_JP.ts -qm $$PWD/i18n/$${TARGET}_ja_JP.qm)
    }
}
else {
    message("Not Translation")
}

# Version Information
VERSION = 0.1.0
VERSTR = '\\"$${VERSION}\\"'  # place quotes around the version string
DEFINES += VER=\"$${VERSTR}\" # create a VER macro containing the version string

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Rules for deployment.
isEmpty(prefix) || contains(prefix, ^/usr/local[/]*) {
    prefix = /usr/local
}

# Config Install file
## prefix for sed command
prefixforsed = $$replace(prefix, /, \/)

## Install D-Bus Configuration file (for System Bus)
isEmpty(prefix) || contains(prefix, ^/usr/local[/]*) {
    DBusConf.path     = /usr/share/dbus-1/system.d
    DBusConf.files    = dbus/org.presire.sshconfig.conf
    DBusConf.commands = cp $${PWD}/dbus/org.presire.sshconfig.conf.in $${PWD}/dbus/org.presire.sshconfig.conf; \
                        mv $${PWD}/dbus/org.presire.sshconfig.conf /usr/share/dbus-1/system.d
}
else {
    DBusConf.path     = $${prefix}/share/dbus-1/system.d
    DBusConf.files    = dbus/org.presire.sshconfig.conf
    DBusConf.commands = cp $${PWD}/dbus/org.presire.sshconfig.conf.in $${PWD}/dbus/org.presire.sshconfig.conf; \
                        mv $${PWD}/dbus/org.presire.sshconfig.conf $${prefix}/share/dbus-1/system.d
}

## Install D-Bus Auto-Start file
isEmpty(prefix) || equals(prefix, /usr/local) || equals(prefix, /usr/local/) {
    DBusAS.path     = /usr/share/dbus-1/system-services
    DBusAS.files    = dbus/org.presire.sshconfig.service
    DBusAS.commands = cp $${PWD}/dbus/org.presire.sshconfig.service.in $${PWD}/dbus/org.presire.sshconfig.service; \
                      sed -i -e \'s/%install_dir%/$${prefixforsed}/g\' $${PWD}/dbus/org.presire.sshconfig.service; \
                      mv $${PWD}/dbus/org.presire.sshconfig.service /usr/share/dbus-1/system-services
}
else {
    DBusAS.path     = $${prefix}/share/dbus-1/system-services
    DBusAS.files    = dbus/org.presire.sshconfig.service
    DBusAS.commands = cp $${PWD}/dbus/org.presire.sshconfig.service.in $${PWD}/dbus/org.presire.sshconfig.service; \
                      sed -i -e \'s/%install_dir%/$${prefixforsed}/g\' $${PWD}/dbus/org.presire.sshconfig.service; \
                      mv $${PWD}/dbus/org.presire.sshconfig.service $${prefix}/share/dbus-1/system-services
}

## Install Polkit file
isEmpty(prefix) || equals(prefix, /usr/local) || equals(prefix, /usr/local/) {
    Polkit.path     = /usr/share/polkit-1/actions
    Polkit.files    = polkit/org.presire.sshconfig.policy
    Polkit.commands = cp $${PWD}/polkit/org.presire.sshconfig.policy.in $${PWD}/polkit/org.presire.sshconfig.policy; \
                      mv $${PWD}/polkit/org.presire.sshconfig.policy /usr/share/polkit-1/actions
}
else {
    Polkit.path     = $${prefix}/share/polkit-1/actions
    Polkit.files    = polkit/org.presire.sshconfig.policy
    Polkit.commands = cp $${PWD}/polkit/org.presire.sshconfig.policy.in $${PWD}/polkit/org.presire.sshconfig.policy; \
                      mv $${PWD}/polkit/org.presire.sshconfig.policy $${prefix}/share/polkit-1/actions
}

## Install Icon file
isEmpty(prefix) || equals(prefix, /usr/local) || equals(prefix, /usr/local/) {
    DesktopIcon.path = /usr/share/icons/hicolor/128x128/apps
    DesktopIcon.files = Image/SSHConfig.png
    DesktopIconSVG.path = /usr/share/icons/hicolor/scalable/apps
    DesktopIconSVG.files = Image/SSHConfig.svg
}
else {
    DesktopIcon.path = $${prefix}/share/icons/hicolor/128x128/apps
    DesktopIcon.files = Image/SSHConfig.png
    DesktopIconSVG.path = $${prefix}/share/icons/hicolor/scalable/apps
    DesktopIconSVG.files = Image/SSHConfig.svg
}

## Install Desktop Entry file
isEmpty(prefix) || equals(prefix, /usr/local) || equals(prefix, /usr/local/) {
    DesktopEntry.path     = /usr/share/applications
    DesktopEntry.files    = Applications/SSHConfig.desktop
    DesktopEntry.commands = cp $${PWD}/DeskopEntry/SSHConfig.desktop.in $${PWD}/DeskopEntry/SSHConfig.desktop; \
                            sed -i -e \'s/%ver%/$${VERSION}/g\' $${PWD}/DeskopEntry/SSHConfig.desktop; \
                            sed -i -e \'s/%install_dir%/$${prefixforsed}/g\' $${PWD}/DeskopEntry/SSHConfig.desktop; \
                            mv $${PWD}/DeskopEntry/SSHConfig.desktop /usr/share/applications/SSHConfig.desktop
}
else {
    DesktopEntry.path     = $${prefix}/share/applications
    DesktopEntry.files    = Applications/SSHConfig.desktop
    DesktopEntry.commands = cp $${PWD}/DeskopEntry/SSHConfig.desktop.in $${PWD}/DeskopEntry/SSHConfig.desktop; \
                            sed -i -e \'s/%ver%/$${VERSION}/g\' $${PWD}/DeskopEntry/SSHConfig.desktop; \
                            sed -i -e \'s/%install_dir%/$${prefixforsed}/g\' $${PWD}/DeskopEntry/SSHConfig.desktop; \
                            mv $${PWD}/DeskopEntry/SSHConfig.desktop $${prefix}/share/applications/SSHConfig.desktop
}

## Install SSHConfig wrapper script file.
Script.path     = $${prefix}/bin
Script.files    = Scripts/SSHConfig.sh
Script.commands = cp $${PWD}/Scripts/SSHConfig.sh.in  $${OUT_PWD}/SSHConfig.sh; \
                  mv $${OUT_PWD}/SSHConfig.sh $${prefix}/bin/SSHConfig.sh

## Install Binary file
target.path = $${prefix}/bin

## Install
INSTALLS += target Script DBusConf DBusAS Polkit DesktopIcon DesktopIconSVG DesktopEntry

# Clean
QMAKE_DISTCLEAN += target Script DBusConf DBusAS Polkit DesktopEntry
