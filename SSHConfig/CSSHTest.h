#ifndef CSSHTEST_H
#define CSSHTEST_H

#include <QObject>
#include <QtDBus>
#include <QDBusContext>
#include <QDBusMessage>
#include <QDBusConnection>
#include <QFile>
#include "CRemoteWindow.h"


class CSSHTest : public QObject
{
    Q_OBJECT

private:
    QString                        m_strStdOutput;
    QString                        m_strErrorMsg;
    std::unique_ptr<CRemoteWindow> m_clsRemote;

public:

private:
    // Execute sshd command on local computer using D-Bus. (Send helper executable)
    int     executeSSHDCommandFromHelper(const QString &strSSHDComandPath, const QStringList &aryOptions, const int option);

public:
    explicit CSSHTest(QObject *parent = nullptr);
    virtual  ~CSSHTest() = default;

    // Execute sshd command on local computer.
    Q_INVOKABLE int         executeSSHDCommand(QString strSSHDComandPath, const QString &strSSHFilePath, const int option);

    // Get result of sshd command from helper executable.
    Q_INVOKABLE QString     getCommandResult();

    // Download sshd_config file from remote server.
    Q_INVOKABLE int         downloadSSHConfigFile(int width, int height, bool bDark, int fontPadding);

    // Get path to sshd_config on remote server.
    Q_INVOKABLE QString     getSSHConfigFilePath();

    // Execute sshd command.
    Q_INVOKABLE int         executeRemoteSSHDCommand(QString strSSHDComandPath, QString strSSHFilePath, int option);

    // Disconnect from remote server.
    Q_INVOKABLE int         disconnectFromServer();

    // Get error message.
    Q_INVOKABLE QString     getErrorMessage();

Q_SIGNALS:
    void resultProcess(int status, QString strErrMsg = "");
    void downloadSSHFileFromServer(QString strSSHConfigFilePath, QString strContents);
    void readSSHDResult(int status, QString strMessage);

public Q_SLOTS:
};

#endif // CSSHTEST_H
