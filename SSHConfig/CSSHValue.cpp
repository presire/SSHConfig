#include "CSSHValue.h"


CSSHValue::CSSHValue(QObject *parent) : QObject(parent)
{
}


// Read data from Json file.
int CSSHValue::readFromJson(const QString &strJsonPath)
{
    try
    {
        QFile File(strJsonPath);
        if(!File.open(QIODevice::ReadOnly | QIODevice::Text))
        {
            m_strErrMsg = tr("File open error %1.").arg(strJsonPath) + "<br>" + File.errorString();

            return -1;
        }

        m_byaryJson = File.readAll();

        m_JsonDocument = QJsonDocument::fromJson(m_byaryJson);
        m_JsonObject   = m_JsonDocument.object();

        File.close();
    }
    catch(QException &ex)
    {
        m_strErrMsg = ex.what();

        return -1;
    }

    return 0;
}


// Write data to Json file.
int CSSHValue::writeToJson(const QString &strJsonPath)
{
    try
    {
        QFile JsonFile(strJsonPath);
        if(!JsonFile.open(QIODevice::WriteOnly | QIODevice::Text))
        {
            m_strErrMsg = tr("File open error %1.").arg(strJsonPath) + "<br>" + JsonFile.errorString();

            return -1;
        }

        // Write Json file from QJsonObject to text.
        if(JsonFile.write(QJsonDocument(m_JsonObject).toJson()) < 0)
        {
            m_strErrMsg = tr("Failed to write temporary sshd_config file (Json file).") + "<br>" + JsonFile.errorString();
            return -1;
        }

        // Close file.
        JsonFile.close();
    }
    catch(QException &ex)
    {
        m_strErrMsg = ex.what();

        return -1;
    }

    return 0;
}


// Get item value.
QString CSSHValue::getItem(const QString &strKeyWord)
{
    QJsonArray JsonValues = {};

    if(strKeyWord.compare("CHALLENGERESPONSEAUTHENTICATION", Qt::CaseSensitive) == 0 ||
       strKeyWord.compare("KBDINTERACTIVEAUTHENTICATION", Qt::CaseSensitive)    == 0)
    {
        auto bKBDInteractive = false;
        if(m_JsonObject.contains("KBDINTERACTIVEAUTHENTICATION")) bKBDInteractive = true;

        if(bKBDInteractive)
        {
            QJsonValue  JsonItemName     = m_JsonObject.value("KBDINTERACTIVEAUTHENTICATION");
            QJsonObject JsonItemAllvalue = JsonItemName.toObject();
            JsonValues                   = JsonItemAllvalue["values"].toArray();
        }
        else
        {
            QJsonValue  JsonItemName     = m_JsonObject.value("CHALLENGERESPONSEAUTHENTICATION");
            QJsonObject JsonItemAllvalue = JsonItemName.toObject();
            JsonValues                   = JsonItemAllvalue["values"].toArray();
        }
    }
    else
    {
        // Get item "values" from Json.
        QJsonValue  JsonItemName     = m_JsonObject.value(strKeyWord);
        QJsonObject JsonItemAllvalue = JsonItemName.toObject();
        JsonValues                   = JsonItemAllvalue["values"].toArray();
//        QJsonArray  JsonEnableLines  = JsonValues["enablelines"].toArray();
//        QJsonArray  JsonCommentLines = JsonValues["commentlines"].toArray();
//        QJsonValue  JsonItemError    = JsonValues["error"];
    }

    // Convert to QStringList to QString.
    QStringList aryValues = {};
    foreach(const auto &value, JsonValues)
    {
        aryValues.append(value.toString());
    }

    auto strValue = aryValues.join(", ");

    return strValue;
}


// Get item values.
QStringList CSSHValue::getItems(const QString &strKeyWord)
{
    // Get item "values" from Json.
//    m_JsonDocument = QJsonDocument::fromJson(m_byaryJson);
//    m_JsonObject   = m_JsonDocument.object();

    QJsonValue  JsonItemName     = m_JsonObject.value(strKeyWord);
    QJsonObject JsonItemAllvalue = JsonItemName.toObject();
    QJsonArray  JsonValues       = JsonItemAllvalue["values"].toArray();
//    QJsonArray  JsonEnableLines  = JsonValues["enablelines"].toArray();
//    QJsonArray  JsonCommentLines = JsonValues["commentlines"].toArray();
//    QJsonValue  JsonItemError    = JsonValues["error"];

    // Convert to QStringList.
    QStringList aryValues = {};
    for(const auto &value : JsonValues)
    {
        aryValues.append(value.toString());
    }

    return aryValues;
}


// Set item value.
int CSSHValue::setItem(const QString &strKeyWord, const QString &strContents)
{
    // Set item "values" to Json.
    QJsonArray JsonValues = {};
    if(strKeyWord == "PORT")
    {
        foreach(const auto value, strContents.split(","))
        {
            // Do not add unnecessary value such as space.
            if(value.isEmpty() || value.compare(" ", Qt::CaseInsensitive) == 0)
            {
                continue;
            }

            // Add value.
            JsonValues.append(value);
        }
    }
    else
    {
        JsonValues.append(strContents);
    }

    // Check depricated item.
    if(strKeyWord == "CHALLENGERESPONSEAUTHENTICATION")
    {   // if "ChallengeResponseAuthentication" exist.
        QJsonValue  JsonPreferredItemName = m_JsonObject.value("KBDINTERACTIVEAUTHENTICATION");
        if(JsonPreferredItemName.isUndefined() == false)
        {   // If "KbdInteractiveAuthentication" items exist.
            QJsonObject JsonItemAllvalue = JsonPreferredItemName.toObject();

            JsonItemAllvalue["values"]                   = JsonValues;
            m_JsonObject["KBDINTERACTIVEAUTHENTICATION"] = JsonItemAllvalue;

            return 0;
        }
    }

    QJsonValue  JsonItemName     = m_JsonObject.value(strKeyWord);
    QJsonObject JsonItemAllvalue = JsonItemName.toObject();

    JsonItemAllvalue["values"] = JsonValues;
    m_JsonObject[strKeyWord]   = JsonItemAllvalue;

    return 0;
}


// Set item values.
int CSSHValue::setItems(const QString &strKeyWord, const QStringList &aryContents)
{
    // Set item "values" to Json.
    QJsonArray JsonValues = {};
    foreach(const auto value, aryContents)
    {
        // Trim.
        auto strValue = value.trimmed();

        // Do not add unnecessary value such as space.
        if(value.isEmpty() || value.compare(" ", Qt::CaseInsensitive) == 0)
        {
            continue;
        }

        // Add value.
        JsonValues.append(strValue);
    }

    QJsonValue  JsonItemName     = m_JsonObject.value(strKeyWord);
    QJsonObject JsonItemAllvalue = JsonItemName.toObject();

    JsonItemAllvalue["values"] = JsonValues;
    m_JsonObject[strKeyWord]   = JsonItemAllvalue;

    return 0;
}


// Get error message.
QString CSSHValue::getErrorMessage()
{
    return m_strErrMsg;
}
