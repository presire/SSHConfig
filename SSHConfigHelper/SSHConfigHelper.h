// This is an example not a library
/*
    SPDX-FileCopyrightText: 2008 Daniel Nicoletti <dantti85-pk@yahoo.com.br>
    SPDX-FileCopyrightText: 2009 Radek Novacek <rnovacek@redhat.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

#ifndef SAMPLE_HELPER_H
#define SAMPLE_HELPER_H

#include <QCoreApplication>
#include <QList>
#include <QDBusConnection>
#include <QDBusContext>
#include <QDBusMessage>
#include <QProcess>
#include <QLocale>
#include <QTranslator>


struct ServerObject
{
    QString     Key;
    QStringList Values;
};

using ServerObjects = QList<ServerObject>;
Q_DECLARE_METATYPE(ServerObjects)


class SSHConfigHelper : public QCoreApplication, protected QDBusContext
{
    Q_OBJECT
    Q_CLASSINFO("D-Bus Interface", "org.presire.sshconfig.server")

private:
    QStringList  m_Args;
    QString      m_strSysConf;
    QTranslator  m_Translator;

    ServerObject m_ServerObj;
    QString      m_strStdOutput;

private:
    int     ReadSSHValues(const QString strFilePath, QString &strContents, QString &strErrMsg);
    int     WriteSSHValues(const QString strSrcSSHFile, const QString strBakSSHFile, const QString strTmpSSHFile, QString &strErrMsg);
    int     ChangeAuthValue(bool bAuth, QString &strErrMsg);

public:
    SSHConfigHelper(int argc, char *argv[]);
    virtual ~SSHConfigHelper() override;

public Q_SLOTS:
    int ReadSSHFile(const QString strFilePath, QString &strContents, QString &strErrMsg);
    int WriteSSHFile(const QString strSrcSSHFile, const QString strBakSSHFile, const QString strTmpSSHFile, QString &strErrMsg);
    int ExecuteSSHD(const QString strSSHDComandPath, const QStringList aryOptions, QString &strStdMsg, QString &strErrMsg);
    int ChangeAuthMode(bool bAuth, QString &strErrMsg);
};

#endif
