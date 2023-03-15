#ifndef CSERVER_H
#define CSERVER_H

#include <QObject>
#include <QtNetwork>
#include <QTcpServer>
#include <QTcpSocket>
//#include <bsd/readpassphrase.h>
//#include "CTCPSocket.h"
#include "CSSLSocket.h"


class CServer : public QTcpServer
{
    Q_OBJECT

private:
    bool                               m_bUseSSL,
                                       m_bUsePassphrase;
    QByteArray                         m_CertData,
                                       m_KeyData;
    QString                            m_Passphrase;
    QList<CSSLSocket*>                 m_SSLConnectionList;
    std::unique_ptr<QByteArray>        m_pData;
    std::unique_ptr<qint32>            m_pInt;
    QHash<QTcpSocket*, QByteArray*>    m_Buffers;  // Buffer to store data until block has completely received
    QHash<QTcpSocket*, qint32*>        m_Sizes;    // Store the size to verify if a block has received completely

public:

private:
    int           ConnectTCP();
    int           ConnectSSL();

protected:

public:
    explicit CServer(QObject *parent = nullptr);
    virtual  ~CServer();
    int      startListen(int iPort, bool bUseSSL, bool bCert, QString strCert, bool bPrivateKey, QString strPrivateKey, bool bUsePassphrase, QString strPassphrase);
    void     incomingConnection(qintptr SocketDescriptor) Q_DECL_OVERRIDE;

signals:

private slots:
    void QuitThread();
};

#endif // CSERVER_H
