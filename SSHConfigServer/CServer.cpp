/*
 * ISC License (ISC)
 *
 * The char *readpassphrase(const char *prompt, char *buf, size_t bufsiz, int flags) function is:
 *
 * Copyright (c) 2000-2002, 2007, 2010
 *   Todd C. Miller <Todd.Miller@courtesan.com>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 * Sponsored in part by the Defense Advanced Research Projects
 * Agency (DARPA) and Air Force Research Laboratory, Air Force
 * Materiel Command, USAF, under agreement number F39502-99-1-0512.
*/

#include "CServer.h"


CServer::CServer(QObject *parent) : QTcpServer(parent)
{
}


CServer::~CServer()
{
//    if(m_bUseSSL)
//    {
//        foreach (auto Connection, m_SSLConnectionList)
//        {
//            Connection->deleteLater();
//            Connection->close();
//            Connection = nullptr;
//        }

//        m_SSLConnectionList.clear();
//    }
//    else
//    {
//        foreach (auto Connection, m_TCPConnectionList)
//        {
//            Connection->deleteLater();
//            Connection->close();
//            Connection = nullptr;
//        }

//        m_TCPConnectionList.clear();
//    }

    foreach (auto Connection, m_SSLConnectionList)
    {
        Connection->abort();
        Connection->deleteLater();
        Connection->close();
        Connection = nullptr;
    }

    m_SSLConnectionList.clear();

    this->close();
    this->deleteLater();
}


int CServer::startListen(int iPort, bool bUseSSL, bool bCert, QString strCert, bool bPrivateKey, QString strPrivateKey, bool bUsePassphrase, QString strPassphrase)
{
    // Set server information.
    m_bUseSSL        = bUseSSL;
    m_bUsePassphrase = bUsePassphrase;

    if(this->listen(QHostAddress::Any, iPort))
    {
        QString strMessage = tr("Listen port %1 OK").arg(iPort) + QString("\n");
        QTextStream ts(stderr);
        ts << strMessage;
        ts.flush();
    }
    else
    {
        QString strMessage = tr("Listen error : %1").arg(this->errorString()) + QString("\n");
        QTextStream ts(stderr);
        ts << strMessage;
        ts.flush();

        return -1;
    }

    // When use SSL, load server certificate and private key.
    if(m_bUseSSL)
    {
        // Load server certificate.
        if(bCert)
        {
            QFile FileCert(strCert);
            if(FileCert.exists())
            {
                if(FileCert.open(QIODevice::ReadOnly))
                {
                    m_CertData = FileCert.readAll();
                    FileCert.close();
                }
            }
            else
            {
                QString strMessage = tr("Error : No such file Certification file.") + QString("\n") + FileCert.errorString() + QString("\n");
                QTextStream ts(stderr);
                ts << strMessage;
                ts.flush();

                return -1;
            }
        }

        // Load private key.
        if(bPrivateKey)
        {
            QFile FileKey(strPrivateKey);
            if(FileKey.exists())
            {
                if(FileKey.open(QIODevice::ReadOnly))
                {
                    m_KeyData = FileKey.readAll();
                    FileKey.close();
                }

                if(m_bUsePassphrase)
                {
                    // Input passphrase for private key.
                    m_Passphrase = strPassphrase;

//                    QByteArray Data = {};
//                    Data.resize(1024);
//                    if(readpassphrase(QString(tr("Input Private Key Passphrase : ")).toLatin1().data(), Data.data(), Data.size(), RPP_REQUIRE_TTY) == nullptr)
//                    {
//                        QString strMessage = tr("Unable to read passphrase.") + QString("\n");
//                        QTextStream ts(stderr);
//                        ts << strMessage;
//                        ts.flush();
//                    }

//                    m_Passphrase = QString(Data);

//                    // Clear password from memory for security.
//                    memset(Data.data(), 0, Data.size());
                }
            }
            else
            {
                QString strMessage = tr("Error : No such Private Key file.") + QString("\n") + FileKey.errorString() + QString("\n");
                QTextStream ts(stderr);
                ts << strMessage;
                ts.flush();

                return -1;
            }
        }
    }

    // Waiting for connections from clients.
    while(this->isListening())
    {
        this->waitForNewConnection();
    }

    return 0;
}


// Called by QTcpServer or QSslServer, when a new connection is available.
void CServer::incomingConnection(qintptr SocketDescriptor)
{
    // A new connection.
    QString strMessage = tr("Connecting... Socket Descriptor = %1").arg(SocketDescriptor) + QString("\n");
    QTextStream ts(stderr);
    ts << strMessage;
    ts.flush();

    // サーバソケットをSSL化する
    CSSLSocket *pSocket = new CSSLSocket(SocketDescriptor);

    if(m_bUseSSL)
    {   // SSL-enable server sockets.

        // Set server certificate.
        QSslCertificate SSLCert(m_CertData);
        pSocket->setLocalCertificate(SSLCert);

        // Set private key.
        QSslKey SSLPrivateKey(m_KeyData, QSsl::Rsa, QSsl::Pem, QSsl::PrivateKey);

        // Use passphrase.
        if(m_bUsePassphrase)
        {   // Load passphrase.
            SSLPrivateKey.toPem(m_Passphrase.toUtf8());
        }

        pSocket->setPrivateKey(SSLPrivateKey);

        // Set SSL protocol version.
        pSocket->setProtocol(QSsl::TlsV1_3OrLater);
    }

    // Add group of connections.
    m_SSLConnectionList.append(pSocket);

    // Create a thread.
    QThread *pThread = new QThread();

    connect(pSocket, &CSSLSocket::readyRead,    pSocket, &CSSLSocket::Read); // will move into the thread
    connect(pSocket, &CSSLSocket::disconnected, pThread, &QThread::quit);
    connect(pThread, &QThread::finished,        this,    &CServer::QuitThread);
    connect(pThread, &QThread::finished,        pSocket, &CSSLSocket::deleteLater);

    if(m_bUseSSL)
    {
        pSocket->startServerEncryption();
        if(!pSocket->waitForEncrypted(5000))
        {   // Error.
            delete pSocket;
            delete pThread;

            return;
        }
        else
        {   // Recieve session.
        }
    }

    pSocket->moveToThread(pThread);
    pThread->start();

    // Documents require inheriting this function to emit this signal, there is no slot connected to this signal here.
    emit newConnection();
}


void CServer::QuitThread()
{
    QString strMessage = tr("End thread") + QString("\n");
    QTextStream ts(stderr);
    ts << strMessage;
    ts.flush();
}
