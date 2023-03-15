#ifndef CSSLSOCKET_H
#define CSSLSOCKET_H

#include <QObject>
#include <QtNetwork>
#include <QTcpSocket>
#include <QHostAddress>
#include <QDataStream>
#include <QtDBus>


struct UnitProcess
{
    QString ServiceName;
    uint JobNum;
    QString Command;
};
using UnitProcesses = QList<UnitProcess>;
Q_DECLARE_METATYPE(UnitProcesses)


class CSSLSocket : public QSslSocket
{
    Q_OBJECT

private:
    QString                         m_CurrentDir;
    std::unique_ptr<QByteArray>     m_pData;
    std::unique_ptr<qint32>         m_pInt;
    QHash<QSslSocket*, QByteArray*> m_Buffers;  // Buffer to store data until block has completely received
    QHash<QSslSocket*, qint32*>     m_Sizes;    // Store the size to verify if a block has received completely

    // For sshd command.
    QString                         m_ProcessMsg;
    std::unique_ptr<QProcess>       m_Process;

public:

private:
    qint32        ArrayToInt(QByteArray source);
    QByteArray    IntToArray(qint32 source);
    void          Show(QByteArray, QString strHostAddress);
    bool          Send(const QByteArray &data);
    int           Command(const QByteArray &data);
    std::tuple<int, QString, QString>       DirCommand(QString &strDirCommand);
    std::tuple<int, QString, QString, bool, QString> SSHDCommand(QString &strSSHDCommand);
    int           ExecuteSSHService(bool bStart);
    int           GetStatusSSHService();
    std::tuple<int, QString, QString, QString, QString> PushCommand(QString &strPushCommand);

public:
    CSSLSocket(int SocketDescriptor, QSslSocket *parent = nullptr);
    ~CSSLSocket();

Q_SIGNALS:

public Q_SLOTS:
    void Read();
    void SocketErr(QAbstractSocket::SocketError socketError);
};

#endif // CSSLSOCKET_H
