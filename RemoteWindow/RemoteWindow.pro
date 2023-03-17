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

QT -= gui
QT += core qml quick quickcontrols2 network

TEMPLATE = lib
DEFINES += REMOTEWINDOW_LIBRARY

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

# Pre-Processor for Debug
CONFIG(debug, release|debug): {
   DEFINES += _DEBUG
}


# You can make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += \
    ../SSHConfig/CWindowState.cpp \
    CClient.cpp \
    CRemoteWindow.cpp \

HEADERS += \
    ../SSHConfig/CWindowState.h \
    CClient.h \
    RemoteWindowExport.h \
    CRemoteWindow.h \

RESOURCES += \
    RemoteWindow.qrc \
    Image/Check.png \
    Image/Critical.png \
    Image/KeyFileButton.png \
    Image/KeyFileButtonPressed.png \
    Image/RemoteWindow.png \
    Image/SSHConfig.png \
    Image/Directory.png \
    Image/File.png \
    Image/Lock.png \
    Image/UpDirectory.png \
    Image/UpDirectoryPressed.png

DISTFILES += \
    Image/Check.png \
    Image/Critical.png \
    Image/KeyFileButton.png \
    Image/KeyFileButtonPressed.png \
    Image/RemoteWindow.png \
    Image/SSHConfig.png \
    Image/Directory.png \
    Image/File.png \
    Image/Lock.png \
    Image/UpDirectory.png \
    Image/UpDirectoryPressed.png

# If exist TS file, translate.
EXISTTSFILE = $$system(test -f RemoteWindow_ja_JP.ts && echo 'true')
if(equals(EXISTTSFILE, true)) {
    # Tranlation File.
    TRANSLATIONS += \
        RemoteWindow_ja_JP.ts

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

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Version Information
VERSION = 0.1.1
VERSTR = '\\"$${VERSION}\\"'  # place quotes around the version string
DEFINES += VER=\"$${VERSTR}\" # create a VER macro containing the version string

# Rules for deployment.
## Config Install directory
isEmpty(prefix) || contains(prefix, ^/usr/local[/]*) {
    prefix = /usr/local
}

## Install Execute file
INSTRUCTSET = $$system(getconf LONG_BIT)
if(equals(INSTRUCTSET, 64)) {
    target.path = $${prefix}/lib64
}
else {
    target.path = $${prefix}/lib
}

INSTALLS += target

# Clean
QMAKE_DISTCLEAN += target
