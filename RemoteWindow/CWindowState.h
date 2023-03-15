#ifndef CWINDOWSTATE_H
#define CWINDOWSTATE_H

#include <QCoreApplication>
#include <QObject>
#include <QQmlEngine>
#include <QSettings>
#include <QProcess>
#include <QException>
#include <QDir>
#include <QFile>


class CWindowState : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

private:    // Private Variables
    QString         m_strIniFilePath;
    QString         m_UserName;
    QString         m_HomePath;
    QString         m_strErrMsg;

public:     // Public Variables

private:    // Private Functions

public:     // Public Functions
    CWindowState(const CWindowState&) = delete;
    explicit CWindowState(QObject *parent = nullptr);
    virtual ~CWindowState() = default;

    // Get settings for SSHConfig application.
    Q_INVOKABLE int         getMainWindowX();
    Q_INVOKABLE int         getMainWindowY();
    Q_INVOKABLE int         getMainWindowWidth();
    Q_INVOKABLE int         getMainWindowHeight();
    Q_INVOKABLE bool        getMainWindowMaximized();
    Q_INVOKABLE int         setMainWindowState(int X, int Y, int Width, int Height, bool Maximized);
    Q_INVOKABLE static bool getColorMode();
    Q_INVOKABLE int         setColorMode(bool bDarkMode);
    Q_INVOKABLE int         getColorModeOverWrite();
    Q_INVOKABLE int         setColorModeOverWrite(bool bOverWrite);
    Q_INVOKABLE int         getFontSize();
    Q_INVOKABLE int         setFontSize(int FontSize);
    Q_INVOKABLE bool        getServerMode();
    Q_INVOKABLE int         setServerMode(bool bServerMode);
    Q_INVOKABLE bool        getAdminPassword();
    Q_INVOKABLE int         setAdminPassword(bool bAdminPassword);

    // SSH connect to remote server.
    Q_INVOKABLE QString     getUserName();
    Q_INVOKABLE QString     getHostName();
    Q_INVOKABLE QString     getPort();
    Q_INVOKABLE bool        getPubkeyAuth();
    Q_INVOKABLE QString     getIdentityFile();
    Q_INVOKABLE bool        getPassphrase();
    Q_INVOKABLE int         setRemoteInfo(const QString User, const QString Host, const QString Port, const QString IdentityFile,
                                          bool bPubKeyAuth, bool bPassphrase);

    // TCP/SSL connect to remote server.
    Q_INVOKABLE bool        getSSL();
    Q_INVOKABLE bool        getCert();
    Q_INVOKABLE QString     getCertFile();
    Q_INVOKABLE bool        getPrivateKey();
    Q_INVOKABLE QString     getPrivateKeyFile();
    Q_INVOKABLE int         saveRemoteInfo(QString strHostName, QString strPort,     bool bUseSSL,          bool bUseCert,
                                           QString strCertFile, bool bUsePrivateKey, QString strPrivateKey, bool bUsePassphrase);

    // Restart application.
    Q_INVOKABLE void        restartSoftware();

    // Get SSHConfig application's version.
    Q_INVOKABLE QString     getVersion();

    // Remove temporary sshd_config, ServerOption.json files.
    Q_INVOKABLE int         removeTmpFiles() const;

    // Get error message.
    Q_INVOKABLE QString     getErrorMessage() const;

Q_SIGNALS:

public Q_SLOTS:

};

#endif // CWINDOWSTATE_H
