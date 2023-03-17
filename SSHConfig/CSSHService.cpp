#include "CSSHService.h"


// Marshall the MyStructure data into a D-Bus argument
QDBusArgument& operator<<(QDBusArgument &argument, const UnitProcesses &Units)
{
    argument.beginArray();

    foreach (auto Unit, Units)
    {
        argument.beginStructure();
        argument << Unit.ServiceName << Unit.JobNum << Unit.Command;
        argument.endStructure();
    }

    argument.endArray();

    return argument;
}

// Retrieve the MyStructure data from the D-Bus argument
const QDBusArgument& operator>>(const QDBusArgument &argument, UnitProcesses &Units)
{
    argument.beginArray();

    Units.clear();
    while (!argument.atEnd())
    {
        UnitProcess Unit = {};
        argument.beginStructure();
        argument >> Unit.ServiceName >> Unit.JobNum >> Unit.Command;
        argument.endStructure();
        Units.append(Unit);
    }

    argument.endArray();

    return argument;
}


CSSHService::CSSHService(QObject *parent) : QObject(parent)
{
    qRegisterMetaType<UnitProcesses>("UnitProcesses");
    qDBusRegisterMetaType<UnitProcesses>();

    QObject::connect(&m_Proc, &QProcess::readyReadStandardOutput, this, &CSSHService::UpdateOutput);
    QObject::connect(&m_Proc, &QProcess::readyReadStandardError, this, &CSSHService::UpdateError);
    QObject::connect(&m_Proc, static_cast<void(QProcess::*)(int, QProcess::ExitStatus)>(&QProcess::finished), this, &CSSHService::ProcessFinished);
}


CSSHService::~CSSHService()
{

}


int CSSHService::setSSHService(const QString strPropertyName)
{
    // Check SSH Service file.
    QString strServiceFile = "";
    if(CheckSSHService(strServiceFile))
    {
        return -1;
    }

    QDBusConnection bus = QDBusConnection::systemBus();
    if (!bus.isConnected())
    {
        m_strErrMsg = "Cannot connect to the D-Bus session bus.";
        return -1;
    }

    if (strPropertyName == "StopUnit")
    {
        QDBusMessage message = QDBusMessage::createMethodCall("org.freedesktop.systemd1",
                                                              "/org/freedesktop/systemd1",
                                                              "org.freedesktop.systemd1.Manager", QLatin1String("GetUnitProcesses"));

        // If a method in a D-Bus file has arguments, enter the arguments.
        QList<QVariant> ArgsToDBus;
        ArgsToDBus << QVariant::fromValue(strServiceFile);
        message.setArguments(ArgsToDBus);

        // Send a message to DBus.
        QDBusMessage replyStatus = bus.call(message);

        // Receive the return value (including arguments) from the D-Bus reply.
        // The methods have 1 argument(Array of Structure), so check them.
        if (replyStatus.type() == QDBusMessage::ReplyMessage)
        {
            // the reply can be anything, receive an Array of Structure (Out : a(sus)).
            // At this time, use QDBusArgument class.
            auto argUnitFiles = replyStatus.arguments().at(0).value<QDBusArgument>();

            UnitProcesses Units;

            // Get ssh(d).service status.
            //// Method 1: Use qdbus_cast
            Units = qdbus_cast<UnitProcesses>(argUnitFiles);

            //// Method 2: Override "operator>>" of QDBusArgument
            //replyStatus.arguments().at(0).value<QDBusArgument>() >> Units;

            // Get Job number of ssh(d).service.
            int iReply = Units.at(0).JobNum;
            if (iReply > 0)
            {
                message = QDBusMessage::createMethodCall("org.freedesktop.systemd1",
                                                         "/org/freedesktop/systemd1",
                                                         "org.freedesktop.systemd1.Manager", strPropertyName.toLatin1());

                // Method in a helper file has 1 argument, enter the argument.
                ArgsToDBus.clear();
                ArgsToDBus << QVariant::fromValue(strServiceFile) << QVariant::fromValue(QString("fail"));
                message.setArguments(ArgsToDBus);

                // Send a message to DBus.
                QDBusMessage reply = bus.call(message);
                if (reply.type() == QDBusMessage::ReplyMessage)
                {
                    auto strMsg2 = reply.arguments().at(0).data();
                    QString *pdata = (QString *)strMsg2;
                    QString strMsg = pdata->toUtf8().constData();
                    int JOBNum = strMsg.replace("/org/freedesktop/systemd1/job/", "", Qt::CaseSensitive).toUInt();
                    if (JOBNum <= 0)
                    {
                        return -1;
                    }
                }
                else
                {
                    return -1;
                }
            }
            else
            {
                return -1;
            }
        }
        else
        {
            return -1;
        }
    }
    else if(strPropertyName == "StartUnit")
    {
        QDBusMessage message = QDBusMessage::createMethodCall("org.freedesktop.systemd1",
                                                 "/org/freedesktop/systemd1",
                                                 "org.freedesktop.systemd1.Manager", strPropertyName.toLatin1());

        // Method in a helper file has 1 argument, enter the argument.
        QList<QVariant> ArgsToDBus;
        ArgsToDBus << QVariant::fromValue(strServiceFile) << QVariant::fromValue(QString("replace"));
        message.setArguments(ArgsToDBus);

        // Send a message to DBus.
        QDBusMessage reply = bus.call(message);
        if (reply.type() == QDBusMessage::ReplyMessage)
        {
            auto strMsg2 = reply.arguments().at(0).data();
            QString *pdata = (QString *)strMsg2;
            QString strMsg = pdata->toUtf8().constData();
            int JOBNum = strMsg.replace("/org/freedesktop/systemd1/job/", "", Qt::CaseSensitive).toUInt();
            if (JOBNum <= 0)
            {
                return -1;
            }
        }
        else
        {
            return -1;
        }
    }

    return 0;
}


// Check if SSH Service file exists
int CSSHService::CheckSSHService(QString &strSSHServiceFile)
{
    if(!QFile::exists("/usr/lib/systemd/system/sshd.service") && !QFile::exists("/etc/systemd/system/sshd.service"))
    {
        if(!QFile::exists("/usr/lib/systemd/system/ssh.service") && !QFile::exists("/etc/systemd/system/ssh.service"))
        {
            m_strErrMsg = tr("No such file SSH Service file.") + "\n" + tr("You may need to install openSSH.");
            return -1;
        }
        else
        {
            strSSHServiceFile = "ssh.service";
        }
    }
    else
    {
        strSSHServiceFile = "sshd.service";
    }

    return 0;
}


int CSSHService::getStateSSHService()
{
    // Check SSH Service file.
    QString strServiceFile = "";
    if(CheckSSHService(strServiceFile))
    {
        return -1;
    }

    QDBusConnection bus = QDBusConnection::systemBus();
    if (!bus.isConnected())
    {
        m_strErrMsg = "Cannot connect to the D-Bus system bus.";
        return -1;
    }

    QDBusMessage message = QDBusMessage::createMethodCall("org.freedesktop.systemd1",
                                                          "/org/freedesktop/systemd1",
                                                          "org.freedesktop.systemd1.Manager", QLatin1String("GetUnitProcesses"));

    // If a method in a D-Bus file has arguments, enter the arguments.
    QList<QVariant> ArgsToDBus;
    ArgsToDBus << QVariant::fromValue(strServiceFile);
    message.setArguments(ArgsToDBus);

    // Send a message to DBus.
    QDBusMessage replyStatus = bus.call(message);

    // Receive the return value (including arguments) from the D-Bus reply.
    // The methods have 1 argument, so check them.
    if (replyStatus.type() == QDBusMessage::ReplyMessage)
    {
        // the reply can be anything, receive an Array (Out : a(sus)).
        // At this time, use QDBusArgument.
        QDBusArgument argUnitFiles = replyStatus.arguments().at(0).value<QDBusArgument>();

        UnitProcesses Units;
        replyStatus.arguments().at(0).value<QDBusArgument>() >> Units;

        int iReply = Units.at(0).JobNum;
        if (iReply <= 0)
        {
            m_strErrMsg = tr("The D-Bus interface message was successfully sent and received,") +"\n"
                          + tr("but the SSH Service status could not be retrieved.");
            return -2;
        }
    }
    else
    {
        m_strErrMsg = tr("Failed to send or receive a message on the D-Bus interface.") + "\n\n"
                      + tr("D-Bus Interface :") + "\n" + "org.freedesktop.systemd1.Manager"
                      + tr("Property Name :")   + "\n" + "GetUnitProcesses";
        return -1;
    }

    return 0;
}


// スロット : 標準出力を取得
void CSSHService::UpdateOutput()
{
    // 標準出力を取得して文字列にする
    QByteArray output = m_Proc.readAllStandardOutput();
    QString str = QString::fromLocal8Bit(output);
}


// スロット : 標準エラー出力を取得
void CSSHService::UpdateError()
{
    // 標準エラー出力を取得して文字列にする
    QByteArray output = m_Proc.readAllStandardError();
    m_strErrMsg = QString::fromLocal8Bit(output);
}


// スロット : プロセス終了時
void CSSHService::ProcessFinished(int exitCode, QProcess::ExitStatus exitStatus)
{
    int code = 0;

    if(exitStatus == QProcess::CrashExit)
    {
        code = -1;
    }
    else if(exitCode != 0)
    {
        code = -2;
    }

    emit resultSSHService(code, m_strErrMsg);
}


// Set requiring administrator password to read/write sshd_config file.
int CSSHService::changeAdminPassword(bool bAdmin)
{
    QDBusConnection bus = QDBusConnection::systemBus();
    if (!bus.isConnected())
    {
        m_strErrMsg = "Cannot connect to the D-Bus system bus.";
        return -1;
    }

    // this is our Special Action that after allowed will call the helper
    QDBusMessage message = QDBusMessage::createMethodCall("org.presire.sshconfig",
                                                          "/org/presire/sshconfig",
                                                          "org.presire.sshconfig.server", QLatin1String("ChangeAuthMode"));

    // If a method in a D-Bus file has arguments, enter the arguments.
    QList<QVariant> ArgsToDBus;
    ArgsToDBus << QVariant::fromValue(bAdmin);
    message.setArguments(ArgsToDBus);

    // Send a message to DBus.
    QDBusMessage replyStatus = bus.call(message);

    // Receive the return value (including arguments) from the D-Bus reply.
    // The methods have 2 arguments, so check them.
    if (replyStatus.type() == QDBusMessage::ReplyMessage)
    {
        // Get the return value from the return parameter the reply can be anything.
        if (replyStatus.arguments().at(0).toInt() == -1)
        {   // If the helper file method fails after successful authentication.
            m_strErrMsg = replyStatus.arguments().at(1).toString();
            return -1;
        }
        else if(replyStatus.arguments().at(0).toInt() == 1)
        {
            return 1;
        }
    }
    else if(replyStatus.type() == QDBusMessage::MethodCallMessage)
    {
        m_strErrMsg = tr("Message did not receive a reply (timeout by message bus).") + "\n\n"
                      + tr("D-Bus Interface :") + "\n" + "org.presire.sshconfig.server"
                      + tr("Property Name :")   + "\n" + "ChangeAuthMode";
        return -1;
    }
    else if(replyStatus.type() == QDBusMessage::ErrorMessage)
    {
        m_strErrMsg = tr("Could not send message to D-Bus.")  + "\n\n"
                      + tr("D-Bus Interface :") + "\n" + "org.presire.sshconfig.server"
                      + tr("Property Name :")   + "\n" + "ChangeAuthMode";
        return -1;
    }
    else
    {
        m_strErrMsg = tr("Failed to send or receive a message on the D-Bus interface.") + "\n\n"
                      + tr("D-Bus Interface :") + "\n" + "org.presire.sshconfig.server"
                      + tr("Property Name :")   + "\n" + "ChangeAuthMode";
        return -1;
    }

    return 0;
}


// Execute on remote server.
int CSSHService::executeRemoteSSHService(int width, int height, bool bDark, int fontPadding, bool bActionFlag, bool bStatus)
{
//    if(m_clsRemote != nullptr)
//    {
//        QObject::disconnect(m_clsRemote.get(), &CRemoteWindow::sendStatus, this, &CSSHService::resultGetSSHStatusRemoteHost);
//        m_clsRemote.reset();
//    }

//    m_clsRemote = std::make_unique<CRemoteWindow>(this);
//    QObject::connect(m_clsRemote.get(), &CRemoteWindow::sendStatus, this, &CSSHService::resultGetSSHStatusRemoteHost);

    if(m_clsRemote == nullptr)
    {
        m_clsRemote = std::make_unique<CRemoteWindow>(this);
        QObject::connect(m_clsRemote.get(), &CRemoteWindow::sendStatus, this, &CSSHService::resultGetSSHStatusRemoteHost);
    }

    auto iRet = m_clsRemote->ExecRemoteSSHService(width * 0.6, height * 0.6, bDark, fontPadding, bActionFlag, bStatus);

    if(iRet != 0)
    {
        return -1;
    }

    return 0;
}


// Get message from remote server.
QString CSSHService::getCommandResult()
{
    return m_strStdOutput;
}


// Disconnect from remote server.
void CSSHService::disconnectFromServer()
{
    if(m_clsRemote != nullptr)
    {
        m_clsRemote->DisconnectFromServer();
    }

    return;
}


// Get error message.
QString CSSHService::getErrorMessage()
{
    return m_strErrMsg;
}
