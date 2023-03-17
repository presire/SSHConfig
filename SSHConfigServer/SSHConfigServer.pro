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
EXISTTSFILE = $$system(test -f SSHConfigServer_ja_JP.ts && echo 'true')
if(equals(EXISTTSFILE, true)) {
    TRANSLATIONS += \
        SSHConfigServer_ja_JP.ts

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

TEMPLATE = app

QT -= gui
QT += dbus network

CONFIG += c++17 console
CONFIG -= app_bundle

# Specify Compiler
!isEmpty(CC) {
   QMAKE_CC  = $${CC}
}

!isEmpty(CXX) {
   QMAKE_CXX = $${CXX}
}

# Pre-Processor
CONFIG(debug, release|debug):DEFINES += _DEBUG

# Config optimization
CONFIG(release, debug|release) {
    CONFIG += optimize_full
}


# You can make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

# Add libbsd library & header
#!isEmpty(libbsd) {
#    INSTRUCTSET = $$system(getconf LONG_BIT)
#    if(equals(INSTRUCTSET, 64)) {
#        LIBS += \
#            -L$${libbsd}/lib64 -lbsd \
#    }
#    else {
#        LIBS += \
#            -L$${libbsd}/lib   -lbsd \
#    }

#    INCLUDEPATH += \
#        $${libbsd}/include
#}
#else {
#    CONFIG += link_pkgconfig

#    PKGCONFIG += \
#        libbsd \

#    LIBS += \
#        -lbsd \
#}

SOURCES += \
    CSSLSocket.cpp \
    CServer.cpp \
    CUIRunner.cpp \
    main.cpp

HEADERS += \
    CSSLSocket.h \
    CServer.h \
    CUIRunner.h

RESOURCES += \
    SSHConfigServer.qrc

DISTFILES += \
    i18n/SSHConfigServer_ja_JP.qm

# Version Information
VERSION = 0.1.1
VERSTR = '\\"$${VERSION}\\"'  # place quotes around the version string
DEFINES += VER=\"$${VERSTR}\" # create a VER macro containing the version string

# Rules for deployment.
## Binary Install directory
isEmpty(prefix) || contains(prefix, ^/usr/local[/]*) {
    prefix = /usr/local
}

## prefix for sed command
prefixforsed = $$replace(prefix, /, \/)

## Install configuration file
isEmpty(sysconfdir) {
    sysconfdir = /etc/sshconfig
}

## sysconfdir for sed command
sysconfdirforsed = $$replace(sysconfdir, /, \/)

config.path     = $${sysconfdir}
config.files    = etc/sshconfig.json
config.commands = cp $${PWD}/etc/sshconfig.json.in $${OUT_PWD}/sshconfig.json; \
                  cp $${OUT_PWD}/sshconfig.json    $${sysconfdir}; \
                  chmod 600 $${sysconfdir}/sshconfig.json

## Install systemd file
isEmpty(systemd) {
    systemd = /etc/systemd/system
}

isEmpty(pid) {
    pid = /run
}

isEmpty(user) {
    user = root
}

isEmpty(group) {
    group = root
}

## systemd for sed command
pidforsed = $$replace(pid, /, \/)

daemon.path     = $${sysconfdir}
daemon.files    = etc/sshconfigd.service
daemon.commands = cp $${PWD}/etc/sshconfigd.service.in      $${OUT_PWD}/sshconfigd.service; \
                  sed -i -e \'s/%user%/$${user}/g\'         $${OUT_PWD}/sshconfigd.service; \
                  sed -i -e \'s/%group%/$${group}/g\'       $${OUT_PWD}/sshconfigd.service; \
                  sed -i -e \'s/%pid_dir%/$${pidforsed}/g\'     $${OUT_PWD}/sshconfigd.service; \
                  sed -i -e \'s/%install_dir%/$${prefixforsed}/g\'     $${OUT_PWD}/sshconfigd.service; \
                  sed -i -e \'s/%sysconf_dir%/$${sysconfdirforsed}/g\' $${OUT_PWD}/sshconfigd.service; \
                  cp $${OUT_PWD}/sshconfigd.service                    $${systemd}

## Config Install file
target.path = $${prefix}/bin
INSTALLS += target config daemon

# Clean
QMAKE_DISTCLEAN += target config daemon
