#ifndef CCLIENT_H
#define CCLIENT_H


#include <QObject>
#include <QtNetwork>
#include <QTcpSocket>
#include <QSslSocket>
#include <QSslKey>
#include <QSslCipher>
#include <QSslCertificate>
#include <QDataStream>


class CClient : public QSslSocket
{
    Q_OBJECT

private:    // Privates variables
    // Remote server infomation.
    bool                        m_bUseSSL,          // Use SSL connect.
                                m_bUseSSCert;       // Use SSL connect.
    bool                        m_bUsePrivateKey,   // Use SSL connect.
                                m_bUsePassphrase;   // Use SSL connect.

    QString                     m_HostName,         // Host name.
                                m_Port,             // Port number.
                                m_CertFile,         // Certificate file for SSL.
                                m_PrivateKeyFile,   // Private key for SSL.
                                m_Passphrase;       // Passphrase with private key for SSL.

    int                         m_iFileMode;        // 0 : Download sshd_config file.
                                                    // 1 : Get path to key file.

    // Socket object.
    std::unique_ptr<QByteArray>     m_pData;
    std::unique_ptr<qint32>         m_pInt;
    QHash<QSslSocket*, QByteArray*> m_Buffers;  // Buffer to store data until block has completely received
    QHash<QSslSocket*, qint32*>     m_Sizes;    // Store the size to verify if a block has received completely

    // Current Directory.
    QString                     m_strCurrentDirectory;

    // Command number to send.
    int                         m_iCommandNumber;

    // Get directories.
    QStringList                 m_aryDirectories;

    // Get files.
    QStringList                 m_aryFiles;

    // Error message.
    QString                     m_strErrorMessage;

public:     // Public variables

private:    // Private Function
    // Integer to QByteArray.
    QByteArray IntToArray(qint32 source);

    // QByteArray to Integer.
    qint32     ArrayToInt(QByteArray source);

    // Recieve data.
    void       ReciveData(QByteArray data);

    // Display recieve data.
    void       Show(QByteArray data, QString strHostAddress);

public:
    explicit CClient(QSslSocket *parent = nullptr);
    virtual ~CClient();

    Q_INVOKABLE QString     getCurrentDirectory();
    Q_INVOKABLE void        setCurrentDirectory(QString strCurrentDirectory);
    Q_INVOKABLE int         setUpDirectory();
    Q_INVOKABLE bool        connectToServer(QString strHostName,   QString strPort,        bool bUseSSL,        bool bUseCert,      QString strCertFile,
                                            bool bUsePrivateKey,   QString PrivateKeyFile, bool bUsePassphrase, QString Passphrase, int iFileMode);
    Q_INVOKABLE int         writeToServer(const QString &strCommand, int iCommandNumber);
    Q_INVOKABLE void        disConnectFromServer();
    Q_INVOKABLE QStringList directories();
    Q_INVOKABLE QStringList files();
    Q_INVOKABLE QString     getErrorMessage();

signals:
    void serverConnected();
    void readDirectory();
    void readSSHFile(QString strContents);
    void reloadSSHFile(QString strContents);
    void readSSHDCommand(int iRet, QString strResult);
    void readSSH(int iSSH);
    void readSSHStatus(int Status);
    void uploadedSSHFile(int Status, QString strMessage);
    void readError(QString strError);

private Q_SLOTS:
    // Recieve data to remote server.
    void    Read();

    // Get connection error.
    void    SocketErr(QAbstractSocket::SocketError socketError);

    // Get connection error using SSL.
    void    SSLErrors(const QList<QSslError> &errors);

    void    sslErrorOccured(const QList<QSslError> & error);
};

#endif // CCLIENT_H
