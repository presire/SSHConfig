#ifndef CREMOTEWINDOW_H
#define CREMOTEWINDOW_H

#include <QCoreApplication>
#include <QQmlApplicationEngine>
#include <QQmlComponent>
#include <QQuickWindow>
#include <QObject>
#include <QSettings>
#include <QDir>
#include <QIcon>
#include <QLocale>
#include <QTranslator>
#include "RemoteWindowExport.h"
#include "CClient.h"


class REMOTEWINDOW_EXPORT CRemoteWindow : public QObject
{
    Q_OBJECT

private:    // Private Variable
    std::unique_ptr<QQmlApplicationEngine>  m_pQMLEngine;
    std::unique_ptr<QQmlComponent>          m_pComponent;
    std::unique_ptr<QObject>                m_pObject;
    std::unique_ptr<CClient>                m_pClient;

    QString m_strRemoteSSHFile;

    // Remote server infomation.
    QString m_strHostName,      // Host name.
            m_strPort,          // Port number.
            m_strCertFile,      // Certificate file for SSL.
            m_strPrivateKey,    // Private key for SSL.
            m_strPassphrase;    // Passphrase with private key for SSL.
    bool    m_bUseSSL,          // Use SSL connect.
            m_bUseCert;         // Use SSL connect.
    bool    m_bUsePrivateKey,   // Use SSL connect.
            m_bUsePassphrase;   // Use SSL connect.

    // Error Message.
    QString m_strErrorMessage;

    // Translation
    QTranslator m_Translator;

public:     // Public Variable

private:    // Private Method

public:
    CRemoteWindow() = delete;
    CRemoteWindow(QObject *parent = nullptr);
    virtual ~CRemoteWindow();

    int     GetSSHDConfigFile(int width, int height, bool bDark, int fontPadding);
    int     ReloadSSHDConfigFile(bool bDark, int fontPadding, const QString &RemoteFilePath);
    int     GetKeyFile(int width, int height, bool bDark, int fontPadding, int KeyType);
    int     GetDirectory(int width, int height, bool bDark, int fontPadding, int DirectoryType);
    int     ExecRemoteSSHDCommand(const QString &strExecuteCommand);
    int     ExecRemoteSSHService(int width, int height, bool bDark, int fontPadding, const bool bActionFlag, const bool bStatus = false);
    int     UploadSSHConfigFile(const QString &strRemoteSSHFile, const QString &strContents);
    QString GetRemoteSSHFile();
    void    DisconnectFromServer();
    QString GetErrorMessage();

Q_SIGNALS:
    void downloadSSHFile(QString, QString);
    void reloadSSHFile(QString, QString);
    void getHostKey(QString);
    void getDirectory(int, QString);
    void getAuthorizedKey(QString);
    void sendSSHDResult(int, QString);
    void sendStatus(int);
    void uploadedSSHFile(int, QString);

private Q_SLOTS:
    void setRemoteInfo(QString strHostName, QString strPort, bool bUseSSL, bool bUseSSCert, QString strCertFile,
                       bool bUsePrivateKey, QString strPrivateKey, bool bUsePassphrase, QString strPassphrase);
};

#endif // CREMOTEWINDOW_H
