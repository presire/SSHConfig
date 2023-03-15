// This is an example not a library
/*
    SPDX-FileCopyrightText: 2008 Daniel Nicoletti <dantti85-pk@yahoo.com.br>
    SPDX-FileCopyrightText: 2009 Radek Novacek <rnovacek@redhat.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

#include <QTimer>
#include <QFileInfo>
#include <QDomDocument>
#include <QException>
#include <QTextStream>
#include "polkitqt1-authority.h"
#include "SSHConfigHelper.h"
#include "SSHConfigAdaptor.h"

#if _DEBUG
   #include <QDebug>
#endif


// Marshall the MyStructure data into a D-Bus argument
QDBusArgument& operator<<(QDBusArgument &argument, const ServerObjects &ServerObjs)
{
    argument.beginArray();

    foreach (auto Object, ServerObjs)
    {
        argument.beginStructure();
        argument << Object.Key << Object.Values;
        argument.endStructure();
    }

    argument.endArray();

    return argument;
}


// Retrieve the MyStructure data from the D-Bus argument
const QDBusArgument& operator>>(const QDBusArgument &argument, ServerObjects &ServerObjs)
{
    argument.beginArray();

    ServerObjs.clear();
    while (!argument.atEnd())
    {
        ServerObject Object = {};
        argument.beginStructure();
        argument >> Object.Key >> Object.Values;
        argument.endStructure();
        ServerObjs.append(Object);
    }

    argument.endArray();

    return argument;
}


SSHConfigHelper::SSHConfigHelper(int argc, char *argv[]) : QCoreApplication(argc, argv)
{
#if _DEBUG
    qDebug() << "Creating Helper";
#endif

    // Register class.
    qRegisterMetaType<ServerObjects>("ServerObjects");
    qDBusRegisterMetaType<ServerObjects>();

    (void) new SSHConfigAdaptor(this);

    // Get path to configuration file.
    auto pApp = QCoreApplication::instance();
    m_Args    = pApp->arguments();

    // Set locale.
    foreach(auto arg, m_Args)
    {
        if(arg.mid(0, 9) == "--locale=")
        {
            auto strLocale = arg.replace("--locale=", "", Qt::CaseSensitive);
            auto iLang = strLocale.compare("jp", Qt::CaseSensitive) == 0 ? 1 : 0;
            if(iLang == 1)
            {
                if(m_Translator.load(":/i18n/SSHConfigHelper_ja_JP.qm"))
                {
                    this->installTranslator(&m_Translator);
                }
            }
        }
    }

    QDBusConnection bus = QDBusConnection::systemBus();

    // Register the DBus service
    if (!bus.registerService("org.presire.sshconfig"))
    {
        QTextStream ErrStream(stderr);
        ErrStream << bus.lastError().message() << Qt::endl;

        QTimer::singleShot(0, this, &QCoreApplication::quit);
        return;
    }

    // Register the DBus object
    if (!bus.registerObject("/org/presire/sshconfig", this))
    {
        QTextStream ErrStream(stderr);
        ErrStream << tr("unable to register service interface to dbus.") << Qt::endl;

        QTimer::singleShot(0, this, &QCoreApplication::quit);
        return;
    }

    // Normally, it will set a timeout, so this software can free some resources of the poor client machine.
#if _DEBUG
    qDebug() << "Creating Helper";
    QTimer::singleShot(10 * 60 * 1000, this, &QCoreApplication::quit);  // 10 minites for debug.
#else
    QTimer::singleShot(30 * 1000, this, &QCoreApplication::quit);
#endif
}


SSHConfigHelper::~SSHConfigHelper()
{
#if _DEBUG
    qDebug() << "Destroying Helper";
#endif
}


int SSHConfigHelper::ReadSSHFile(const QString strFilePath, QString &strContents, QString &strErrMsg)
{
    // The service name of the caller.
    PolkitQt1::Authority::Result result;
    PolkitQt1::SystemBusNameSubject subject(QDBusContext::message().service());

    result = PolkitQt1::Authority::instance()->checkAuthorizationSync("org.presire.sshconfig.server.ReadSSHFile",
                                                                      subject, PolkitQt1::Authority::AllowUserInteraction);
    if (result == PolkitQt1::Authority::Yes)
    {   // Caller is authorized so we can perform the action
        return ReadSSHValues(strFilePath, strContents, strErrMsg);
    }
    else
    {   // Caller is not authorized so the action can't be performed
        return 1;
    }
}


int SSHConfigHelper::ReadSSHValues(const QString strFilePath, QString &strContents, QString &strErrMsg)
{
    // This action must be authorized.
    try
    {
        QFile File(strFilePath);
        if(!File.exists())
        {
            strErrMsg = tr("No such file : %1").arg(strFilePath);
            return -1;
        }

        if (!File.open(QIODevice::ReadOnly | QIODevice::Text))
        {
            strErrMsg = tr("File open error : %1").arg(strFilePath) + "<br>" + File.errorString();
            return -1;
        }

        QTextStream inStream(&File);

        // Set character encoding to UTF-8. (If UTF-8 is not specified, double-byte characters are garbled.)
        inStream.setCodec("UTF-8");

        // Read sshd_config file.
        strContents = inStream.readAll();

        File.close();
    }
    catch(QException &ex)
    {
        strErrMsg = ex.what();
        return -1;
    }

    return 0;
}


int SSHConfigHelper::WriteSSHFile(const QString strSrcSSHFile, const QString strBakSSHFile, const QString strTmpSSHFile, QString &strErrMsg)
{
    // message().service() is the service name of the caller.
    // check if the caller is authorized to following action.
    PolkitQt1::Authority::Result result;
    PolkitQt1::SystemBusNameSubject subject(QDBusContext::message().service());

    result = PolkitQt1::Authority::instance()->checkAuthorizationSync("org.presire.sshconfig.server.WriteSSHFile",
                                                                      subject, PolkitQt1::Authority::AllowUserInteraction);
    if (result == PolkitQt1::Authority::Yes)
    {   // Caller is authorized so we can perform the action
        return WriteSSHValues(strSrcSSHFile, strBakSSHFile, strTmpSSHFile, strErrMsg);
    }
    else
    {   // Caller is not authorized so the action can't be performed
        return 1;
    }
}


int SSHConfigHelper::WriteSSHValues(const QString strSrcSSHFile, const QString strBakSSHFile, const QString strTmpSSHFile, QString &strErrMsg)
{
    // This action must be authorized.
    try
    {
        // Get permission of source sshd_config file.
        auto SrcPermission = QFile::permissions(strSrcSSHFile);

        // Backup sshd_config file.
        if(!QFile::rename(strSrcSSHFile, strBakSSHFile))
        {
            strErrMsg = tr("File backup error : %1").arg(strSrcSSHFile) + QString("<br>");
            return -1;
        }

        // Copy sshd_config file.
        // (When use QFile::copy method, double-byte characters are garbled.)
        // (Therefore, a new file is created.)
        QFile TmpSSHFile(strTmpSSHFile);
        if(!TmpSSHFile.open(QIODevice::ReadOnly))
        {
           strErrMsg = tr("File open error : %1").arg(strTmpSSHFile) + QString("<br>") + TmpSSHFile.errorString();
           return -1;
        }
        QByteArray byaryData = TmpSSHFile.readAll();
        TmpSSHFile.close();

        // Next, write contents.
        QFile SrcSSHFile(strSrcSSHFile);
        if(!SrcSSHFile.open(QIODevice::WriteOnly))
        {
            strErrMsg = tr("File open error : %1").arg(strSrcSSHFile) + QString("<br>") + SrcSSHFile.errorString();
            return -1;
        }
        SrcSSHFile.write(byaryData);
        SrcSSHFile.close();

        // Finally, set from source permission to destination sshd_config file.
        SrcSSHFile.setPermissions(strSrcSSHFile, SrcPermission);
    }
    catch (QException &err)
    {
        strErrMsg = err.what();
    }

    return 0;
}


int SSHConfigHelper::ExecuteSSHD(const QString strSSHDComandPath, const QStringList aryOptions, QString &strStdMsg, QString &strErrMsg)
{
    // message().service() is the service name of the caller.
    // Check if the caller is authorized to following action.
    PolkitQt1::Authority::Result result;
    PolkitQt1::SystemBusNameSubject subject(QDBusContext::message().service());

    result = PolkitQt1::Authority::instance()->checkAuthorizationSync("org.presire.sshconfig.server.ExecuteSSHD",
                                                                      subject, PolkitQt1::Authority::AllowUserInteraction);
    if (result == PolkitQt1::Authority::Yes)
    {   // Caller is authorized so we can perform the action

        // Check test mode.
        bool bTestOption = false;
        foreach(const auto &option, aryOptions)
        {
            if(option.contains(QRegExp("-t")))
            {   // If sshd command is test mode.
                bTestOption = true;
            }
        }

        // Execute sshd command, and then get output.
        QProcess Process;
        QObject::connect(&Process, static_cast<void(QProcess::*)(int, QProcess::ExitStatus)>(&QProcess::finished),
                         [&Process, &strStdMsg, &strErrMsg, bTestOption]([[maybe_unused]] int exitCode, [[maybe_unused]] QProcess::ExitStatus exitStatus)
                         {
                            strStdMsg  = QString::fromLocal8Bit(Process.readAllStandardError());
                            strStdMsg += QString::fromLocal8Bit(Process.readAllStandardOutput());

                            if(bTestOption && strStdMsg.isEmpty())
                            {
                                //strStdMsg = tr("Success.") + QString("\n") + tr("There is nothing wrong with sshd_config file.");
                            }
                        });
        Process.start(strSSHDComandPath, aryOptions);
        Process.waitForFinished();
    }
    else
    {   // Caller is not authorized so the action can't be performed.
        return 1;
    }

    return 0;
}


int SSHConfigHelper::ChangeAuthMode(bool bAuth, QString &strErrMsg)
{
    // message().service() is the service name of the caller.
    // Check if the caller is authorized to following action.
    PolkitQt1::Authority::Result result;
    PolkitQt1::SystemBusNameSubject subject(QDBusContext::message().service());

    result = PolkitQt1::Authority::instance()->checkAuthorizationSync("org.presire.sshconfig.server.ChangeAuthMode",
                                                                      subject, PolkitQt1::Authority::AllowUserInteraction);
    if (result == PolkitQt1::Authority::Yes)
    {   // Caller is authorized so we can perform the action
        return ChangeAuthValue(bAuth, strErrMsg);
    }
    else
    {   // Caller is not authorized so the action can't be performed
        return 1;
    }

    return 0;
}


int SSHConfigHelper::ChangeAuthValue(bool bAuth, QString &strErrMsg)
{
    // This action must be authorized.
    QDomDocument doc = QDomDocument("policy");
    QFile file("/usr/share/polkit-1/actions/org.presire.sshconfig.policy");

    if(!file.open(QIODevice::ReadOnly))
    {
        strErrMsg = tr("PolKit file could not be opened.");
        return -1;
    }

    doc.setContent(&file);
    file.close();

    // Change action auth "auth_admin" to "yes" in "org.presire.sshconfig.server.ReadSSHFile"
    QDomElement el = doc.firstChildElement("policyconfig").
                     firstChildElement("action");
    while (!el.isNull() && el.attribute("id", QString()) != "org.presire.sshconfig.server.ReadSSHFile")
    {
        el = el.nextSiblingElement("action");
    }

    el = el.firstChildElement("defaults");
    el = el.firstChildElement("allow_active");
    if(el.isNull())
    {
        strErrMsg = tr("PolKit action file is corrupt.");
        return -1;
    }

    bAuth ? el.firstChild().toText().setData("yes") : el.firstChild().toText().setData("auth_admin");

    // Change action auth "auth_admin" to "yes" in "org.presire.sshconfig.server.WriteSSHFile"
    el = doc.firstChildElement("policyconfig").firstChildElement("action");
    while (!el.isNull() && el.attribute("id", QString()) != "org.presire.sshconfig.server.WriteSSHFile")
    {
        el = el.nextSiblingElement("action");
    }

    el = el.firstChildElement("defaults");
    el = el.firstChildElement("allow_active");
    if(el.isNull())
    {
        strErrMsg = tr("PolKit action file is corrupt.");
        return -1;
    }

    bAuth ? el.firstChild().toText().setData("yes") : el.firstChild().toText().setData("auth_admin");

    // Change action auth "auth_admin" to "yes" in "org.presire.sshconfig.server.WriteSSHFile"
    el = doc.firstChildElement("policyconfig").firstChildElement("action");
    while (!el.isNull() && el.attribute("id", QString()) != "org.presire.sshconfig.server.ExecuteSSHD")
    {
        el = el.nextSiblingElement("action");
    }

    el = el.firstChildElement("defaults");
    el = el.firstChildElement("allow_active");
    if(el.isNull())
    {
        strErrMsg = tr("PolKit action file is corrupt.");
        return -1;
    }

    bAuth ? el.firstChild().toText().setData("yes") : el.firstChild().toText().setData("auth_admin");

    // Write the changed value.
    if(!file.open(QIODevice::WriteOnly))
    {
        strErrMsg = tr("Could not write to PolKit action file.");
        return -1;
    }

    QTextStream stream(&file);

    doc.save(stream, 2);
    file.close();

    return 0;
}
