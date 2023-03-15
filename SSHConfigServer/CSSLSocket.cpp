#include "CSSLSocket.h"


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


CSSLSocket::CSSLSocket(int SocketDescriptor, QSslSocket *parent) : QSslSocket(parent)
{
    qRegisterMetaType<UnitProcesses>("UnitProcesses");
    qDBusRegisterMetaType<UnitProcesses>();

    this->setSocketDescriptor(SocketDescriptor);

    m_CurrentDir = "/";
    m_pData      = std::make_unique<QByteArray>();
    m_pInt       = std::make_unique<qint32>();
    m_Buffers.insert(this, m_pData.get());
    m_Sizes.insert(this, m_pInt.get());
    m_Process    = std::make_unique<QProcess>(this);

    QObject::connect(this, &CSSLSocket::errorOccurred, this, &CSSLSocket::SocketErr);
}


CSSLSocket::~CSSLSocket()
{
    this->close();
    this->deleteLater();

    m_pData.reset();
    m_pInt.reset();

    m_Buffers.clear();
    m_Sizes.clear();
}


// Will be moved into the thread to run
void CSSLSocket::Read()
{
    // process the data
    CSSLSocket *pSocket = reinterpret_cast<CSSLSocket *>(sender());

    QByteArray *buffer = m_Buffers.value(pSocket);
    qint32 *s = m_Sizes.value(pSocket);
    qint32 size = *s;

    while(pSocket->bytesAvailable() > 0)
    {
        buffer->append(pSocket->readAll());
        while((size == 0 && buffer->size() >= 4) || (size > 0 && buffer->size() >= size)) //While can process data, process it
        {
            if(size == 0 && buffer->size() >= 4) //if size of data has received completely, then store it on our global variable
            {
                size = ArrayToInt(buffer->mid(0, 4));
                *s = size;
                buffer->remove(0, 4);
            }

            if(size > 0 && buffer->size() >= size) // If data has received completely, then emit our SIGNAL with the data
            {
                QByteArray data = buffer->mid(0, size);
                buffer->remove(0, size);
                size = 0;
                *s = size;

                QString strHostAddress = pSocket->QAbstractSocket::peerAddress().toString();
                Show(data, strHostAddress);
                Command(data);
            }
        }
    }
}


bool CSSLSocket::Send(const QByteArray &data)
{
    if(!data.isEmpty())
    {
        // Send size of data.
        this->write(IntToArray(data.size()));
        if(!this->waitForBytesWritten(5000))
        {
            return false;
        }

        this->write(data);
        if(!this->waitForBytesWritten(5000))
        {
            return false;
        }
    }

    return true;
}


void CSSLSocket::SocketErr(QAbstractSocket::SocketError socketError)
{
    CSSLSocket *pSocket = reinterpret_cast<CSSLSocket*>(sender());

    switch(socketError)
    {
        case QAbstractSocket::RemoteHostClosedError:
        {
            QString strHostAddress  = pSocket->QAbstractSocket::peerAddress().toString();
            QString strStateMessage = tr("Client [%1] disconnected").arg(strHostAddress) + QString("\n");
            QTextStream ts(stderr);
            ts << strStateMessage;
            ts.flush();

            break;
        }
        default:
        {
            QString strErrorMessage = tr("Error Name : %1").arg(socketError) + QString("\n") + pSocket->errorString() + QString("\n");
            QTextStream ts(stderr);
            ts << strErrorMessage;
            ts.flush();

            break;
        }
    }
}


// Convert integer to QByteArray.
QByteArray CSSLSocket::IntToArray(qint32 source) //Use qint32 to ensure that the number have 4 bytes
{
    //Avoid use of cast, this is the Qt way to serialize objects
    QByteArray temp = {};
    QDataStream data(&temp, QIODevice::ReadWrite);
    data << source;

    return temp;
}


qint32 CSSLSocket::ArrayToInt(QByteArray source)
{
    qint32 temp;
    QDataStream data(&source, QIODevice::ReadWrite);
    data >> temp;

    return temp;
}


int CSSLSocket::Command(const QByteArray &data)
{
    auto iCommandNumber = 0;

    auto strData = QString::fromUtf8(data);

    // If command has option, get option.
    QString     strDirOption      = "";     // For "dir" option.
    QString     strCommandPath    = "";     // For "sshd" options.
    QStringList arySSHDOptions    = {};     // For "sshd" options.
    bool        bTestOption       = false;  // For "sshd" options.
    QString     strUploadFile     = "";     // For "push" ooption.
    QString     strUploadContents = "";     // For "push" ooption.
    if(strData.leftRef(3) == "dir" || strData.leftRef(4) == "pull" || strData.left(6) == "reload" ||
       strData.left(3) == "key"    || strData.left(7) == "onlydir")
    {
        auto [iRet, Command, Option] = DirCommand(strData);
        if(iRet == -1)
        {
            QString strErrorMessage = QString("error") + QString("\\\\//") + Option;
            Send(strErrorMessage.toUtf8());
            return -1;
        }

        strData      = Command;
        strDirOption = Option;
    }
    else if(strData.leftRef(4) == "sshd")
    {
        auto [iRet, Command, CommandPath, bTest, Option] = SSHDCommand(strData);
        if(iRet == -1)
        {
            QString strErrorMessage = QString("error") + QString("\\\\//") + Option;
            Send(strErrorMessage.toUtf8());
            return -1;
        }

        strData        = Command;
        strCommandPath = CommandPath;
        arySSHDOptions = Option.split(QRegExp(" "), Qt::KeepEmptyParts);
        bTestOption    = bTest;
    }
    else if(strData.leftRef(4) == "push")
    {
        auto [iRet, Command, FilePath, Contents, ErrorMessage] = PushCommand(strData);
        if(iRet == -1)
        {
            QString strErrorMessage = QString(tr("error")) + QString("\\\\//") + ErrorMessage;
            Send(strErrorMessage.toUtf8());

            return -1;
        }

        strData           = Command;
        strUploadFile     = FilePath;
        strUploadContents = Contents;
    }

    if(strData.compare("dir", Qt::CaseSensitive) == 0)              iCommandNumber = 0;     // Search directories and sshd_config file.
    else if(strData.compare("pull", Qt::CaseSensitive) == 0)        iCommandNumber = 1;     // Download "sshd_config" file.
    else if(strData.compare("reload", Qt::CaseSensitive) == 0)      iCommandNumber = 2;     // Reload "sshd_config" file.
    else if(strData.compare("key", Qt::CaseSensitive) == 0)         iCommandNumber = 3;     // Serach Key files.
    else if(strData.compare("sshd", Qt::CaseSensitive) == 0)        iCommandNumber = 4;     // Execute "sshd" command.
    else if(strData.compare("sshstart", Qt::CaseSensitive) == 0)    iCommandNumber = 5;     // Start ssh(d).service.
    else if(strData.compare("sshrestart", Qt::CaseSensitive) == 0)  iCommandNumber = 6;     // Restart ssh(d).service.
    else if(strData.compare("sshstop", Qt::CaseSensitive) == 0)     iCommandNumber = 7;     // Stop ssh(d).service.
    else if(strData.compare("sshstatus", Qt::CaseSensitive) == 0)   iCommandNumber = 8;     // Get status ssh(d).service.
    else if(strData.compare("sshreload", Qt::CaseSensitive) == 0)   iCommandNumber = 9;     // Reload ssh(d).service.
    else if(strData.compare("onlydir", Qt::CaseSensitive) == 0)     iCommandNumber = 10;    // Search directories only.
    else if(strData.compare("push", Qt::CaseSensitive) == 0)        iCommandNumber = 11;    // Search directories only.
    else                                                            iCommandNumber = -1;    // Unknown command.

    if(iCommandNumber == 0)
    {   // Search directories and sshd_config file.
        QStringList aryDirs  = {};
        QStringList aryFiles = {};

        m_CurrentDir = strDirOption;

        QDir Dir(m_CurrentDir);

        // Get directories.
        QDir::SortFlags flags = QDir::IgnoreCase | QDir::Name;
        aryDirs               = Dir.entryList(QDir::Dirs | QDir::Hidden | QDir::NoDotAndDotDot |
                                              QDir::Readable | QDir::Writable | QDir::Executable, flags);

        // Get sshd_config file.
        auto aryFilesList = Dir.entryList({"sshd_config*"}, QDir::Files | QDir::Readable | QDir::Writable, flags);

        // Generating data to be sent.
        auto strData = QString("success") + QString("\\\\//") + aryDirs.join("\\\\//") + QString("\\@\\/@/") + aryFilesList.join("\\\\//");

        // Send directories and sshd_config file to client.
        Send(strData.toUtf8());
    }
    else if(iCommandNumber == 1 || iCommandNumber == 2)
    {   // Download(pull) or Re-download(reload) sshd_config file.
        try
        {
            QFile File(strDirOption);

            if(!File.open(QIODevice::ReadOnly))
            {
                auto strErrMsg = QString(tr("error")) + QString("\\\\//") + tr("File open error : %1").arg(strDirOption) + QString("<br>") + File.errorString();
                Send(strErrMsg.toUtf8());

                return -1;
            }

            QTextStream inStream(&File);

            // Set character encoding to UTF-8. (If UTF-8 is not specified, double-byte characters are garbled.)
            inStream.setCodec("UTF-8");

            auto strContents = inStream.readAll();

            File.close();

            // Send directories and sshd_config file to client.
            Send(strContents.toUtf8());
        }
        catch(QException &ex)
        {
            auto strErrMsg =  QString(tr("error")) + QString("\\\\//") + tr("File open error : %1").arg(strDirOption) + QString("<br>") + ex.what();
            Send(strErrMsg.toUtf8());

            return -1;
        }
    }
    else if(iCommandNumber == 3)
    {   // Search directories and get path to key file.
        QStringList aryDirs  = {};
        QStringList aryFiles = {};

        m_CurrentDir = strDirOption;

        QDir Dir(m_CurrentDir);

        // Get directories.
        QDir::SortFlags flags = QDir::IgnoreCase | QDir::Name;
        aryDirs               = Dir.entryList(QDir::Dirs | QDir::Hidden | QDir::NoDotAndDotDot |
                                              QDir::Readable | QDir::Writable | QDir::Executable, flags);

        // Get sshd_config file.
        auto aryFilesList = Dir.entryList(QDir::Files, flags);

        // Generating data to be sent.
        auto strData = QString("success") + QString("\\\\//") + aryDirs.join("\\\\//") + QString("\\@\\/@/") + aryFilesList.join("\\\\//");

        // Send directories and sshd_config file to client.
        Send(strData.toUtf8());
    }
    else if(iCommandNumber == 4)
    {   // Execute sshd command.
        QString strResult = "";
        QProcess Process;
        QObject::connect(&Process, static_cast<void(QProcess::*)(int, QProcess::ExitStatus)>(&QProcess::finished),
                         [&Process, &strResult, bTestOption]([[maybe_unused]] int exitCode, [[maybe_unused]] QProcess::ExitStatus exitStatus) {
                            strResult  = QString::fromLocal8Bit(Process.readAllStandardError());
                            strResult += QString::fromLocal8Bit(Process.readAllStandardOutput());

                            if(bTestOption && strResult.isEmpty())
                            {
                                strResult = tr("Success.") + QString("\n") + tr("There is nothing wrong with sshd_config file.");
                            }
                        });
        Process.start(strCommandPath, arySSHDOptions);
        Process.waitForFinished();

        // Send result of sshd command.
        Send(strResult.toUtf8());
    }
    else if(iCommandNumber == 5 || iCommandNumber == 6)
    {   // Restart ssh(d).service.
        auto iRet = ExecuteSSHService(true);
        if(iRet == 0)
        {   // ssh(d).service is running.
            Send("running");
        }
        else
        {   // Error.
            auto strErrMsg = QString(tr("error")) + QString("\\\\//") + tr("SSH service could not be started.");
            Send(strErrMsg.toUtf8());

            return -1;
        }
    }
    else if(iCommandNumber == 7)
    {   // Stop ssh(d).service.
        auto iRet = ExecuteSSHService(false);
        if(iRet == 0)
        {   // ssh(d).service is stop.
            Send("stop");
        }
        else
        {   // Error.
            auto strErrMsg = QString(tr("error")) + QString("\\\\//") + tr("SSH service could not be stopped.");
            Send(strErrMsg.toUtf8());

            return -1;
        }
    }
    else if(iCommandNumber == 8)
    {   // Get status ssh(d).service.
        auto iRet = GetStatusSSHService();
        if(iRet == 0)
        {   // ssh(d).service is running.
            Send("running");
        }
        else if(iRet == 1)
        {   // ssh(d).service is stop.
            Send("stop");
        }
        else
        {   // Error.
            auto strErrMsg = QString(tr("error")) + QString("\\\\//") + tr("Could not get SSH service status.");
            Send(strErrMsg.toUtf8());

            return -1;
        }
    }
    else if(iCommandNumber == 10)
    {   // Search directories only.
        QStringList aryDirs  = {};

        m_CurrentDir = strDirOption;

        QDir Dir(m_CurrentDir);

        // Get directories.
        QDir::SortFlags flags = QDir::IgnoreCase | QDir::Name;
        aryDirs               = Dir.entryList(QDir::Dirs | QDir::Hidden | QDir::NoDotAndDotDot |
                                              QDir::Readable | QDir::Writable | QDir::Executable, flags);

        // Generating data to be sent.
        auto strData = QString("success") + QString("\\\\//") + aryDirs.join("\\\\//");

        // Send directories and sshd_config file to client.
        Send(strData.toUtf8());
    }
    else if(iCommandNumber == 11)
    {   // Upload(push) sshd_config file.
        try
        {
            // Get permission of source sshd_config file.
            auto SrcPermission = QFile::permissions(strUploadFile);

            // Backup sshd_config file.
            QFileInfo FileInfo(strUploadFile);
            auto Current_Date_Time = QDateTime::currentDateTime();
            auto strDate           = Current_Date_Time.toString("_yyyyMMdd_hhmmss_zzz");
            auto SSHBackupFile     = FileInfo.absolutePath() + QDir::separator() + FileInfo.completeBaseName() + QString("_bak") + strDate;
            if(!QFile::rename(strUploadFile, SSHBackupFile))
            {
                auto strErrMsg = QString(tr("error")) + QString("\\\\//") + tr("File backup error : %1").arg(strUploadFile) + QString("<br>");
                Send(strErrMsg.toUtf8());

                return -1;
            }

            // Create sshd_config file.
            QFile SSHFile(strUploadFile);
            if(!SSHFile.open(QIODevice::WriteOnly))
            {
                auto strErrMsg = QString(tr("error")) + QString("\\\\//") + tr("File open error : %1").arg(strUploadFile) + QString("<br>") + SSHFile.errorString();
                Send(strErrMsg.toUtf8());

                return -1;
            }

            // Write sshd_config file.
            if(SSHFile.write(strUploadContents.toUtf8()) < 0)
            {
                auto strErrMsg = QString(tr("error")) + QString("\\\\//") + tr("File upload error : %1").arg(strUploadFile) + QString("<br>") + SSHFile.errorString();
                Send(strErrMsg.toUtf8());

                return -1;
            }

            SSHFile.close();

            // Finally, set permission sshd_config file.
            SSHFile.setPermissions(strUploadFile, SrcPermission);

            // Send success message to client.
            Send("success");
        }
        catch(QException &ex)
        {
            auto strErrMsg =  QString(tr("error")) + QString("\\\\//") + tr("File upload error : %1").arg(strUploadFile) + QString("<br>") + ex.what();
            Send(strErrMsg.toUtf8());

            return -1;
        }
    }
    else
    {
        auto strErrMsg = QString(tr("error")) + QString("\\\\//") + tr("Unknown command");
        Send(strErrMsg.toUtf8());

        return -1;
    }

    return 0;
}


// Get option for "dir", "pull", "reload", "key", "onlydir" command.
std::tuple<int, QString, QString> CSSLSocket::DirCommand(QString &strDirCommand)
{
    QString strCommand = "";
    QString strDirPath = "";

    // Check until blank character.
    for(auto i = 0; i < strDirCommand.length(); i++)
    {
        if(strDirCommand.at(i).isSpace())
        {   // Split command name and path to directory.
            strCommand = strDirCommand.mid(0, i);
            strDirPath = strDirCommand.mid(i + 1, strDirCommand.length() - i - 1);
            break;
        }
        else
        {
            continue;
        }
    }

    // Check enable command.
    if(!strCommand.contains(QRegExp("(dir|pull|reload|key|onlydir)")))
    {
        return std::make_tuple(-1, "", "Unknown command");
    }

    // Check exist directory.
    if(!QFile::exists(strDirPath))
    {
        return std::make_tuple(-1, "", "Unknown directory");
    }

    return std::make_tuple(0, strCommand, strDirPath);
}


// Get option for "sshd" command.
std::tuple<int, QString, QString, bool, QString> CSSLSocket::SSHDCommand(QString &strCommandCommand)
{
    auto aryData = strCommandCommand.split(" ", Qt::KeepEmptyParts);
    if(aryData.length() > 8)
    {
        return std::make_tuple(-1, "", "", false, "Unknown sshd command");
    }

    // Get server command.
    auto Command = aryData.at(0);
    if(Command.compare("sshd", Qt::CaseSensitive) != 0)
    {
        return std::make_tuple(-1, "", "", false, "Unknown sshd command");
    }

    aryData.removeAt(0);

    // Get path to sshd command.
    auto CommandPath = aryData.at(0);
    if(!QFile::exists(CommandPath))
    {
        return std::make_tuple(-1, "", "", false, QString(tr("No such sshd binary file : %1")).arg(CommandPath));
    }
    aryData.removeAt(0);

    // Get sshd command options.
    auto strSSHDOptions = aryData.join(" ");

    bool bTest = false;
    if(aryData.contains("-t", Qt::CaseSensitive))
    {
        bTest = true;
    }

    foreach(const auto &option, aryData)
    {
        if(!option.contains(QRegExp("(-t|-T|-d|-f)")))
        {   // sshd_config file to run sshd command.
            if(!QFile::exists(option))
            {
                return std::make_tuple(-1, "", "", false, QString(tr("No such file : %1")).arg(option));
            }
        }
    }

    return std::make_tuple(0, Command, CommandPath, bTest, strSSHDOptions);
}


// Return value:
//    0 : ssh(d).service is running.
//    1 : ssh(d).service is stop.
//    -1: Error.
int CSSLSocket::ExecuteSSHService(bool bStart)
{
    // Get ssh(d).service name.
    QString strSSHServiceFile = "";
    if(!QFile::exists("/usr/lib/systemd/system/sshd.service") && !QFile::exists("/etc/systemd/system/sshd.service"))
    {
        if(!QFile::exists("/usr/lib/systemd/system/ssh.service") && !QFile::exists("/etc/systemd/system/ssh.service"))
        {
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

    // Execute command.
    QDBusConnection bus = QDBusConnection::systemBus();
    if(!bus.isConnected())
    {
        return -1;
    }

    if(bStart == false)
    {
        QDBusMessage message = QDBusMessage::createMethodCall("org.freedesktop.systemd1",
                                                              "/org/freedesktop/systemd1",
                                                              "org.freedesktop.systemd1.Manager", QLatin1String("GetUnitProcesses"));

        // If a method in a D-Bus file has arguments, enter the arguments.
        QList<QVariant> ArgsToDBus;
        ArgsToDBus << QVariant::fromValue(strSSHServiceFile);
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
            if(iReply > 0)
            {
                message = QDBusMessage::createMethodCall("org.freedesktop.systemd1",
                                                         "/org/freedesktop/systemd1",
                                                         "org.freedesktop.systemd1.Manager", QLatin1String("StopUnit"));

                // Method in a helper file has 1 argument, enter the argument.
                ArgsToDBus.clear();
                ArgsToDBus << QVariant::fromValue(strSSHServiceFile) << QVariant::fromValue(QString("fail"));
                message.setArguments(ArgsToDBus);

                // Send a message to DBus.
                QDBusMessage reply = bus.call(message);
                if(reply.type() == QDBusMessage::ReplyMessage)
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
        }
        else
        {
            return -1;
        }
    }
    else
    {
        QDBusMessage message = QDBusMessage::createMethodCall("org.freedesktop.systemd1",
                                                              "/org/freedesktop/systemd1",
                                                              "org.freedesktop.systemd1.Manager", QLatin1String("StartUnit"));

        // Method in a helper file has 1 argument, enter the argument.
        QList<QVariant> ArgsToDBus;
        ArgsToDBus << QVariant::fromValue(strSSHServiceFile) << QVariant::fromValue(QString("replace"));
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

    // Check ssh(d).service state.
    auto iRet = GetStatusSSHService();
    if(iRet == -1)
    {
        return -1;
    }

    if(bStart)
    {
        if(iRet == 1) return -1;
    }
    else
    {
        if(iRet == 0) return -1;
    }

    return 0;
}


// Return value:
//    0 : ssh(d).service is running.
//    1 : ssh(d).service is stop.
//    -1: Error.
int CSSLSocket::GetStatusSSHService()
{
    // Get ssh(d).service name.
    QString strSSHServiceFile = "";
    if(!QFile::exists("/usr/lib/systemd/system/sshd.service") && !QFile::exists("/etc/systemd/system/sshd.service"))
    {
        if(!QFile::exists("/usr/lib/systemd/system/ssh.service") && !QFile::exists("/etc/systemd/system/ssh.service"))
        {
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

    // Check ssh(d).service state.
    QDBusConnection bus = QDBusConnection::systemBus();
    if (!bus.isConnected())
    {
        return -1;
    }

    QDBusMessage message = QDBusMessage::createMethodCall("org.freedesktop.systemd1",
                                                          "/org/freedesktop/systemd1",
                                                          "org.freedesktop.systemd1.Manager", QLatin1String("GetUnitProcesses"));

    // If a method in a D-Bus file has arguments, enter the arguments.
    QList<QVariant> ArgsToDBus;
    ArgsToDBus << QVariant::fromValue(strSSHServiceFile);
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
            return -1;
        }
    }
    else
    {
        return 1;
    }

    return 0;
}


// Get option for "push" command.
std::tuple<int, QString, QString, QString, QString> CSSLSocket::PushCommand(QString &strPushCommand)
{
    QString strConvertString = "";

    // Get command name.
    auto strCommand = strPushCommand.mid(0, 4);
    if(strCommand.compare("push", Qt::CaseSensitive) != 0)
    {
        return std::make_tuple(-1, "", "", "", tr("Unknown push command"));
    }
    else
    {
        strConvertString = strPushCommand.mid(4, strPushCommand.length() - 4);
    }

    // Remove leading blanks if any.
    for(auto i = 0; i < strConvertString.length(); i++)
    {
        if(strConvertString.at(i).isSpace())
        {
            continue;
        }
        else
        {
            strConvertString = strConvertString.mid(i, strConvertString.length() - i);
            break;
        }
    }

    // Get split characters. (\\\\//)
    if(strConvertString.mid(0, 4) != "\\\\//")
    {
        return std::make_tuple(-1, "", "", "", tr("Unknown push command"));
    }
    else
    {
        strConvertString = strConvertString.mid(4, strConvertString.length() - 4);
    }

    // Remove blanks if any.
    for(auto i = 0; i < strConvertString.length(); i++)
    {
        if(strConvertString.at(i).isSpace())
        {
            continue;
        }
        else
        {
            strConvertString = strConvertString.mid(i, strConvertString.length() - i);
            break;
        }
    }

    // Get split characters. (\\\\//)
    // Then, get path to sshd_config file.
    QString strSSHFile = "";
    for(auto i = 0; i < strConvertString.length(); i++)
    {
        if(strConvertString.mid(i, 4) != "\\\\//")
        {
            continue;
        }
        else
        {
            strSSHFile       = strConvertString.mid(0, i - 1);
            strConvertString = strConvertString.mid(i + 4, strConvertString.length() - i - 4);
            break;
        }
    }

    // Remove blanks if any.
    for(auto i = 0; i < strConvertString.length(); i++)
    {
        if(strConvertString.at(i).isSpace())
        {
            continue;
        }
        else
        {
            strConvertString = strConvertString.mid(i, strConvertString.length() - i);
            break;
        }
    }

    // Check sshd_config file.
    if(QFile::exists(strSSHFile) == false)
    {
        return std::make_tuple(-1, "", "", "", QString(tr("No such sshd_config file : %1")).arg(strSSHFile));
    }

    // Get sshd_config contents.
    auto strContents = strConvertString;

    return std::make_tuple(0, strCommand, strSSHFile, strContents, "");
}


void CSSLSocket::Show(QByteArray data, QString strHostAddress)
{
    QString strMessage = QString::fromUtf8(data) + QString(" from ") + strHostAddress + QString("\n");
    QTextStream ts(stderr);
    ts << strMessage;
    ts.flush();
}
