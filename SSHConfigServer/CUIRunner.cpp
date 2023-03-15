#include <QCoreApplication>
#include "CUIRunner.h"
#include "CServer.h"


CUIRunner::CUIRunner(int argc, char *argv[]) : QCoreApplication(argc, argv)
{
    // Get path to configuration file.
    auto pApp = QCoreApplication::instance();
    m_Args    = pApp->arguments();
}


CUIRunner::~CUIRunner()
{

}

void CUIRunner::run()
{
    // Set locale.
    foreach(auto arg, m_Args)
    {
        if(arg.mid(0, 9) == "--locale=")
        {
            auto strLocale = arg.replace("--locale=", "", Qt::CaseSensitive);
            auto iLang = strLocale.compare("jp", Qt::CaseSensitive) == 0 ? 1 : 0;
            if(iLang == 1)
            {
                if(m_Translator.load(":/i18n/SSHConfigServer_ja_JP.qm"))
                {
                    this->installTranslator(&m_Translator);
                }
            }
        }
    }

    // Get path to configuration file.
    foreach(auto arg, m_Args)
    {
        if(arg.mid(0, 13) == "--sysconfdir=")
        {
            m_strSysConf = arg.replace("--sysconfdir=", "", Qt::CaseSensitive);
        }
    }

    if(m_strSysConf.isEmpty())
    {
        QTextStream ErrorStream(stderr);
        ErrorStream << tr("Option is wrong. The available option is \"--sysconfdir=<path to sshconfig.json>\".") + QString("\n");
        ErrorStream.flush();

        QCoreApplication::exit(0);
        return;
    }

    if(!QFile::exists(m_strSysConf))
    {
        QTextStream ErrorStream(stderr);
        ErrorStream << tr("No such file error : %1").arg(m_strSysConf) + QString("\n");
        ErrorStream.flush();

        QCoreApplication::exit(0);
        return;
    }

    try
    {
        QFile File(m_strSysConf);
        if(!File.open(QIODevice::ReadOnly | QIODevice::Text))
        {
            auto strErrMsg = tr("File open error : %1").arg(m_strSysConf) + QString("\n") + File.errorString();
            QTextStream ErrorStream(stderr);
            ErrorStream << tr("Error : %1").arg(strErrMsg);
            ErrorStream.flush();

            QCoreApplication::exit(0);
        }

        auto byaryJson = File.readAll();

        // Get item "values" from Json.
        auto JsonDocument = QJsonDocument::fromJson(byaryJson);
        auto JsonObject   = JsonDocument.object();

        QJsonValue  JsonItemName     = JsonObject.value("PORT");
        QJsonObject JsonItemAllvalue = JsonItemName.toObject();
        auto        iPort            = JsonItemAllvalue["value"].toInt(61060);

        JsonItemName     = JsonObject.value("USESSL");
        JsonItemAllvalue = JsonItemName.toObject();
        auto bUseSSL     = JsonItemAllvalue["value"].toBool(false);

        JsonItemName     = JsonObject.value("USECERT");
        JsonItemAllvalue = JsonItemName.toObject();
        auto bCert       = JsonItemAllvalue["value"].toBool(false);

        JsonItemName     = JsonObject.value("CERTFILE");
        JsonItemAllvalue = JsonItemName.toObject();
        auto strCert     = JsonItemAllvalue["value"].toString("");

        JsonItemName     = JsonObject.value("USEKEY");
        JsonItemAllvalue = JsonItemName.toObject();
        auto bPrivateKey = JsonItemAllvalue["value"].toBool(false);

        JsonItemName       = JsonObject.value("KEYFILE");
        JsonItemAllvalue   = JsonItemName.toObject();
        auto strPrivateKey = JsonItemAllvalue["value"].toString("");

        JsonItemName     = JsonObject.value("USEPASSPHRASE");
        JsonItemAllvalue = JsonItemName.toObject();
        auto bPassphrase = JsonItemAllvalue["value"].toBool(false);

        JsonItemName       = JsonObject.value("PASSPHRASE");
        JsonItemAllvalue   = JsonItemName.toObject();
        auto strPassphrase = JsonItemAllvalue["value"].toString("");

        File.close();

        // Main loop.
        CServer Server(this);
        if(Server.startListen(iPort, bUseSSL, bCert, strCert, bPrivateKey, strPrivateKey, bPassphrase, strPassphrase))
        {   // Settings error.
            QCoreApplication::exit(0);  // Quit application.
            return;
        }
    }
    catch(QException &ex)
    {
        auto strErrMsg = ex.what();
        QTextStream ErrorStream(stderr);
        ErrorStream << tr("Error : %1").arg(strErrMsg);
        ErrorStream.flush();

        QCoreApplication::exit(0);
        return;
    }

    QCoreApplication::exit(0);

    return;
}
