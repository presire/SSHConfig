#ifndef CSSHSERVICE_H
#define CSSHSERVICE_H

#include <QCoreApplication>
#include <QObject>
#include <QtDBus>
#include <QSettings>
#include <QProcess>
#include <QException>
#include <QStandardPaths>
#include "CRemoteWindow.h"


struct UnitProcess
{
    QString ServiceName;
    uint JobNum;
    QString Command;
};
using UnitProcesses = QList<UnitProcess>;
Q_DECLARE_METATYPE(UnitProcesses)


class CSSHService : public QObject
{
    Q_OBJECT

private:    // Private Variables
    QString     m_strIniFilePath;
    QProcess    m_Proc;
    QString     m_strErrMsg;
    UnitProcess m_strtReply;

    std::unique_ptr<CRemoteWindow> m_clsRemote;
    QString     m_strResponse;
    QString     m_strStdOutput;

public:     // Public Variables


private:    // Private Functions
    int CheckSSHService(QString &strSSHServiceFile);
    //friend QDBusArgument &operator<<(QDBusArgument &argument, const UnitProcesses &strtReply);
    //friend const QDBusArgument &operator>>(const QDBusArgument &argument, UnitProcesses &strtReply);

public:     // Public Functions
    explicit CSSHService(QObject *parent = nullptr);
    virtual ~CSSHService();

    Q_INVOKABLE int setSSHService(const QString strPropertyName);
    Q_INVOKABLE int getStateSSHService();

    // Execute sshd command.
    Q_INVOKABLE int         executeRemoteSSHService(int width, int height, bool bDark, int fontPadding, bool bActionFlag, bool bStatus = false);
    Q_INVOKABLE QString     getCommandResult();

    // Set requiring administrator password to read/write sshd_config file.
    Q_INVOKABLE int         changeAdminPassword(bool bAdmin);

    // Disconnect from remote server.
    Q_INVOKABLE void        disconnectFromServer();

    // Get error message.
    Q_INVOKABLE QString     getErrorMessage();

Q_SIGNALS:
    void resultSSHService(int status, QString strErrMsg = "");
    void resultProcess(int status, QString strErrMsg = "");
    void resultGetSSHStatusRemoteHost(int status);

public Q_SLOTS:
    void ProcessFinished(int exitCode, QProcess::ExitStatus exitStatus);
    void UpdateOutput();
    void UpdateError();
};

#endif // CSSHSERVICE_H
