TEMPLATE = subdirs

SUBDIRS = \
    RemoteWindow \
    SSHConfig \
    SSHConfigHelper

SSHConfig.depends = RemoteWindow

RemoteWindow.file    = RemoteWindow/RemoteWindow.pro
SSHConfig.file       = SSHConfig/SSHConfig.pro
SSHConfigHelper.file = SSHConfigHelper/SSHConfigHelper.pro

QMAKE_DISTCLEAN += Makefile && rm -rf out
