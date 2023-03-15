/*
 * This file was generated by qdbusxml2cpp version 0.8
 * Command line was: qdbusxml2cpp -a SSHConfigAdaptor -c SSHConfigAdaptor -i SSHConfigHelper.h -l SSHConfigHelper org.presire.sshconfig.xml org.presire.sshconfig.server
 *
 * qdbusxml2cpp is Copyright (C) 2020 The Qt Company Ltd.
 *
 * This is an auto-generated file.
 * This file may have been hand-edited. Look for HAND-EDIT comments
 * before re-generating it.
 */

#ifndef SSHCONFIGADAPTOR_H
#define SSHCONFIGADAPTOR_H

#include <QtCore/QObject>
#include <QtDBus/QtDBus>
#include "SSHConfigHelper.h"
QT_BEGIN_NAMESPACE
class QByteArray;
template<class T> class QList;
template<class Key, class Value> class QMap;
class QString;
class QStringList;
class QVariant;
QT_END_NAMESPACE

/*
 * Adaptor class for interface org.presire.sshconfig.server
 */
class SSHConfigAdaptor: public QDBusAbstractAdaptor
{
    Q_OBJECT
    Q_CLASSINFO("D-Bus Interface", "org.presire.sshconfig.server")
    Q_CLASSINFO("D-Bus Introspection", ""
"  <interface name=\"org.presire.sshconfig.server\">\n"
"    <method name=\"ReadSSHFile\">\n"
"      <arg direction=\"out\" type=\"i\"/>\n"
"      <arg direction=\"in\" type=\"s\" name=\"strFilePath\"/>\n"
"      <arg direction=\"out\" type=\"s\" name=\"strContents\"/>\n"
"      <arg direction=\"out\" type=\"s\" name=\"strErrMsg\"/>\n"
"    </method>\n"
"    <method name=\"WriteSSHFile\">\n"
"      <arg direction=\"out\" type=\"i\"/>\n"
"      <arg direction=\"in\" type=\"s\" name=\"strSrcSSHFile\"/>\n"
"      <arg direction=\"in\" type=\"s\" name=\"strBakSSHFile\"/>\n"
"      <arg direction=\"in\" type=\"s\" name=\"strTmpSSHFile\"/>\n"
"      <arg direction=\"out\" type=\"s\" name=\"strErrMsg\"/>\n"
"    </method>\n"
"    <method name=\"ExecuteSSHD\">\n"
"      <arg direction=\"out\" type=\"i\"/>\n"
"      <arg direction=\"in\" type=\"s\" name=\"strSSHDComandPath\"/>\n"
"      <arg direction=\"in\" type=\"as\" name=\"aryOptions\"/>\n"
"      <arg direction=\"out\" type=\"s\" name=\"strStdMsg\"/>\n"
"      <arg direction=\"out\" type=\"s\" name=\"strErrMsg\"/>\n"
"    </method>\n"
"    <method name=\"ChangeAuthMode\">\n"
"      <arg direction=\"out\" type=\"i\"/>\n"
"      <arg direction=\"in\" type=\"b\" name=\"bAuth\"/>\n"
"      <arg direction=\"out\" type=\"s\" name=\"strErrMsg\"/>\n"
"    </method>\n"
"  </interface>\n"
        "")
public:
    SSHConfigAdaptor(SSHConfigHelper *parent);
    virtual ~SSHConfigAdaptor();

    inline SSHConfigHelper *parent() const
    { return static_cast<SSHConfigHelper *>(QObject::parent()); }

public: // PROPERTIES
public Q_SLOTS: // METHODS
    int ChangeAuthMode(bool bAuth, QString &strErrMsg);
    int ExecuteSSHD(const QString &strSSHDComandPath, const QStringList &aryOptions, QString &strStdMsg, QString &strErrMsg);
    int ReadSSHFile(const QString &strFilePath, QString &strContents, QString &strErrMsg);
    int WriteSSHFile(const QString &strSrcSSHFile, const QString &strBakSSHFile, const QString &strTmpSSHFile, QString &strErrMsg);
Q_SIGNALS: // SIGNALS
};

#endif
