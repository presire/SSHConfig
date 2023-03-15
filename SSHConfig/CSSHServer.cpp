#include "CSSHServer.h"


//Q_DECLARE_METATYPE(QVariantList)

//// Marshall the User-definition-Structure data into a D-Bus argument
//QDBusArgument& operator<<(QDBusArgument &argument, const <構造体> &ReadContents)
//{
//    argument.beginArray();
//    foreach (auto Content, ReadContents)
//    {
//        QString a = Content.toString();
//        argument << a;
//    }
//    argument.endArray();

//    return argument;
//}


//// Retrieve the User-definition-Structure data from the D-Bus argument
//const QDBusArgument& operator>>(const QDBusArgument &argument, <構造体> &ReadContents)
//{
//    argument.beginArray();
//    ReadContents.clear();
//    while(!argument.atEnd())
//    {
//        QString Content;
//        argument >> Content;
//        ReadContents.append(Content);
//    }
//    argument.endArray();

//    return argument;
//}


CSSHServer::CSSHServer(QObject *parent) : QObject(parent)
{
    //qRegisterMetaType<<構造体>>("<構造体>");

    m_UserName = qgetenv("USER");
    m_HomePath = QDir::homePath();
    m_strIniFilePath = m_HomePath + QDir::separator() + ".config" + QDir::separator() + "SSHConfig" + QDir::separator() + "settings.ini";

    QObject::connect(&m_Proc, &QProcess::readyReadStandardOutput, this, &CSSHServer::UpdateOutput);
    QObject::connect(&m_Proc, &QProcess::readyReadStandardError, this, &CSSHServer::UpdateError);
    QObject::connect(&m_Proc, static_cast<void(QProcess::*)(int, QProcess::ExitStatus)>(&QProcess::finished), this, &CSSHServer::ProcessFinished);
}


// Get path to sshd_config file in ini file.
QString CSSHServer::getSSHFilePath()
{
    QString strSSHDPath = "";

    QSettings settings(m_strIniFilePath, QSettings::IniFormat, this);

    settings.beginGroup("SSHServer");

    if(settings.contains("SSHFilePath"))
    {
        strSSHDPath = settings.value("SSHFilePath").toString();
    }
    else
    {
        strSSHDPath = "/etc/ssh/sshd_config";
    }

    if(!QFile::exists(strSSHDPath))
    {
        strSSHDPath = "";
    }

    settings.endGroup();

    return strSSHDPath;
}


// Save successfully loaded sshd_config file in ini file.
int CSSHServer::saveSSHFilePath(const QString &strSSHDPath)
{
    int iRet = 0;

    try
    {
        QSettings settings(m_strIniFilePath, QSettings::IniFormat, this);

        settings.beginGroup("SSHServer");

        settings.setValue("SSHFilePath", strSSHDPath);

        settings.endGroup();
    }
    catch (QException *ex)
    {
        iRet = -1;
    }

    return iRet;
}


// Get read permission for sshd_config file.
int CSSHServer::getFileReadPermissions(const QString &strSSHPath)
{
    QFileInfo FileInfo(strSSHPath);
    if(FileInfo.exists())
    {
        // Get running software user's group ID.
        startProcess("id", QStringList({"-g"}));

        auto permission = FileInfo.permissions();
        if(m_UserName == FileInfo.owner())
        {   // If the owner of the sshd_config file and the user running this executable are the same
            if((permission & QFileDevice::Permission::ReadUser) == QFileDevice::Permission::ReadUser)
            {   // If the executing user has read permission to the ssd_config file
                return 0;
            }
        }
        else if(m_GroupID == FileInfo.groupId())
        {   // If the group of the sshd_config file and the user's group running this executable are the same
            if((permission & QFileDevice::Permission::ReadGroup) == QFileDevice::Permission::ReadGroup)
            {   // If the executing user has read permission to the ssd_config file
                return 0;
            }
        }
        else
        {
            if((permission & QFileDevice::Permission::ReadOther) == QFileDevice::Permission::ReadOther)
            {   // If the executing user has read permission to the ssd_config file
                return 0;
            }
        }
    }
    else
    {   // If the file does not exist.
        m_strErrMsg = tr("No such file, sshd_config.") + "\n" + strSSHPath;

        return -2;
    }

    // If you do not have read permission.
    return -1;
}


// Get write permission for sshd_config file.
int CSSHServer::getFileWritePermissions(const QString &strSSHPath)
{
    QFileInfo FileInfo(strSSHPath);
    if(FileInfo.exists())
    {
        // Get running software user's group ID.
        startProcess("id", QStringList({"-g"}));

        auto permission = FileInfo.permissions();
        if(m_UserName == FileInfo.owner())
        {   // If the owner of the sshd_config file and the user running this executable are the same
            if((permission & QFileDevice::Permission::WriteUser) == QFileDevice::Permission::WriteUser)
            {   // If the executing user has Write permission to the ssd_config file
                return 0;
            }
        }
        else if(m_GroupID == FileInfo.groupId())
        {   // If the group of the sshd_config file and the user's group running this executable are the same
            if((permission & QFileDevice::Permission::WriteGroup) == QFileDevice::Permission::WriteGroup)
            {   // If the executing user has Write permission to the ssd_config file
                return 0;
            }
        }
        else
        {
            if((permission & QFileDevice::Permission::WriteOther) == QFileDevice::Permission::WriteOther)
            {   // If the executing user has Write permission to the ssd_config file
                return 0;
            }
        }
    }
    else
    {   // If the file does not exist.
        m_strErrMsg = tr("No such file, sshd_config.") + "\n" + strSSHPath;

        return -2;
    }

    // If you do not have read permission.
    return -1;
}


// Execute an external process.
void CSSHServer::startProcess(QString Execute, QStringList Args)
{
    // Start an external process.
    m_Proc.start(Execute, Args);

    // Wait for the external process to terminate.
    m_Proc.waitForFinished();
}


// Slot : Get Standard Output
void CSSHServer::UpdateOutput()
{
   // 標準出力を取得して文字列にする
   QByteArray output = m_Proc.readAllStandardOutput();
   m_GroupID = QString::fromLocal8Bit(output).toUInt();
}


// Slot : Get Standard Error Output
void CSSHServer::UpdateError()
{
   // 標準エラー出力を取得して文字列にする
   QByteArray output = m_Proc.readAllStandardError();
   m_strErrMsg = QString::fromLocal8Bit(output);
}


// Slot : When Process end
void CSSHServer::ProcessFinished(int exitCode, QProcess::ExitStatus exitStatus)
{
   if(exitStatus == QProcess::CrashExit)
   {
       emit resultProcess(-1, m_strErrMsg);
   }
   else if(exitCode != 0)
   {
       emit resultProcess(-2, m_strErrMsg);
   }
   else
   {   // Success
       emit resultProcess(0, "");
   }
}


int CSSHServer::readSSHFile(const QString strFilePath)
{
    // Check sshd_config file exist.
    if(!QFile::exists(strFilePath))
    {
        m_strErrMsg = tr("No such file %1.").arg(strFilePath);
        return -1;
    }

    // Get ssh(d).service file's read permission.
    // Next, read ssh(d).service file.
    int iRet = 0;
    QString strContents = "";
    if(getFileReadPermissions(strFilePath) == 0)
    {   // If the user executing the software has read permission to the "sshd_config" file
        // Create Temporary sshd_config file local only.
        try
        {
            QFile File(strFilePath);

            if(!File.open(QIODevice::ReadOnly))
            {
                m_strErrMsg = tr("File open error %1.").arg(strFilePath) + QString("<br>") + File.errorString();
                return -1;
            }

            QTextStream inStream(&File);
            strContents = inStream.readAll();

            File.close();
        }
        catch(QException &ex)
        {
            m_strErrMsg = ex.what();
            return -1;
        }

        // Convert sshd_config's contents to Json file.
        // Return value  0 : Success
        //              -1 : Fail
        //               2 : Warning (Multiple identical items are described)
        iRet = ReadSSHValues(strContents);
        if(iRet == -1)
        {
            return -1;
        }

        // Create temporary sshd_config file and Json file.
        if(CreateTmpConfigFile(strContents))
        {
            return -1;
        }
    }
    else
    {   // If the user executing the software does not have read permission to the "sshd_config" file
        QDBusConnection bus = QDBusConnection::systemBus();

        if (!bus.isConnected())
        {
            m_strErrMsg = tr("Cannot connect to the D-Bus system bus.");
            return -1;
        }

        // this is our Special Action that after allowed will call the helper
        QDBusMessage message = QDBusMessage::createMethodCall("org.presire.sshconfig",
                                                              "/org/presire/sshconfig",
                                                              "org.presire.sshconfig.server", QLatin1String("ReadSSHFile"));

        // If a method in a helper file has arguments, enter the arguments.
        QList<QVariant> ArgsToHelper;
        ArgsToHelper << QVariant::fromValue(strFilePath);
        message.setArguments(ArgsToHelper);

        // Send a message to DBus. (Execute the helper file.)
        QDBusMessage reply = bus.call(message);

        // Receive the return value (including arguments) from the helper file.
        // The methods in the helper file have two arguments, so check them.
        if (reply.type() == QDBusMessage::ReplyMessage)
        {
            //Get the return value from the return parameter
            // the reply can be anything, here we receive a bool
            if (reply.arguments().at(0).toInt() == -1)
            {   // If the helper file method fails after successful authentication
                m_strErrMsg = reply.arguments().at(2).toString();
                return -1;
            }
            else if(reply.arguments().at(0).toInt() == 1)
            {
                return 1;
            }

            // the reply can be anything, receive an Array (Out : a(sus)).
            // At this time, use QDBusArgument.
            //QDBusArgument argsReadContents = reply.arguments().at(1).value<QDBusArgument>();
            //<構造体名> strtReadContents;
            //reply.arguments().at(1).value<QDBusArgument>() >> strtReadContents;
            strContents = reply.arguments().at(1).toString();

            // Convert sshd_config's contents to Json file.
            // Return value  0 : Success
            //              -1 : Fail
            //               2 : Warning (Multiple identical items are described)
            iRet = ReadSSHValues(strContents);
            if(iRet == -1)
            {
                return -1;
            }

            // Create temporary sshd_config file and Json file.
            if(CreateTmpConfigFile(strContents))
            {
                return -1;
            }
        }
        else if (reply.type() == QDBusMessage::MethodCallMessage)
        {
            m_strErrMsg = tr("Message did not receive a reply (timeout by message bus).");
            return -1;
        }
        else if (reply.type() == QDBusMessage::ErrorMessage)
        {
            m_strErrMsg = tr("Could not send message to D-Bus.");
            return -1;
        }
    }

    return iRet;
}


int CSSHServer::readSSHFileFromServer(const QString strContents)
{
    // Convert sshd_config's contents to Json file.
    // Convert sshd_config's contents to Json file.
    // Return value  0 : Success
    //              -1 : Fail
    //               2 : Warning (Multiple identical items are described)
    auto iRet = ReadSSHValues(strContents);
    if(iRet == -1)
    {
        return -1;
    }

    // Create temporary sshd_config file and Json file.
    if(CreateTmpConfigFile(strContents))
    {
        return -1;
    }

    return iRet;
}


// Create Temporary sshd_config file.
int CSSHServer::CreateTmpConfigFile(QString strContents)
{
    // Specify the full path of the sshd_config file to be created temporarily.
    auto Current_Date_Time = QDateTime::currentDateTime();
    auto strDate           = Current_Date_Time.toString("_yyyyMMdd_hhmmss_zzz");
    auto strTmpSSHDPath    = m_HomePath + QDir::separator() + ".config" + QDir::separator() + "SSHConfig" + QDir::separator() +
                             "sshd_config" + strDate;

    // Specify the full path of the Json file to be created.
    auto strJsonFilePath   = m_HomePath + QDir::separator() + ".config" + QDir::separator() + "SSHConfig" + QDir::separator() + "ServerOptions" +
                             strDate +".json";

    try
    {
        QFile TmpSSHDFile(strTmpSSHDPath);

        // Open file.
        if(!TmpSSHDFile.open(QIODevice::WriteOnly | QIODevice::Text))
        {
            m_strErrMsg = tr("Creation of temporary sshd_config file failed.");
            return -1;
        }

        // Write file.
        TmpSSHDFile.write(strContents.toUtf8().constData());

        // Close file.
        TmpSSHDFile.close();

        QFile JsonFile(strJsonFilePath);
        if(!JsonFile.open(QIODevice::WriteOnly | QIODevice::Text))
        {
            m_strErrMsg = tr("Failed to write temporary sshd_config file (Json file).");
            return -1;
        }

        // Save Json file from QJsonObject to text.
        JsonFile.write(QJsonDocument(m_NewRoot).toJson());

        // Close file.
        JsonFile.close();

        // Remove old sshd_config file and Json file.
        if(QFile::exists(m_strTmpSSHPath))  QFile::remove(m_strTmpSSHPath);
        if(QFile::exists(m_strJsonFilePath)) QFile::remove(m_strJsonFilePath);

        m_OldRoot.empty();
    }
    catch(QException &ex)
    {
        m_NewRoot = m_OldRoot;
        m_OldRoot.empty();

        if(QFile::exists(strTmpSSHDPath))  QFile::remove(strTmpSSHDPath);
        if(QFile::exists(strJsonFilePath)) QFile::remove(strJsonFilePath);

        m_strErrMsg = tr("Creation of temporary sshd_config file failed.") + QString("<br>") + ex.what();
        return -1;
    }

    // Set sshd_config file contents.
    m_strContents = strContents;

    // Set temporary sshd_config file path.
    m_strTmpSSHPath  = strTmpSSHDPath;

    // Set temporary Json file path.
    m_strJsonFilePath = strJsonFilePath;

    return 0;
}


// Read valid settings from the sshd_config file.
int CSSHServer::ReadSSHValues(const QString &strContents)
{
    int iRet = 0;
    ServerObjects aryServerOptions = {};

    try
    {
        QStringList aryContents = strContents.split("\n");
        //std::move(m_aryContents.begin(), m_aryContents.end(), std::back_inserter(aryLines));

        int iLine = 0;                                    // Line number.
        QMap<QString, QStringList> mapValues       = {};  // Save item value(s).
        QMap<QString, QList<int>>  mapLines        = {};  // Save item line(s).
        QMap<QString, QList<int>>  mapCommentLines = {};  // Save item comment line(s).

        // Get enable items.
        foreach (auto strLine, aryContents)
        {
            iLine++;

            // Skip line breaks.
            if(strLine.length() == 0)
            {
                continue;
            }

            // Remove leading blanks if any.
            QString strConvertString = "";
            for(auto i = 0; i < strLine.length(); i++)
            {
                if(strLine.at(i).isSpace())
                {
                    continue;
                }
                else
                {
                    strConvertString = strLine.mid(i, strLine.length() - i);
                    break;
                }
            }

            // Replace tab characters to a space.
            strConvertString = strConvertString.replace("\t", " ");

            // Check commented line.
            QString strKey          = "";
            QStringList aryValues   = {};

            if(strConvertString.at(0) == "#")
            {   // If comment line.
                continue;
            }
            else
            {   // If non-comment line.
                // Check comment line.
                auto [Key, Values] = CheckEnableLine(strConvertString);

                strKey      = Key;
                aryValues   = Values;
            }

            // Get valid items and values.
            // If a key with the same name is described in multiple lines,
            // set it as a single key.
            if(mapValues.contains(strKey))
            {
                if(m_aryMultipleItems.contains(strKey))
                {
                    // Set existing an item and its values.
                    auto aryAddTempValues =  mapValues.value(strKey);
                    aryAddTempValues      += aryValues;
                    mapValues.insert(strKey, aryAddTempValues);
                }

                // Set existing its item's line.
                auto aryAddTempLines =  mapLines.value(strKey);
                aryAddTempLines      += iLine;
                mapLines.insert(strKey, aryAddTempLines);
            }
            else
            {
                // Set new an item and its values.
                mapValues.insert(strKey, aryValues);

                // Set new its item's line.
                mapLines.insert(strKey, {iLine});
            }
        }

        // Get comment items.
        iLine = 0;
        foreach (auto strLine, aryContents)
        {
            iLine++;

            // Skip line breaks.
            if(strLine.length() == 0)
            {
                continue;
            }

            // Remove leading blanks if any.
            QString strConvertString = "";
            for(auto i = 0; i < strLine.length(); i++)
            {
                if(strLine.at(i).isSpace())
                {
                    continue;
                }
                else
                {
                    strConvertString = strLine.mid(i, strLine.length() - i);
                    break;
                }
            }

            // Replace tab characters to a space.
            strConvertString = strConvertString.replace("\t", " ");

            // Check commented line.
            QString     strKey      = "";
            QStringList aryValues   = {};

            if(strConvertString.at(0) == "#")
            {   // If comment line.

                // Check comment line.
                auto [iRet, Key, Values] = CheckCommentLine(strConvertString);

                if(mapValues.contains(Key))
                {
                    auto aryAddTempLines =  mapCommentLines.value(Key);
                    aryAddTempLines      += iLine;
                    mapCommentLines.insert(Key, aryAddTempLines);

                    continue;
                }

                if(iRet == 0)
                {
                    strKey      = Key;
                    aryValues   = Values;
                }
                else
                {
                    continue;
                }
            }
            else
            {   // If non-comment line.
                continue;
            }

            // Set new commented item and its values.
            mapValues.insert(strKey, aryValues);

            // Set new commented item's line.
            mapCommentLines.insert(strKey, {iLine});
        }

        // Get items and default values that are not exist in "sshd_config" file.
        SetNonExistItems(mapValues, mapCommentLines);

        // Disable deprecated items according to conditions.
        CheckDeprecatedItem(mapValues, mapLines, mapCommentLines);

        // Convert to "ServerObject" structure.
        // Set values to the structure written in the Json file.
        bool bfirstDuplicate = false;
        QMapIterator<QString, QStringList> itMapValues(mapValues);
        while(itMapValues.hasNext())
        {
            itMapValues.next();

            // Check for the presence of multiple values for non-duplicable items.
            // If there are duplicate non-duplicate items, comment all of them.
            bool bDuplicate = false;
            auto strKey = itMapValues.key();

            // Check multiple same name items.
            if(!m_aryMultipleItems.contains(strKey, Qt::CaseInsensitive))
            {
                // Multiple same name items are not allowed.
                if(mapLines.value(strKey).count() > 1)
                {   // If duplicate items exist.
                    QStringList aryLines = {};
                    foreach(const auto Line, mapLines.value(strKey))
                    {
                        aryLines << QString::number(Line);
                    }

                    // Get only valid values.
                    if(!m_MapMultipleValues.contains(strKey))
                    {
                        auto aryItemValues = itMapValues.value();
                        aryItemValues      = QStringList{aryItemValues.at(0)};
                        mapValues[strKey]  = aryItemValues;
                    }
                    else
                    {   // "RekeyLimit" and "AuthorizedKeysFile" items will be here.
                        auto iNum = m_MapMultipleValues.value(strKey);
                        if(iNum > 0)
                        {   // If multiple values of item are a finite number.
                            auto aryItemValues = itMapValues.value();
                            aryItemValues      = QStringList{aryItemValues.mid(0, iNum)};
                            mapValues[strKey]  = aryItemValues;
                        }
                    }

                    if(!bfirstDuplicate)
                    {
                        m_strErrMsg = "<br>" + tr("Duplicate items are shown below.") + "<br>" +
                                      tr("For these items, first line value is valid, next line value is commented when saved.") + "<br><br>" +
                                      QString(tr("<u><b>%1</b></u> :<br>Line: %2<br><br>")).arg(strKey, aryLines.join(", "));

                        bfirstDuplicate = true;
                    }
                    else
                    {
                        m_strErrMsg += QString(tr("<u><b>%1</b></u> :<br>Line: %2<br><br>")).arg(strKey, aryLines.join(", "));
                    }

                    bDuplicate = true;
                }
            }

            ServerObject ServerOption = {strKey, mapValues[strKey], mapLines.value(strKey), mapCommentLines.value(strKey), bDuplicate};
            aryServerOptions.append(ServerOption);
        }

        iRet = bfirstDuplicate ? 2 : 0;
    }
    catch(QException &ex)
    {
        m_strErrMsg = ex.what();
        return -1;
    }

    // Set to Json file.
    if(SetToJson(aryServerOptions))
    {
        iRet = -1;
    }

    return iRet;
}


std::tuple<QString, QStringList> CSSHServer::CheckEnableLine(const QString &strLine)
{
    QString     strItem         = "";
    QStringList aryValues       = {};

    auto strConvertString = strLine;

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

    // Remove all strings after #.
    auto index = strConvertString.indexOf("#", 0, Qt::CaseSensitive);
    strConvertString = strConvertString.mid(0, index);

    // Get Key.
    QString strKey = "";
    for(auto i = 0; i < strConvertString.length(); i++)
    {
        if(!strConvertString.at(i).isSpace())
        {
            continue;
        }
        else
        {
            strKey           = strConvertString.mid(0, i).toUpper();
            strConvertString = strConvertString.mid(i, strConvertString.length() - i);
            break;
        }
    }

    // Get value(s).
    // However, trim whitespace because it is useless.
    int         iRemoveCount = 0;
    QStringList aryItemValues = strConvertString.split(" ", Qt::SkipEmptyParts);
    for(auto i = 0; i < aryItemValues.count(); i++)
    {
        if(aryItemValues.at(i) == " ")
        {
            aryItemValues.removeAt(i - iRemoveCount);
            iRemoveCount++;
        }
    }

    strItem   = strKey;
    aryValues = aryItemValues;

    return {strItem, aryValues};
}


std::tuple<int, QString, QStringList> CSSHServer::CheckCommentLine(const QString &strLine)
{
    int         iRet            = 0;
    QString     strItem         = "";
    QStringList aryValues       = {};

    // Remove comment(#).
    auto strConvertString = strLine.mid(1, strLine.length() - 1);

    // If character following "#" character is blank,
    // it is considered to be a comment.
    if(strConvertString.at(0).isSpace())
    {
        return {-1, "", {}};
    }

    // Remove all strings after #.
    auto index = strConvertString.indexOf("#", 0, Qt::CaseSensitive);
    strConvertString = strConvertString.mid(0, index);

    // Get Key.
    QString strKey = "";
    for(auto i = 0; i < strConvertString.length(); i++)
    {
        if(!strConvertString.at(i).isSpace())
        {
            continue;
        }
        else
        {
            strKey           = strConvertString.mid(0, i).toUpper();
            strConvertString = strConvertString.mid(i, strConvertString.length() - i);
            break;
        }
    }

    // Get value(s).
    // However, trim whitespace because it is useless.
    int         iRemoveCount = 0;
    QStringList aryItemValues = strConvertString.split(" ", Qt::SkipEmptyParts);
    for(auto i = 0; i < aryItemValues.count(); i++)
    {
        if(aryItemValues.at(i) == " ")
        {
            aryItemValues.removeAt(i - iRemoveCount);
            iRemoveCount++;
        }
    }

    // Check enable key.
    if(m_MapDefaultValues.contains(strKey))
    {   // Enable key.

        // Check its item's value(s) number.
        auto iDefaultValuesCount = m_MapMultipleValues.contains(strKey) ? m_MapMultipleValues.value(strKey) : 1;
        if(aryItemValues.count() == iDefaultValuesCount || iDefaultValuesCount == -1)
        {   // Get its item's dafault value or multiple default values.
            strItem   = strKey;
            aryValues = m_MapDefaultValues.value(strKey);
        }
        else
        {   // Not key or invalid value(s).
            iRet = -1;
        }
    }
    else
    {   // Not key.
        // Get its item's dafault value or multiple default values.
        iRet = -1;
    }

    return {iRet, strItem, aryValues};
}


// Get items and default values that are not exist in "sshd_config" file.
void CSSHServer::SetNonExistItems(QMap<QString, QStringList> &mapValues, QMap<QString, QList<int>> &mapLines)
{
    QMapIterator<QString, QStringList> itMapValues(m_MapDefaultValues);
    while(itMapValues.hasNext())
    {
        itMapValues.next();

        // Check for the presence of multiple values for non-duplicable items.
        // If there are duplicate non-duplicate items, comment all of them.
        auto strKey = itMapValues.key();
        if(!mapValues.contains(strKey))
        {   // If non-exist item in sshd_config file.
            mapValues.insert(itMapValues.key(), itMapValues.value());
            mapLines.insert(itMapValues.key(), {-1});
        }
    }

    return;
}


// Disable deprecated items according to conditions.
void CSSHServer::CheckDeprecatedItem(QMap<QString, QStringList> &mapValues, QMap<QString, QList<int>> &mapLines, QMap<QString, QList<int>> &mapCommentLines)
{
    // "ChallengeResponseAuthentication" or "KbdInteractiveAuthentication".
    // "ChallengeResponseAuthentication" is deprecated alias for "KbdInteractiveAuthentication".
    auto bChallengResponse = false;
    if(mapLines.contains("CHALLENGERESPONSEAUTHENTICATION"))
    {
        bChallengResponse = mapLines.value("CHALLENGERESPONSEAUTHENTICATION").count() > 0 ? true : false;
    }

    auto bKBDInteractive = false;
    if(mapLines.contains("KBDINTERACTIVEAUTHENTICATION"))
    {
        bKBDInteractive = true;
    }

    if(bChallengResponse == false)
    {   // If "CHALLENGERESPONSEAUTHENTICATION" items non-exist or commented.
        // "KBDINTERACTIVEAUTHENTICATION" is preferred.
        mapValues.remove("CHALLENGERESPONSEAUTHENTICATION");
        mapLines.remove("CHALLENGERESPONSEAUTHENTICATION");
        mapCommentLines.remove("CHALLENGERESPONSEAUTHENTICATION");
    }
    else if(bChallengResponse && bKBDInteractive == false)
    {   // If "CHALLENGERESPONSEAUTHENTICATION" item is enable, and "KBDINTERACTIVEAUTHENTICATION" item is non-exist.
        mapValues.remove("KBDINTERACTIVEAUTHENTICATION");
        mapLines.remove("KBDINTERACTIVEAUTHENTICATION");
        mapCommentLines.remove("KBDINTERACTIVEAUTHENTICATION");
    }
    else if(bChallengResponse && bKBDInteractive)
    {   // If both items exist, NOP.
        // This is because "CHALLENGERESPONSEAUTHENTICATION" is necessary to comment.
    }

    return;
}


// Check for the presence of multiple values for non-duplicable items.
int CSSHServer::CheckDuplication(ServerObjects &ServerOptions)
{
    auto iRet  = 0;
    int  index = 0;
    QList<int> aryErrorIndexes = {};

    foreach (auto ServerOption, ServerOptions)
    {
        auto strKey = ServerOption.Key;
        if(!m_aryMultipleItems.contains(strKey, Qt::CaseInsensitive))
        {
            if(ServerOption.Values.count() > 1)
            {   // If duplicate items exist.
                aryErrorIndexes.append(index);

                if(iRet == 0)
                {
                    m_strErrMsg = "<br>" + tr("Duplicate items are shown below.") + "<br>" +
                                  tr("Values set for these items are ignored, and commented when saving.") + "<br><br>" +
                                  QString("<u><b>%1 :</b></u><br>%2<br><br>").arg(strKey, ServerOption.Values.join(", "));
                    iRet = -1;
                }
                else
                {
                    m_strErrMsg += QString("<u><b>%1 :</b></u><br>%2<br><br>").arg(strKey, ServerOption.Values.join(", "));
                }
            }
        }

        index++;
    }

    foreach (auto index, aryErrorIndexes)
    {
        auto ServerOption = ServerOptions.at(index);
        ServerOption.bError = true;
        ServerOptions.removeAt(index);
        ServerOptions.insert(index, ServerOption);
    }

    return iRet;
}


// Create temporary Json file.
// Convert sshd_config file to Json file for processing.
int CSSHServer::SetToJson(const ServerObjects &ServerOptions)
{
    // Generate Json Object.
    QJsonObject root = {};
    QJsonObject node = {};

    foreach (auto ServerOption, ServerOptions)
    {
        // Store item's values.
        QJsonArray aryItemValues = {};
        foreach(auto Value, ServerOption.Values)
        {
            aryItemValues.push_back(Value);
        }

        // Store item's line number.
        QJsonArray aryJsonLines = {};
        foreach(auto Value, ServerOption.Lines)
        {
            aryJsonLines.push_back(Value);
        }

        // Store commented item's line number.
        QJsonArray aryJsonCommentLines = {};
        foreach(auto Value, ServerOption.CommentedLines)
        {
            aryJsonCommentLines.push_back(Value);
        }

        // Store Error flag.
        QJsonValue ErrorValue(ServerOption.bError);

        // "values" node "enablelines" node, "commentlines" node, "error" node.
        node.insert("values", aryItemValues);
        node.insert("enablelines", aryJsonLines);
        node.insert("commentlines", aryJsonCommentLines);
        node.insert("error",  ErrorValue);

        // Format
        // Item Name {
        //    "error":  ...,
        //    "values": [
        //       ...,
        //       ...
        //    ]
        // }
        root[ServerOption.Key] = node;
    }

    m_OldRoot = m_NewRoot;
    m_NewRoot = root;

    return 0;
}


// Get the contents of sshd_config for Editor.
QString CSSHServer::getContents() const
{
    return m_strContents;
}


// Generate random for 32-bit unsigned integer.
unsigned int CSSHServer::GenerateRandom()
{
    QList<unsigned int> arySeed = {};

    // Generate Seed.
    for(int i = 0; i < 4; i++)
    {
        auto strMilliSec1 = QDateTime::currentDateTime().toString("zzz").mid(0, 2);
        auto strMilliSec2 = QDateTime::currentDateTime().toString("zzz");
        auto strMilliSec3 = QDateTime::currentDateTime().toString("zzz").mid(1, 2);
        auto strMilliSec4 = QDateTime::currentDateTime().toString("zzz").mid(0, 2);
        auto uiSeed = (strMilliSec1 + strMilliSec2 + strMilliSec3 + strMilliSec4).toUInt();
        std::mt19937 SeedMT(uiSeed);

        // Generate 4-digit integer with poisson distribution.
        std::poisson_distribution<int> poisson(1000.0);
        int num = 0;
        while (num < 1000 || num > 9999) num = poisson(SeedMT) % 9000 + 1000;

        arySeed.append((strMilliSec1 + strMilliSec2 + QString::number(num, 10)).toUInt());
    }

    // XOR Shift.
    auto t = arySeed.at(0) ^ (arySeed.at(0) << 11);
    arySeed[0] = arySeed.at(1);
    arySeed[1] = arySeed.at(2);
    arySeed[2] = arySeed.at(3);
    auto uiSeed = (arySeed.at(3) ^ (arySeed.at(3) >> 19)) ^ (t ^ (t >> 8));

    // Generate random for 32-bit unsigned integer.
    std::mt19937 GenMT(uiSeed);
    unsigned int uiRandom = GenMT();

    return uiRandom;
}


// Get temporary sshd_config file name for remote server.
QString CSSHServer::getTmpFilePath()
{
    return m_strTmpSSHPath;
}


// Set temporary sshd_config file name for remote server.
void CSSHServer::setTmpFilePath(QString strLocalFile)
{
    m_strTmpSSHPath = strLocalFile;
}


// Get Json file path.
QString CSSHServer::getJsonFilePath() const
{
    return m_strJsonFilePath;
}


// Write Json file data to sshd_config.
int CSSHServer::writeToSSHFile()
{
    try
    {
        // Open Json file.
        QFile JsonFile(m_strJsonFilePath);
        if(!JsonFile.open(QIODevice::ReadOnly | QIODevice::Text))
        {
            m_strErrMsg = tr("File open error %1.").arg(m_strJsonFilePath) + "<br>" + JsonFile.errorString();

            return -1;
        }

        // Read Json file.
        auto byaryJson = JsonFile.readAll();

        // Close Json file.
        JsonFile.close();

        // Open temporary sshd_config file.
        QFile TmpSSHFile(m_strTmpSSHPath);
        if(!TmpSSHFile.open(QIODevice::ReadWrite | QIODevice::Text))
        {
            m_strErrMsg = tr("Failed to open temporary sshd_config file.") + "<br>" + TmpSSHFile.errorString();
            return -1;
        }

        // Create text stream.
        QTextStream Stream(&TmpSSHFile);

        // Get last line of sshd_config file.
        // Then, copy sshd_config file's contents to QStringList.
        int count = 0;
        auto arySSHLines = QStringList{};
        while(!Stream.atEnd())
        {
            count++;
            arySSHLines.append(Stream.readLine());
        }

        // Close temporary sshd_config file.
        TmpSSHFile.close();

        // Number of lines to be added.
        int iAddLinesCount = 0;

        // Get all values from Json file.
        auto JsonDocument = QJsonDocument::fromJson(byaryJson);
        auto JsonObject   = JsonDocument.object();

        foreach(const auto &Item, m_aryAllItems)
        {
            // Current specifications do not support following items.
            if(Item.toUpper() == "ACCEPTENV" || Item.toUpper() == "SUBSYSTEM" || Item.toUpper() == "MATCH")
            {
                continue;
            }

            QJsonValue  JsonItemName     = JsonObject.value(Item.toUpper());
            if(JsonItemName.isUndefined()) continue;

            QJsonObject JsonItemAllvalue = JsonItemName.toObject();

            QJsonArray  JsonEnableLines  = JsonItemAllvalue["enablelines"].toArray();
            QJsonArray  JsonCommentLines = JsonItemAllvalue["commentlines"].toArray();
            QJsonArray  JsonValues       = JsonItemAllvalue["values"].toArray();
            QJsonArray  JsonError        = JsonItemAllvalue["error"].toArray();

            // Check depricated item.
            if(Item.toUpper() == "CHALLENGERESPONSEAUTHENTICATION")
            {   // if "ChallengeResponseAuthentication" exist.
                QJsonValue  JsonPreferredItemName = JsonObject.value("KBDINTERACTIVEAUTHENTICATION");
                if(JsonPreferredItemName.isUndefined() == false)
                {   // If both "ChallengeResponseAuthentication" and "KbdInteractiveAuthentication" items exist.

                    // Comment and overwrite "ChallengeResponseAuthentication" item.
                    // If other valid same name item exists, comment.
                    for(auto i = 0; i < JsonEnableLines.count(); i++)
                    {
                        auto strOverwriteLine = QString("#") + arySSHLines.at(JsonEnableLines.at(i).toInt() - 1 + iAddLinesCount);
                        arySSHLines.replace(JsonEnableLines.at(i).toInt() - 1 + iAddLinesCount, strOverwriteLine);
                    }

                    continue;
                }
            }
//            else if(Item.toUpper() == "KBDINTERACTIVEAUTHENTICATION")
//            {   // If "KbdInteractiveAuthentication" exist.
//                QJsonValue  JsonDepricatedItemName    = JsonObject.value("CHALLENGERESPONSEAUTHENTICATION");
//                if(JsonDepricatedItemName.isUndefined()) continue;

//                QJsonObject JsonDepricatedItemAllvalue = JsonItemName.toObject();

//                QJsonArray  JsonDepricatedEnableLines  = JsonItemAllvalue["enablelines"].toArray();
//                QJsonArray  JsonDepricatedCommentLines = JsonItemAllvalue["commentlines"].toArray();
//                QJsonArray  JsonDepricatedValues       = JsonItemAllvalue["values"].toArray();
//            }

            // Items that allow multiple values to be set for a item.
            bool bMultipleValue = false;
            if(m_MapMultipleValues.contains(Item.toUpper()))
            {
                bMultipleValue = true;
            }

            // If there are multiple Items, all valid.
            bool bMultipleItem  = false;
            if(m_aryMultipleItems.contains(Item.toUpper()))
            {
                bMultipleItem = true;
            }

            // Move to row of valid item.
            if(JsonEnableLines.count() > 0)
            {   // If valid item exists
                //Stream.seek(JsonEnableLines.at(0).toInt());

                if(bMultipleValue && bMultipleItem)
                {   // AcceptEnv, Subsystem, Match
                }
                else if(bMultipleValue && !bMultipleItem)
                {   // RekeyLimit, AuthorizedKeysFile

                    // Convert to QStringList.
                    auto aryValues = QStringList{};
                    foreach(const auto &value, JsonValues)
                    {
                        aryValues.append(value.toString());
                    }

                    // Overwrite to enable line.
                    auto strOverwriteLine = Item + QString(" ") + aryValues.join(" ");
                    arySSHLines.replace(JsonEnableLines.at(0).toInt() - 1 + iAddLinesCount, strOverwriteLine);

                    // If other valid same name item exists, comment.
                    for(auto i = 1; i < JsonEnableLines.count(); i++)
                    {
                        auto strOtherItem = QString("#") + arySSHLines.at(JsonEnableLines.at(i).toInt() - 1 + iAddLinesCount);
                        arySSHLines.replace(JsonEnableLines.at(i).toInt() - 1 + iAddLinesCount, strOtherItem);
                    }
                }
                else if(!bMultipleValue && bMultipleItem)
                {   // Port, ListenAddress, Hostkey
                    if(JsonEnableLines.count() < JsonValues.count())
                    {   // If item to add.
                        auto aryAddValues = QStringList{};
                        for(auto i = 0; i < JsonValues.count(); i++)
                        {
                            if(i < JsonEnableLines.count())
                            {   // Overwrite to enable line.
                                auto strOverwriteLine = Item + QString(" ") + JsonValues.at(i).toString();
                                arySSHLines.replace(JsonEnableLines.at(i).toInt() - 1 + iAddLinesCount, strOverwriteLine);
                            }
                            else
                            {
                                aryAddValues.append(JsonValues.at(i).toString());
                            }
                        }

                        // Overwrite commented item.
                        // Then, if not enough items, append to next line of the item.
                        for(auto i = 0; i < aryAddValues.count(); i++)
                        {
                            if(i < JsonCommentLines.count())
                            {   // Overwrite to commented line.
                                auto strOverwriteLine = Item + QString(" ") + aryAddValues.at(i);
                                arySSHLines.replace(JsonCommentLines.at(i).toInt() - 1 + iAddLinesCount, strOverwriteLine);
                            }
                            else
                            {   // Add new lines.
                                auto iLastRow = JsonCommentLines.count() == 0 ?
                                                JsonEnableLines.at(JsonEnableLines.count() - 1).toInt() : JsonCommentLines.at(JsonCommentLines.count() - 1).toInt();

                                iAddLinesCount++;
                                auto strRemainValue = Item + QString(" ") + aryAddValues.at(i);
                                arySSHLines.insert(iLastRow - 1 + iAddLinesCount, strRemainValue);
                            }
                        }
                    }
                    else
                    {   // If item to comment.

                        // Overwrite to enable line.
                        for(auto i = 0; i < JsonValues.count(); i++)
                        {
                            auto strOverwriteLine = Item + QString(" ") + JsonValues.at(i).toString();
                            arySSHLines.replace(JsonEnableLines.at(i).toInt() - 1 + iAddLinesCount, strOverwriteLine);
                        }

                        // Comment on enable line.
                        for(auto i = JsonValues.count(); i < JsonEnableLines.count(); i++)
                        {
                            auto strOtherItem = QString("#") + arySSHLines.at(JsonEnableLines.at(i).toInt() - 1 + iAddLinesCount);
                            arySSHLines.replace(JsonEnableLines.at(i).toInt() - 1 + iAddLinesCount, strOtherItem);
                        }
                    }
                }
                else
                {   // Other item.

                    // Overwrite to enable line.
                    auto strOverwriteLine = Item + QString(" ") + JsonValues.at(0).toString();
                    arySSHLines.replace(JsonEnableLines.at(0).toInt() - 1 + iAddLinesCount, strOverwriteLine);

                    // Comment on enable line.
                    for(auto i = JsonValues.count(); i < JsonEnableLines.count(); i++)
                    {
                        auto strOtherItem = QString("#") + arySSHLines.at(JsonEnableLines.at(i).toInt() - 1 + iAddLinesCount);
                        arySSHLines.replace(JsonEnableLines.at(i).toInt() - 1 + iAddLinesCount, strOtherItem);
                    }
                }
            }
            else
            {   // If no item with valid value exists.

                // For commented or non-exist item, value equal to default value shall be NOP.
                auto ListsEqual = [](const auto &list1, const auto &list2) {
                    if(list1.size() != list2.size())
                    {
                        return false;
                    }

                    return std::equal(list1.begin(), list1.end(), list2.begin());
                };

                auto aryDefaultValues = m_MapDefaultValues.value(Item.toUpper());
                if(ListsEqual(JsonValues.toVariantList().toVector(), aryDefaultValues.toVector()))
                {
                    continue;
                }

                // Overwrite item or add item.
                if(bMultipleValue && bMultipleItem)
                {   // AuthorizedKeysFile, AcceptEnv, Subsystem, Match
                }
                else if(bMultipleValue && !bMultipleItem)
                {   // RekeyLimit
                    if(JsonCommentLines.count() > 0)
                    {   // Overwrite to commented line.
                        auto strOverwriteLine = Item + QString(" ") + JsonValues.at(0).toString();
                        arySSHLines.replace(JsonCommentLines.at(0).toInt() - 1 + iAddLinesCount, strOverwriteLine);
                    }
                    else
                    {   // Add new lines.
                        // Convert to QStringList.
                        auto aryValues = QStringList{};
                        foreach(const auto &value, JsonValues)
                        {
                            aryValues.append(value.toString());
                        }

                        auto strNewValue = Item + QString(" ") + aryValues.join(" ");
                        arySSHLines.append(strNewValue);

                        iAddLinesCount++;
                    }
                }
                else if(!bMultipleValue && bMultipleItem)
                {   // Port, ListenAddress, Hostkey
                    if(JsonCommentLines.count() < JsonValues.count())
                    {   // Overwrite to commented line and add new lines.

                        // Overwrite to commented line.
                        for(auto i = 0; i < JsonCommentLines.count(); i++)
                        {
                            auto strOverwriteLine = Item + QString(" ") + JsonValues.at(i).toString();
                            arySSHLines.replace(JsonCommentLines.at(i).toInt() - 1 + iAddLinesCount, strOverwriteLine);
                        }

                        // Add new lines.
                        QString strRemainValue = "";
                        for(auto i = JsonCommentLines.count(); i < JsonValues.count(); i++)
                        {
                            auto iLastRow = JsonCommentLines.count() == 0 ?
                                            count : JsonCommentLines.at(JsonCommentLines.count() - 1).toInt();

                            iAddLinesCount++;

                            strRemainValue += Item + QString(" ") + JsonValues.at(i).toString();
                            arySSHLines.insert(iLastRow - 1 + iAddLinesCount, strRemainValue);
                        }
                    }
                    else
                    {   // Overwrite to commented line.
                        for(auto i = 0; i < JsonValues.count(); i++)
                        {
                            auto strOverwriteLine = Item + QString(" ") + JsonValues.at(i).toString();
                            arySSHLines.replace(JsonCommentLines.at(i).toInt() - 1 + iAddLinesCount, strOverwriteLine);
                        }
                    }
                }
                else
                {   // Other item.
                    // If item to comment.
                    if(JsonCommentLines.count() > 0)
                    {   // If item to comment, overwrite to commented line.
                        auto strOverwriteLine = Item + QString(" ") + JsonValues.at(0).toString();
                        arySSHLines.replace(JsonCommentLines.at(0).toInt() - 1 + iAddLinesCount, strOverwriteLine);
                    }
                    else
                    {   // If non-exist item to comment, add new lines.
                        auto strNewValue = Item + QString(" ") + JsonValues.at(0).toString();
                        arySSHLines.append(strNewValue);

                        iAddLinesCount++;
                    }
                }
            }
        }

        // Open temporary sshd_config file.
        if(!TmpSSHFile.open(QIODevice::ReadWrite | QIODevice::Text))
        {
            m_strErrMsg = tr("Failed to open temporary sshd_config file.") + "<br>" + TmpSSHFile.errorString();
            return -1;
        }

        // Clear temporary sshd_config file contents.
        TmpSSHFile.resize(0);

        // Write temporary sshd_config file.
        foreach(const auto &SSHLine, arySSHLines)
        {
            Stream << SSHLine << Qt::endl;
        }

        // Close temporary sshd_config file.
        TmpSSHFile.close();
    }
    catch(QException &ex)
    {
        m_strErrMsg = tr("Failed to write to Json file.") + QString("<br>") + ex.what();
        return -1;
    }

    return 0;
}


// Write editor data to sshd_config.
int CSSHServer::writeToSSHFileForEditor(const QString &strContents)
{
    try
    {
        QFile TmpSSHFile(m_strTmpSSHPath);

        // Open file.
        if(!TmpSSHFile.open(QIODevice::ReadWrite | QIODevice::Text))
        {
            m_strErrMsg = tr("Failed to open temporary sshd_config file.") + QString("<br>") + TmpSSHFile.errorString();;
            return -1;
        }

        // Create text stream.
        QTextStream Stream(&TmpSSHFile);
        Stream.setCodec("UTF-8");

        // Write file.
        Stream << strContents;

        // Close file.
        TmpSSHFile.close();
    }
    catch(QException &ex)
    {
        m_strErrMsg = tr("Failed to write to temporary sshd_config file.") + QString("<br>") + ex.what();
        return -1;
    }

    return 0;
}


// Copy and backup sshd_config file.
int CSSHServer::copySSHFile(const QString &strSSHFilePath)
{
    // Check sshd_config file exist.
    if(!QFile::exists(m_strTmpSSHPath))
    {
        m_strErrMsg = tr("No such file : %1").arg(m_strTmpSSHPath);
        return -1;
    }

    if(!QFile::exists(strSSHFilePath))
    {
        m_strErrMsg = tr("No such file : %1").arg(strSSHFilePath);
        return -1;
    }

    // First, get sshd_config file's write permission.
    // Next, backup sshd_config file.
    if(getFileWritePermissions(strSSHFilePath) == 0)
    {   // If user executing this application has write permission to destination "sshd_config" file.
        try
        {
            // Backup sshd_config file.
            QFileInfo FileInfo(strSSHFilePath);

            auto Current_Date_Time    = QDateTime::currentDateTime();
            auto strDate              = QString("_bak") + Current_Date_Time.toString("_yyyyMMdd_hhmmss_zzz");
            auto strBackupSSHFilePath = FileInfo.absolutePath() + QDir::separator() + FileInfo.completeBaseName() + strDate;

            if(!QFile::rename(strSSHFilePath, strBackupSSHFilePath))
            {
                m_strErrMsg = tr("File backup error : %1").arg(strSSHFilePath) + QString("<br>");
                return -1;
            }

            // Copy sshd_config file.
            QFile SourceSSHFile(m_strTmpSSHPath);
            if(!SourceSSHFile.copy(strSSHFilePath))
            {
                m_strErrMsg = tr("File copy error : %1").arg(strSSHFilePath) + QString("<br>") + SourceSSHFile.errorString();
                return -1;
            }
        }
        catch(QException &ex)
        {
            m_strErrMsg = ex.what();
            return -1;
        }
    }
    else
    {   // If user executing this application does not have write permission to destination "sshd_config" file.
        QDBusConnection bus = QDBusConnection::systemBus();

        if(!bus.isConnected())
        {
            m_strErrMsg = tr("Cannot connect to the D-Bus system bus.");
            return -1;
        }

        // this is our Special Action that after allowed will call the helper
        QDBusMessage message = QDBusMessage::createMethodCall("org.presire.sshconfig",
                                                              "/org/presire/sshconfig",
                                                              "org.presire.sshconfig.server", QLatin1String("WriteSSHFile"));

        // If a method in a helper file has arguments, enter the arguments.
        QFileInfo FileInfo(strSSHFilePath);

        auto Current_Date_Time    = QDateTime::currentDateTime();
        auto strDate              = QString("_bak") + Current_Date_Time.toString("_yyyyMMdd_hhmmss_zzz");
        auto strBackupSSHFilePath = FileInfo.absolutePath() + QDir::separator() + FileInfo.completeBaseName() + strDate;

        QList<QVariant> ArgsToHelper;
        ArgsToHelper << QVariant::fromValue(strSSHFilePath) << QVariant::fromValue(strBackupSSHFilePath) << QVariant::fromValue(m_strTmpSSHPath);
        message.setArguments(ArgsToHelper);

        // Send a message to DBus. (Execute the helper file.)
        QDBusMessage reply = bus.call(message);

        // Receive the return value (including arguments) from helper file.
        // The methods in the helper file have two arguments, so check them.
        if(reply.type() == QDBusMessage::ReplyMessage)
        {
            if(reply.arguments().at(0).toInt() == -1)
            {   // If the helper file method fails after authentication.
                m_strErrMsg = reply.arguments().at(1).toString();
                return -1;
            }
            else if(reply.arguments().at(0).toInt() == 1)
            {   // If cancel authentication.
                return 1;
            }
        }
        else if(reply.type() == QDBusMessage::MethodCallMessage)
        {
            m_strErrMsg = tr("Message did not receive a reply (timeout by message bus).");
            return -1;
        }
        else if(reply.type() == QDBusMessage::ErrorMessage)
        {
            m_strErrMsg = tr("Could not send message to D-Bus.");
            return -1;
        }
    }

    return 0;
}


// Show Remote Window.
int CSSHServer::downloadSSHConfigFile(int width, int height, bool bDark, int fontPadding)
{
    if(m_clsRemote == nullptr)
    {
        m_clsRemote = std::make_unique<CRemoteWindow>(this);
        QObject::connect(m_clsRemote.get(), &CRemoteWindow::downloadSSHFile,  this, &CSSHServer::downloadSSHFileFromServer);
        QObject::connect(m_clsRemote.get(), &CRemoteWindow::reloadSSHFile,    this, &CSSHServer::reloadSSHFileFromServer);
        QObject::connect(m_clsRemote.get(), &CRemoteWindow::getHostKey,       this, &CSSHServer::getHostKeyFromServer);
        QObject::connect(m_clsRemote.get(), &CRemoteWindow::getAuthorizedKey, this, &CSSHServer::getAuthorizedKeyFromServer);
        QObject::connect(m_clsRemote.get(), &CRemoteWindow::getDirectory,     this, &CSSHServer::getDirectoryFromServer);
        QObject::connect(m_clsRemote.get(), &CRemoteWindow::uploadedSSHFile,  this, &CSSHServer::uploadedSSHFileToServer);
    }

    auto iRet = m_clsRemote->GetSSHDConfigFile(width * 0.6, height * 0.6, bDark, fontPadding);
    if(iRet != 0)
    {
        return -1;
    }

    return 0;
}


// Get path to sshd_config file in remote server.
QString CSSHServer::getSSHConfigFilePath()
{
    if (m_clsRemote != nullptr)
    {
        return m_clsRemote->GetRemoteSSHFile();
    }

    return "";
}


int CSSHServer::reloadSSHConfigFile(bool bDark, int fontPadding, const QString &strRemoteFilePath)
{
    if (m_clsRemote == nullptr)
    {
        m_strErrMsg = tr("No instance libRemoteWindow library.") + "<br>" +
                      tr("You may not have selected \"sshd_config\" file on remote server.");
        return -1;
    }

    auto iRet = m_clsRemote->ReloadSSHDConfigFile(bDark, fontPadding, strRemoteFilePath);
    if(iRet != 0)
    {
        return -1;
    }

    return 0;
}


// Get host key file from remote server.
int CSSHServer::getHostKeyFile(int width, int height, bool bDark, int fontPadding)
{
    if (m_clsRemote == nullptr)
    {
        m_strErrMsg = tr("No instance libRemoteWindow library.") + "<br>" +
                      tr("You may not have selected \"sshd_config\" file on remote server.");
        return -1;
    }

    m_clsRemote->GetKeyFile(width * 0.6, height * 0.6, bDark, fontPadding, 0);

    return 0;
}


// Get authorized key file from remote server.
int CSSHServer::getAuthorizedKeyFile(int width, int height, bool bDark, int fontPadding)
{
    if (m_clsRemote == nullptr)
    {
        m_strErrMsg = tr("No instance libRemoteWindow library.") + "<br>" +
                      tr("You may not have selected \"sshd_config\" file on remote server.");
        return -1;
    }

    m_clsRemote->GetKeyFile(width * 0.6, height * 0.6, bDark, fontPadding, 1);

    return 0;
}


// Get path to  directory in remote server.
int CSSHServer::getRemoteDirectory(int width, int height, bool bDark, int fontPadding, int DirectoryType)
{
    if (m_clsRemote == nullptr)
    {
        m_strErrMsg = tr("No instance libRemoteWindow library.") + "<br>" +
                      tr("You may not have selected \"sshd_config\" file on remote server.");
        return -1;
    }

    m_clsRemote->GetDirectory(width * 0.6, height * 0.6, bDark, fontPadding, DirectoryType);

    return 0;
}


// Upload sshd_config file to remote server.
int CSSHServer::uploadSSHConfigFile(const QString &strRemoteFilePath)
{
    if(m_clsRemote == nullptr)
    {
        m_strErrMsg = tr("No instance libRemoteWindow library.") + "<br>" +
                      tr("You may not have selected \"sshd_config\" file on remote server.");
        return -1;
    }

    // Open written sshd_config file.
    QFile File(m_strTmpSSHPath);
    if(!File.open(QIODevice::ReadOnly))
    {
        m_strErrMsg = tr("File open error %1.").arg(m_strTmpSSHPath) + QString("<br>") + File.errorString();
        return -1;
    }

    QTextStream Stream(&File);

    // Set character encoding to UTF-8. (If UTF-8 is not specified, double-byte characters are garbled.)
    Stream.setCodec("UTF-8");

    // Read written sshd_config's contents.
    auto strContents = Stream.readAll();

    // Close written sshd_config file.
    File.close();

    // Upload written sshd_config to remote server.
    auto iRet = m_clsRemote->UploadSSHConfigFile(strRemoteFilePath, strContents);
    if(iRet != 0)
    {
        m_strErrMsg = m_clsRemote->GetErrorMessage();
        return -1;
    }

    return 0;
}


// Disconnect from remote server.
void CSSHServer::disconnectFromServer()
{
    if(m_clsRemote != nullptr)
    {
        m_clsRemote->DisconnectFromServer();
    }

    return;
}


// Delete temporarily files used by this software.
int CSSHServer::removeTmpFiles() const
{
    if(QFile::exists(m_strTmpSSHPath))  QFile::remove(m_strTmpSSHPath);   // If exist, delete tmp sshd_config file.
    else                                 return -1;                         // Not exist File.

    if(QFile::exists(m_strJsonFilePath)) QFile::remove(m_strJsonFilePath);  // If exist, delete tmp json files ("ServerOptions" files).
    else                                 return -1;                         // Not exist File.

    return 0;
}


// Get error message.
QString CSSHServer::getErrorMessage()
{
    return m_strErrMsg;
}
