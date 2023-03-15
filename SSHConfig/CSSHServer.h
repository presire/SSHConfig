#ifndef CSSHSERVER_H
#define CSSHSERVER_H

#include <QCoreApplication>
#include <QObject>
#include <QSettings>
#include <QtDBus>
#include <QDBusContext>
#include <QDBusMessage>
#include <QDBusConnection>
#include <QProcess>
#include <QException>
#include <QStandardPaths>
#include <QDirIterator>
#include <QDir>
#include <QFile>
#include "CRemoteWindow.h"


struct ServerObject
{
    // Item Name.
    QString     Key;

    // Item value or Item values.
    QStringList Values;

    // Item enable line(s) number.
    QList<int>  Lines;

    // Item commented line(s) number.
    // If Non-exist items in "sshd_config" file, set line number to "-1".
    QList<int>  CommentedLines;

    // Error.
    bool        bError;
};

using ServerObjects = QList<ServerObject>;
Q_DECLARE_METATYPE(ServerObjects)


class CSSHServer : public QObject
{
    Q_OBJECT

private:    // Private Variables
    QString     m_strIniFilePath;
    QString     m_strTmpSSHPath;
    QString     m_strJsonFilePath;
    QString     m_UserName;
    uint        m_GroupID;
    QString     m_HomePath;
    QProcess    m_Proc;
    QString     m_strContents;
    QJsonObject m_OldRoot;
    QJsonObject m_NewRoot;
    QString     m_strErrMsg;

    // Remote server object.
    std::unique_ptr<CRemoteWindow> m_clsRemote;

    // Default items name.
    const QStringList m_aryAllItems =  {
        // General
        "Port", "AddressFamily", "RekeyLimit", "ListenAddress", "Hostkey", "SyslogFacility", "LogLevel", "LoginGraceTime", "StrictModes",
        // Authentication
        "PermitRootLogin", "MaxAuthTries", "MaxSessions", "PubkeyAuthentication", "AuthorizedKeysFile", "AuthorizedKeysCommand",
        "AuthorizedKeysCommandUser", "HostbasedAuthentication", "IgnoreUserKnownHosts", "IgnoreRhosts", "PasswordAuthentication",
        "PermitEmptyPasswords", "ChallengeResponseAuthentication", "UsePAM", "FingerprintHash", "PubkeyAuthOptions", "KbdInteractiveAuthentication",
        // GSSAPI
        "KerberosAuthentication", "KerberosOrLocalPasswd", "KerberosTicketCleanup", "GSSAPIAuthentication",
        "GSSAPICleanupCredentials", "GSSAPIStrictAcceptorCheck", "GSSAPIKeyExchange", "GSSAPIStoreCredentialSonreKey", "GSSAPIKexAlgorithms",
        // Others
        "AcceptEnv", "AllowAgentForwarding", "AllowTcpForwarding", "GatewayPorts", "X11Forwarding", "X11DisplayOffset", "X11UseLocalhost",
        "PermitTTY", "PrintMotd", "PrintLastLog", "TCPKeepAlive ", "PermitUserEnvironment", "Compression", "ClientAliveInterval",
        "ClientAliveCountMax", "UseDNS", "PidFile", "MaxStartups", "PermitTunnel", "ChrootDirectory", "Banner", "VersionAddendum",
        "Subsystem", "Match"
    };

    // Default items name and values.
    const QMap<QString, QStringList> m_MapDefaultValues = {
        // General
        {"PORT", {"22"}}, {"ADDRESSFAMILY", {"any"}}, {"REKEYLIMIT", {"0", "0"}}, {"LISTENADDRESS", {"[::]:22", "0.0.0.0:22"}},
        {"HOSTKEY", {"/etc/ssh/ssh_host_rsa_key", "/etc/ssh/ssh_host_ecdsa_key", "/etc/ssh/ssh_host_ed25519_key"}},
        {"SYSLOGFACILITY", {"AUTH"}}, {"LOGLEVEL", {"INFO"}}, {"LOGINGRACETIME", {"120"}}, {"STRICTMODES", {"yes"}},
        // Authentication
        {"PERMITROOTLOGIN", {"yes"}}, {"MAXAUTHTRIES", {"6"}}, {"MAXSESSIONS", {"10"}},
        {"PASSWORDAUTHENTICATION", {"yes"}}, {"PERMITEMPTYPASSWORDS", {"no"}}, {"PUBKEYAUTHENTICATION", {"yes"}},
        {"AUTHORIZEDKEYSFILE", {".ssh/authorized_keys", ".ssh/authorized_keys2"}}, {"AUTHORIZEDKEYSCOMMAND", {"none"}}, {"AUTHORIZEDKEYSCOMMANDUSER", {"none"}},
        {"HOSTBASEDAUTHENTICATION", {"no"}}, {"IGNOREUSERKNOWNHOSTS", {"no"}}, {"IGNORERHOSTS", {"yes"}},
        {"CHALLENGERESPONSEAUTHENTICATION", {"yes"}}, {"USEPAM", {"no"}},
        {"PUBKEYAUTHOPTIONS", {"none"}}, {"FINGERPRINTHASH", {"SHA256"}}, {"KBDINTERACTIVEAUTHENTICATION", {"yes"}},
        // GSSAPI
        {"KERBEROSAUTHENTICATION", {"no"}}, {"KERBEROSORLOCALPASSWD", {"yes"}}, {"KERBEROSTICKETCLEANUP", {"yes"}},
        {"GSSAPIAUTHENTICATION", {"no"}}, {"GSSAPICLEANUPCREDENTIALS", {"yes"}}, {"GSSAPISTRICTACCEPTORCHECK", {"yes"}}, {"GSSAPIKEYEXCHANGE", {"no"}},
        {"GSSAPISTORECREDENTIALSONREKEY", {"no"}}, {"GSSAPIKEXALGORITHMS", {"gss-gex-sha1-,gss-group14-sha1-"}},
        // Others
        {"ALLOWAGENTFORWARDING", {"yes"}}, {"ALLOWTCPFORWARDING", {"yes"}}, {"GATEWAYPORTS", {"no"}}, {"X11FORWARDING", {"no"}},
        {"X11DISPLAYOFFSET", {"10"}}, {"X11USELOCALHOST", {"yes"}}, {"PERMITTTY", {"yes"}}, {"PRINTMOTD", {"yes"}}, {"PRINTLASTLOG", {"yes"}}, {"TCPKEEPALIVE", {"yes"}},
        {"PERMITUSERENVIRONMENT", {"no"}}, {"COMPRESSION", {"yes"}}, {"CLIENTALIVEINTERVAL", {"0"}}, {"CLIENTALIVECOUNTMAX", {"3"}},
        {"USEDNS", {"no"}}, {"PIDFILE", {"/run/sshd.pid"}}, {"MAXSTARTUPS", {"10:30:100"}}, {"PERMITTUNNEL", {"no"}}, {"CHROOTDIRECTORY", {"none"}},
        {"BANNER", {"none"}}, {"VERSIONADDENDUM", {"none"}}, {"ACCEPTENV", {""}}, {"SUBSYSTEM", {""}}, {"MATCH", {""}}
    };

    // Items that allow multiple values to be set for a item.
    // Items not listed are 1.
    // -1           : unlimited.
    // 2 or more    : natural number.
    const QMap<QString, int> m_MapMultipleValues = {
        {"REKEYLIMIT", 2},                                  // General
        {"AUTHORIZEDKEYSFILE", -1},                         // Authentication
        {"ACCEPTENV", -1}, {"SUBSYSTEM", -1}, {"MATCH", -1} // Others
    };

    // If there are multiple Items, all valid.
    const QStringList m_aryMultipleItems    = {
        "PORT", "LISTENADDRESS", "HOSTKEY",  // General
        //"AUTHORIZEDKEYSFILE",                // Authentication
        "ACCEPTENV", "SUBSYSTEM", "MATCH"    // Others
    };

public:     // Public Variables

private:    // Private Functions
    //friend QDBusArgument &operator<<(QDBusArgument &argument, const QVariantList &ReadContents);
    //friend const QDBusArgument &operator>>(const QDBusArgument &argument, QVariantList &ReadContents);

    // Run process in external terminal.
    void    startProcess(QString Execute, QStringList Args);

    // Format loaded sshd_config file.
    int     ReadSSHValues(const QString &strContents);

    // Create temporary sshd_config file and Json file to write.
    int     CreateTmpConfigFile(QString strContents);

    // Get valid item in sshd_config file.
    std::tuple<QString, QStringList>      CheckEnableLine(const QString &strLine);

    // Get commented item in sshd_config file.
    // Then, get default value for commented value.
    std::tuple<int, QString, QStringList> CheckCommentLine(const QString &strLine);

    // Set non-exist item in sshd_config file.
    // Then, set default value for non-exist item.
    void    SetNonExistItems(QMap<QString, QStringList> &mapValues, QMap<QString, QList<int>> &mapLines);

    // Disable deprecated items according to conditions.
    void    CheckDeprecatedItem(QMap<QString, QStringList> &mapValues, QMap<QString, QList<int>> &mapLines, QMap<QString, QList<int>> &mapCommentLines);

    // [Un-used] Check for presence of multiple values for non-duplicable items.
    int     CheckDuplication(ServerObjects &ServerOptions);

    // Create temporary Json file.
    // Convert sshd_config file to Json file for processing.
    int     SetToJson(const ServerObjects &ServerOptions);

    // Generate random.
    unsigned int GenerateRandom();

public:     // Public Functions
    explicit CSSHServer(QObject *parent = nullptr);
    virtual ~CSSHServer() = default;

    // Get read permission for sshd_config file.
    Q_INVOKABLE int     getFileReadPermissions(const QString &strSSHPath);

    // Get write permission for sshd_config file.
    Q_INVOKABLE int     getFileWritePermissions(const QString &strSSHPath);

    // Get path to sshd_config file in ini file.
    Q_INVOKABLE QString getSSHFilePath();

    // Save successfully loaded sshd_config file in ini file.
    Q_INVOKABLE int     saveSSHFilePath(const QString &strSSHDPath);

    // Get contents of sshd_config file.
    Q_INVOKABLE int     readSSHFile(const QString strFilePath);

    // Get contents of sshd_config file from remote server.
    Q_INVOKABLE int     readSSHFileFromServer(const QString strContents);

    // Get all contents of sshd_config file.
    Q_INVOKABLE QString getContents() const;

    // Get Json file path.
    Q_INVOKABLE QString getJsonFilePath() const;

    // Write Json file data to sshd_config.
    Q_INVOKABLE int     writeToSSHFile();

    // Write editor data to sshd_config.
    Q_INVOKABLE int     writeToSSHFileForEditor(const QString &strContents);

    // Copy and backup sshd_config file.
    Q_INVOKABLE int     copySSHFile(const QString &strFilePath);

    // Get temporary sshd_config file name for remote server.
    Q_INVOKABLE QString getTmpFilePath();

    // Set temporary sshd_config file name for remote server.
    Q_INVOKABLE void    setTmpFilePath(QString strLocalFile);

    // Download sshd_config file from remote server.
    Q_INVOKABLE int     downloadSSHConfigFile(int width, int height, bool bDark, int fontPadding);

    // Reload sshd_config file from remote server.
    Q_INVOKABLE int     reloadSSHConfigFile(bool bDark, int fontPadding, const QString &strRemoteFilePath);

    // Get host key file from remote server.
    Q_INVOKABLE int     getHostKeyFile(int width, int height, bool bDark, int fontPadding);

    // Get authorized key file from remote server.
    Q_INVOKABLE int     getAuthorizedKeyFile(int width, int height, bool bDark, int fontPadding);

    // Get path to sshd_config file from remote server.
    Q_INVOKABLE QString getSSHConfigFilePath();

    // Get path to  directory from remote server.
    Q_INVOKABLE int     getRemoteDirectory(int width, int height, bool bDark, int fontPadding, int DirectoryType);

    // Upload sshd_config file to remote server.
    Q_INVOKABLE int     uploadSSHConfigFile(const QString &strRemoteFilePath);

    // Disconnect from remote server.
    Q_INVOKABLE void    disconnectFromServer();

    // Delete temporarily files used.
    Q_INVOKABLE int     removeTmpFiles() const;

    // Get error message.
    Q_INVOKABLE QString getErrorMessage();

Q_SIGNALS:
    void resultProcess(int status, QString strErrorMessage = "");
    void downloadSSHFileFromServer(QString strSSHConfigFilePath, QString strContents);
    void reloadSSHFileFromServer(QString strSSHConfigFilePath, QString strContents);
    void getHostKeyFromServer(QString strHostKeyFilePath);
    void getAuthorizedKeyFromServer(QString strAuthorizedKeyFilePath);
    void getDirectoryFromServer(int directoryType, QString strDirectoryPath);
    void uploadedSSHFileToServer(int status, QString strErrorMessage);

public Q_SLOTS:
    void ProcessFinished(int exitCode, QProcess::ExitStatus exitStatus);
    void UpdateOutput();
    void UpdateError();
};

#endif // CSSHSERVER_H
