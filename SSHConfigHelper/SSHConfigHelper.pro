# Error Windows, MacOS, Android, iOS
if(!equals(QMAKE_HOST.os, Linux)) {
   error("I apologize, $${TARGET} runs only on Linux.")
}

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

# If exist TS file, translate.
EXISTTSFILE = $$system(test -f SSHConfigHelper_ja_JP.ts && echo 'true')
if(equals(EXISTTSFILE, true)) {
    TRANSLATIONS += \
        SSHConfigHelper_ja_JP.ts

    CONFIG += lrelease
    CONFIG += embed_translations

    #system(lrelease $$PWD/$${TARGET}_ja_JP.ts -qm $$PWD/i18n/$${TARGET}_ja_JP.qm)
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

# Generate D-Bus Interface file.
#system(qdbuscpp2xml -a -A SSHConfigHelper.h -o org.presire.sshconfig.xml)

# Generate D-Bus Adaptor file.
QDBUS = $$system(type -P qdbusxml2cpp > /dev/null && echo 'true')
if(!equals(QDBUS, true)) {
    QDBUS = $$system(type -P qdbusxml2cpp-qt5 > /dev/null && echo 'true')
    if(equals(QDBUS, true)) {
        system(qdbusxml2cpp-qt5 -a SSHConfigAdaptor -c SSHConfigAdaptor -i SSHConfigHelper.h -l SSHConfigHelper org.presire.sshconfig.xml org.presire.sshconfig.server)
    }
}
else {
    system(qdbusxml2cpp -a SSHConfigAdaptor -c SSHConfigAdaptor -i SSHConfigHelper.h -l SSHConfigHelper org.presire.sshconfig.xml org.presire.sshconfig.server)
}

TEMPLATE = app

QT -= gui
QT += dbus xml

# Specify Compiler
!isEmpty(CC) {
   QMAKE_CC  = $${CC}
}

!isEmpty(CXX) {
   QMAKE_CXX = $${CXX}
}

CONFIG += c++17 console
CONFIG -= app_bundle

CONFIG(debug, release|debug):DEFINES += _DEBUG

# You can make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

# Add PolKit-Qt-1 Library & Header directory
!isEmpty(polqt_dir) {
    LIBS += \
        -L$${polqt_dir}/lib64 -lpolkit-qt$${QT_MAJOR_VERSION}-core-1 \
        -L$${polqt_dir}/lib64 -lpolkit-qt$${QT_MAJOR_VERSION}-agent-1 \
        -L$${polqt_dir}/lib   -lpolkit-qt$${QT_MAJOR_VERSION}-core-1 \
        -L$${polqt_dir}/lib   -lpolkit-qt$${QT_MAJOR_VERSION}-agent-1 \

    INCLUDEPATH += \
        $${polqt_dir}/include/polkit-qt$${QT_MAJOR_VERSION}-1
}
else {
    CONFIG += link_pkgconfig
    PKGCONFIG += \
        polkit-qt$${QT_MAJOR_VERSION}-1 \
        polkit-qt$${QT_MAJOR_VERSION}-core-1 \

    LIBS += \
        -lpolkit-qt$${QT_MAJOR_VERSION}-core-1 \
}

SOURCES += \
        SSHConfigHelper.cpp \
        SSHConfigAdaptor.cpp \
        main.cpp

HEADERS += \
    SSHConfigHelper.h \
    SSHConfigAdaptor.h \

RESOURCES += \
    SSHConfigHelper.qrc


# Version Information
VERSION = 0.1.0
VERSTR = '\\"$${VERSION}\\"'  # place quotes around the version string
DEFINES += VER=\"$${VERSTR}\" # create a VER macro containing the version string


# Rules for deployment.
## Config Install directory
isEmpty(prefix) {
    prefix = /usr/local
}


## Install D-Bus Interfase file.
!isEmpty(dbusif) {
    dbusif = $$upper($${dbus})
}

equals(dbusif, YES) {
    isEmpty(prefix)  || contains(prefix, ^/usr/local[/]*) {
        DBus.path = $${prefix}/dbus
        DBus.files = dbus/org.presire.sshconfig.xml
        DBus.commands = cp $${PWD}/dbus/org.presire.sshconfig.xml.in $${PWD}/dbus/org.presire.sshconfig.xml; \
                        mv $${PWD}/dbus/org.presire.sshconfig.xml    /usr/share/dbus-1/interfaces
    }
    else {
        DBus.path = $${prefix}/dbus
        DBus.files = dbus/org.presire.sshconfig.xml
        DBus.commands = cp $${PWD}/dbus/org.presire.sshconfig.xml.in $${PWD}/dbus/org.presire.sshconfig.xml; \
                        mv $${PWD}/dbus/org.presire.sshconfig.xml    $${prefix}/share/dbus-1/interfaces
    }
}


## Config Install file
target.path = $${prefix}/bin
INSTALLS += target
