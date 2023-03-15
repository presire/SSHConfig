#ifndef CSSHVALUE_H
#define CSSHVALUE_H


#include <QCoreApplication>
#include <QJsonObject>
#include <QJsonDocument>
#include <QJsonArray>
#include <QDir>
#include <QFile>
#include <QException>


class CSSHValue : public QObject
{
    Q_OBJECT

private:    // Private Variables
    QByteArray      m_byaryJson;
    QJsonDocument   m_JsonDocument;
    QJsonObject     m_JsonObject;

    QString         m_strErrMsg;

    // Default items name.
    const QStringList m_aryAllItems =  {
        // General
        "PORT", "ADDRESSFAMILY", "LISTENADDRESS", "HOSTKEY", "REKEYLIMIT", "SYSLOGFACILITY", "LOGLEVEL", "LOGINGRACETIME", "STRICTMODES",
        // Authentication
        "PERMITROOTLOGIN", "MAXAUTHTRIES", "MAXSESSIONS", "PUBKEYAUTHENTICATION", "AUTHORIZEDKEYSFILE", "AUTHORIZEDKEYSCOMMAND",
        "AUTHORIZEDKEYSCOMMANDUSER", "HOSTBASEDAUTHENTICATION", "IGNOREUSERKNOWNHOSTS", "IGNORERHOSTS", "PASSWORDAUTHENTICATION",
        "PERMITEMPTYPASSWORDS", "CHALLENGERESPONSEAUTHENTICATION", "USEPAM", "FINGERPRINTHASH", "PUBKEYAUTHOPTIONS", "KBDINTERACTIVEAUTHENTICATION",
        // GSSAPI
        "KERBEROSAUTHENTICATION", "KERBEROSORLOCALPASSWD", "KERBEROSTICKETCLEANUP", "GSSAPIAUTHENTICATION",
        "GSSAPICLEANUPCREDENTIALS", "GSSAPISTRICTACCEPTORCHECK", "GSSAPIKEYEXCHANGE", "GSSAPISTORECREDENTIALSONREKEY", "GSSAPIKEXALGORITHMS",
        // Others
        "ACCEPTENV", "ALLOWAGENTFORWARDING", "ALLOWTCPFORWARDING", "GATEWAYPORTS", "X11FORWARDING", "X11DISPLAYOFFSET", "X11USELOCALHOST",
        "PRINTMOTD", "PRINTLASTLOG", "TCPKEEPALIVE", "PERMITUSERENVIRONMENT", "COMPRESSION", "CLIENTALIVEINTERVAL",
        "CLIENTALIVECOUNTMAX", "USEDNS", "PIDFILE", "MAXSTARTUPS", "PERMITTUNNEL", "CHROOTDIRECTORY", "BANNER", "VERSIONADDENDUM",
        "SUBSYSTEM", "MATCH"
    };

public:     // Public Variables


private:    // Private Functions

public:     // Public Functions
    CSSHValue(const CSSHValue&) = delete;
    explicit CSSHValue(QObject *parent = nullptr);
    virtual ~CSSHValue()        = default;

    Q_INVOKABLE int         readFromJson(const QString &strJsonPath);
    Q_INVOKABLE int         writeToJson(const QString &strJsonPath);
    Q_INVOKABLE QString     getItem(const QString &strKeyWord);
    Q_INVOKABLE QStringList getItems(const QString &strKeyWord);
    Q_INVOKABLE int         setItem(const QString &strKeyWord, const QString &strContents);
    Q_INVOKABLE int         setItems(const QString &strKeyWord, const QStringList &aryContents);

    // Get error message.
    Q_INVOKABLE QString getErrorMessage();

Q_SIGNALS:
    void getGeneralValues(int Port);
};

#endif // CSSHVALUE_H
