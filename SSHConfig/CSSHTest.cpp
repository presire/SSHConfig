#include "CSSHTest.h"


CSSHTest::CSSHTest(QObject *parent) : QObject(parent)
{
}


// Execute sshd command on local computer.
int CSSHTest::executeSSHDCommand(QString strSSHDComandPath, const QString &strSSHFilePath, const int option)
{
    QStringList aryOptions = {};
    switch (option) {
        case 0:
            aryOptions.append({"-t", "-f", strSSHFilePath});
            break;
        case 1:
            aryOptions.append({"-T", "-f", strSSHFilePath});
            break;
        case 2:
            aryOptions.append({"-T", "-d", "-f", strSSHFilePath});
            break;
        case 3:
            aryOptions.append({"-T", "-d", "-d", "-d", "-f", strSSHFilePath});
            break;
        default:
            aryOptions.append({"-T", "-f", strSSHFilePath});
            break;
    }

    if(!QFile::exists(strSSHDComandPath))
    {
        m_strErrorMsg = tr("sshd command not exists.") + "<br>" + strSSHDComandPath;
        return -1;
    }

    if(!QFile::exists(strSSHFilePath))
    {
        m_strErrorMsg = tr("sshd_config not exists.") + "<br>" + strSSHFilePath;
        return -1;
    }

    // Execute sshd command with administrative privileges.
    auto iRet = executeSSHDCommandFromHelper(strSSHDComandPath, aryOptions, option);

    return iRet;
}


// Execute sshd command on local computer using D-Bus. (Send helper executable)
int CSSHTest::executeSSHDCommandFromHelper(const QString &strSSHDComandPath, const QStringList &aryOptions, const int option)
{
    // Execute sshd command with administrative privileges.
    QDBusConnection bus = QDBusConnection::systemBus();

    if (!bus.isConnected())
    {
        m_strErrorMsg = tr("Cannot connect to the D-Bus system bus.");
        return -1;
    }

    // this is our Special Action that after allowed will call the helper
    QDBusMessage message = QDBusMessage::createMethodCall("org.presire.sshconfig",
                                                          "/org/presire/sshconfig",
                                                          "org.presire.sshconfig.server", QLatin1String("ExecuteSSHD"));

    // If a method in a helper file has arguments, enter the arguments.
    QList<QVariant> ArgsToHelper;
    //ArgsToHelper << QVariant::fromValue(strSSHDComandPath) << QVariant::fromValue(strSSHFilePath) << QVariant::fromValue(QString(""));
    ArgsToHelper << QVariant::fromValue(strSSHDComandPath) << QVariant::fromValue(aryOptions);
    message.setArguments(ArgsToHelper);

    // Send a message to DBus. (Execute the helper file.)
    QDBusMessage reply = bus.call(message);

    // Receive the return value (including arguments) from the helper file.
    // The methods in the helper file have two arguments, so check them.
    if (reply.type() == QDBusMessage::ReplyMessage)
    {
        // Get return value from return parameter
        // the reply can be anything, here receive values.
        if (reply.arguments().at(0).toInt() == -1)
        {   // If the helper file method fails after successful authentication
            m_strErrorMsg = reply.arguments().at(2).toString();

            return -1;
        }
        else if(reply.arguments().at(0).toInt() == 1)
        {   // Cancel authentication.
            return 1;
        }

        // the reply can be anything, receive an Array (Out : a(sus)).
        // At this time, use QDBusArgument.
        //QDBusArgument argsReadContents = reply.arguments().at(1).value<QDBusArgument>();
        //<構造体名> strtReadContents;
        //reply.arguments().at(1).value<QDBusArgument>() >> strtReadContents;
        if(reply.arguments().at(0).toInt() == 0 && option == 0)
        {   // Success sshd command with test mode.
            m_strStdOutput = tr("Success.") + QString("\n") + tr("There is nothing wrong with sshd_config file.");
        }
        else
        {   // Success sshd command without test mode.
            m_strStdOutput = reply.arguments().at(2).toString() + reply.arguments().at(1).toString();
        }
    }
    else if (reply.type() == QDBusMessage::MethodCallMessage)
    {
        m_strErrorMsg = tr("Message did not receive a reply. (timeout by message bus)");

        return -1;
    }
    else if (reply.type() == QDBusMessage::ErrorMessage)
    {
        m_strErrorMsg = tr("Could not send message to D-Bus.");

        return -1;
    }

    return 0;
}


// Get result of sshd command from helper executable.
QString CSSHTest::getCommandResult()
{
    return m_strStdOutput;
}


// Download sshd_config file from remote server.
int CSSHTest::downloadSSHConfigFile(int width, int height, bool bDark, int fontPadding)
{
    if(m_clsRemote == nullptr)
    {
        m_clsRemote = std::make_unique<CRemoteWindow>(this);
        QObject::connect(m_clsRemote.get(), &CRemoteWindow::downloadSSHFile, this, &CSSHTest::downloadSSHFileFromServer);
        QObject::connect(m_clsRemote.get(), &CRemoteWindow::sendSSHDResult,  this, &CSSHTest::readSSHDResult);
    }

    m_clsRemote->GetSSHDConfigFile(width * 0.6, height * 0.6, bDark, fontPadding);

    return 0;
}


// Get path to sshd_config on remote server.
QString CSSHTest::getSSHConfigFilePath()
{
    if (m_clsRemote != nullptr)
    {
        return m_clsRemote->GetRemoteSSHFile();
    }

    return "";
}


// Execute sshd command.
int CSSHTest::executeRemoteSSHDCommand(QString strSSHDComandPath, QString strRemoteFilePath, int option)
{
    QStringList aryOptions = {};
    switch (option) {
        case 0:
            aryOptions.append({"-t", "-f", strRemoteFilePath});
            break;
        case 1:
            //aryOptions.append("-T");
            aryOptions.append({"-T", "-f", strRemoteFilePath});
            break;
        case 2:
            aryOptions.append({"-T", "-d", "-f", strRemoteFilePath});
            break;
        case 3:
            aryOptions.append({"-T", "-d", "-d", "-d", "-f", strRemoteFilePath});
            break;
        default:
            aryOptions.append({"-T", "-f", strRemoteFilePath});
            break;
    }

    auto strExecuteCommand = QString("sshd") + QString("\\\\//") + strSSHDComandPath + QString("\\\\//") + aryOptions.join("\\\\//");

    if (m_clsRemote == nullptr)
    {
        m_strErrorMsg = tr("No instance libRemoteWindow library.") + "<br>" +
                        tr("You may not have selected \"sshd_config\" file on remote server.");
        return -1;
    }

    auto iRet = m_clsRemote->ExecRemoteSSHDCommand(strExecuteCommand);
    if(iRet != 0)
    {
        m_strErrorMsg = m_clsRemote->GetErrorMessage();

        return -1;
    }

    return 0;
}


// Disconnect from remote server.
int CSSHTest::disconnectFromServer()
{
    if(m_clsRemote == nullptr)
    {
        m_strErrorMsg = tr("No instance libRemoteWindow library.") + "<br>" +
                        tr("You may not have selected \"sshd_config\" file on remote server.");
        return -1;
    }

    m_clsRemote->DisconnectFromServer();

    return 0;
}


// Get error message.
QString CSSHTest::getErrorMessage()
{
    return m_strErrorMsg;
}
