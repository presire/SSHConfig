#include "CClient.h"


CClient::CClient(QSslSocket *parent) : QSslSocket(parent), m_strCurrentDirectory("/")
{
}


CClient::~CClient()
{
    this->abort();
    this->disconnectFromHost();
    this->close();
    this->deleteLater();

    if(m_pData != nullptr) m_pData.reset();
    if(m_pInt != nullptr)  m_pInt.reset();

    if(!m_Buffers.isEmpty()) m_Buffers.empty();
    if(!m_Sizes.isEmpty())   m_Sizes.empty();

    QString strHostAddress  = this->QAbstractSocket::peerAddress().toString();
    QString strStateMessage = tr("Client [%1] disconnected.").arg(strHostAddress) + QString("\n");
    QTextStream ts(stderr);
    ts << strStateMessage;
    ts.flush();
}


QString CClient::getCurrentDirectory()
{
    return m_strCurrentDirectory;
}


void CClient::setCurrentDirectory(QString strCurrentDirectory)
{
    if(m_strCurrentDirectory == "/") m_strCurrentDirectory += strCurrentDirectory;
    else                             m_strCurrentDirectory += QDir::separator() + strCurrentDirectory;

    return;
}


int CClient::setUpDirectory()
{
    if(m_strCurrentDirectory != "/")
    {
        auto index = m_strCurrentDirectory.lastIndexOf("/");

        if(index == 0) index++;

        m_strCurrentDirectory = m_strCurrentDirectory.mid(0, index);
    }
    else
    {
        return -1;
    }

    return 0;
}


bool CClient::connectToServer(QString strHostName,   QString strPort,        bool bUseSSL,        bool bUseCert,      QString strCertFile,
                              bool bUsePrivateKey,   QString PrivateKeyFile, bool bUsePassphrase, QString Passphrase, int iFileMode)
{
    // Set initial variables.
    m_aryDirectories.clear();
    m_aryFiles.clear();

    if(m_pData != nullptr) m_pData.reset();
    m_pData      = std::make_unique<QByteArray>();
    if(m_pInt != nullptr)  m_pInt.reset();
    m_pInt       = std::make_unique<qint32>();

    if(!m_Buffers.isEmpty()) m_Buffers.empty();
    m_Buffers.insert(this, m_pData.get());
    if(!m_Sizes.isEmpty())   m_Sizes.empty();
    m_Sizes.insert(this, m_pInt.get());

    // Set parameter for remote server.
    m_HostName       = strHostName;
    m_Port           = strPort;
    m_bUseSSL        = bUseSSL;
    m_bUseSSCert     = bUseCert;
    m_CertFile       = strCertFile;
    m_bUsePrivateKey = bUsePrivateKey;
    m_PrivateKeyFile = PrivateKeyFile;
    m_bUsePassphrase = bUsePassphrase;
    m_Passphrase     = Passphrase;
    m_iFileMode      = iFileMode;

    // Check using SSL.
    if(m_bUseSSL)
    {
        if(!this->supportsSsl())
        {
            m_strErrorMessage = tr("SSL not supported.");
            return false;
        }

        QObject::connect(this, &QSslSocket::readyRead, this, &CClient::Read);
        QObject::connect(this, QOverload<const QList<QSslError> &>::of(&QSslSocket::sslErrors), this, &CClient::SSLErrors);
    }
    else
    {
        QObject::connect(this, &QSslSocket::readyRead, this, &CClient::Read);
        QObject::connect(this, &QSslSocket::errorOccurred, this, &CClient::SocketErr);
    }

    auto ok = false;
    auto iPort = m_Port.toInt(&ok, 10);
    if(!ok)
    {
        iPort = 61060;
    }

    if(m_bUseSSL)
    {   // SSL conection.
        // Get default settings.
        auto SSLConfig    = QSslConfiguration::defaultConfiguration();
        auto certificates = SSLConfig.caCertificates();

        // Use server certificate.
        if(m_bUseSSL)
        {   // Load certificate (server certificate).
            certificates.append(QSslCertificate::fromPath(m_CertFile, QSsl::Pem, QSslCertificate::PatternSyntax::FixedString));
        }

        // Add to certificate store.
        SSLConfig.setCaCertificates(certificates);

        // Use private key.
        if(m_bUsePrivateKey)
        {   // Load private key.
            QByteArray data = {};
            QFile File(m_PrivateKeyFile);
            if(File.open(QFile::ReadOnly))
            {
                data = File.readAll();
                QSslKey SSLKey(data, QSsl::KeyAlgorithm::Rsa, QSsl::EncodingFormat::Pem, QSsl::KeyType::PrivateKey);

                // Use passphrase.
                if(m_bUsePassphrase)
                {   // Load passphrase.
                    SSLKey.toPem(m_Passphrase.toUtf8());
                }

                // Add to private key store.
                SSLConfig.setPrivateKey(SSLKey);
            }
            else
            {
                m_strErrorMessage = tr("Failed to load private key.");
                return false;
            }
        }

        // SSL protocol version setting.
        SSLConfig.setProtocol(QSsl::TlsV1_3OrLater);

        // Reflects SSL setting.
        this->setSslConfiguration(SSLConfig);

        // Connect to server with SSL.
        // (This is similar to calling connectToHost() to establish connection and then calling startClientEncryption().)
        this->connectToHostEncrypted(m_HostName, iPort);
        if(!this->waitForEncrypted(5000))
        {
            this->abort();

            m_strErrorMessage = tr("SSL/TLS session failed to establish.") + QString("<br>") +
                                this->errorString() + QString("<br>");

            return false;
        }
        else
        {
            emit serverConnected();

            // Display server certificates.
#ifdef _DEBUG
            const auto &Cert = this->peerCertificate();
            QString strMessage = tr("Server certificate : ") + Cert.toText() + QString("\n");
            QTextStream ts(stderr);
            ts << strMessage;
            ts.flush();
#endif
        }
    }
    else
    {   // TCP conection.
        // Connect to server.
        this->connectToHost(m_HostName, iPort);
        if(!this->waitForConnected(5000))
        {
            this->abort();

            m_strErrorMessage = tr("TCP session failed to establish.") + QString("\n") +
                                this->errorString() + QString("\n");

            return false;
        }
        else
        {
            emit serverConnected();

            // Display server with TCP.
#ifdef _DEBUG
            const auto Address = this->peerAddress().toString();
            QString strMessage = tr("Server connect : ") + Address + QString("\n");
            QTextStream ts(stderr);
            ts << strMessage;
            ts.flush();
#endif
        }
    }

    return true;
}


// Disconnect from server.
void CClient::disConnectFromServer()
{
    this->abort();
    this->disconnectFromHost();
    this->close();
    this->deleteLater();

    QObject::disconnect(this, &QSslSocket::readyRead, this, &CClient::Read);
    if(m_bUseSSL)
    {
        QObject::disconnect(this, QOverload<const QList<QSslError> &>::of(&QSslSocket::sslErrors), this, &CClient::SSLErrors);
    }
    else
    {
        QObject::disconnect(this, &QSslSocket::errorOccurred, this, &CClient::SocketErr);
    }
}


// Recieve data from remote server.
void CClient::Read()
{
    QByteArray Data = {};

    auto *pSocket = reinterpret_cast<CClient *>(sender());

    auto buffer = m_Buffers.value(pSocket);
    auto s      = m_Sizes.value(pSocket);
    auto size   = *s;

    while(this->bytesAvailable() > 0)
    {
        buffer->append(pSocket->readAll());

        // Process data.
        while ((size == 0 && buffer->size() >= 4) || (size > 0 && buffer->size() >= size))
        {
            // If data size has received completely, then store it on our global variable.
            if (size == 0 && buffer->size() >= 4)
            {
                size = ArrayToInt(buffer->mid(0, 4));
                *s = size;
                buffer->remove(0, 4);
            }

            // If data has received completely, then emit signal with the data.
            if (size > 0 && buffer->size() >= size)
            {
                Data = buffer->mid(0, size);
                buffer->remove(0, size);
                size = 0;
                *s = size;

                ReciveData(Data);
            }
        }
    }

    return;
}


// Send command to remote server.
int CClient::writeToServer(const QString &strCommand, int iCommandNumber)
{
    m_iCommandNumber = iCommandNumber;

    QByteArray data = strCommand.toUtf8();

    if(this->state() == QAbstractSocket::ConnectedState)
    {
        // Send size of data.
        this->write(IntToArray(data.size()));
        if(!this->waitForBytesWritten(5000))
        {
            return -1;
        }

        // Send the data itself.
        this->write(data);
        if(!this->waitForBytesWritten(5000))
        {
            return -1;
        }
    }
    else
    {
        return 0;
    }

    return 0;
}


// Process data.
void CClient::ReciveData(QByteArray data)
{
    if(m_iCommandNumber == 0)
    {   // Search directories and sshd_config file.
        auto strData = QString::fromUtf8(data);

        // Check error.
        auto aryStatus = strData.split("\\\\//", Qt::KeepEmptyParts, Qt::CaseSensitive).mid(0, 2);
        if(aryStatus.at(0).compare("error", Qt::CaseSensitive) == 0)
        {   // If error.
            if(aryStatus.at(1).isEmpty())  aryStatus[1] = tr("Unknown error.");
            emit readError(aryStatus.at(1));

            return;
        }

        // Split directories and files.
        auto aryData = strData.split("\\@\\/@/", Qt::KeepEmptyParts, Qt::CaseSensitive);

        // Get Directories.
        auto aryDirectories = aryData.at(0).split("\\\\//");
        m_aryDirectories    = aryDirectories.mid(1, aryDirectories.length() - 1);
        for(auto i = 0; i < m_aryDirectories.length(); i++)
        {
            if(m_aryDirectories.at(i).isEmpty())
            {
                m_aryDirectories.removeAt(i);
                i--;
            }
        }

        // Get files.
        m_aryFiles = aryData.at(1).split("\\\\//");
        for(auto i = 0; i < m_aryFiles.length(); i++)
        {
            if(m_aryFiles.at(i).isEmpty())
            {
                m_aryFiles.removeAt(i);
                i--;
            }
        }

        emit readDirectory();
    }
    else if(m_iCommandNumber == 1)
    {   // Download "sshd_config" file.
        auto strData = QString::fromUtf8(data);
        auto aryData = strData.split("\\\\//", Qt::KeepEmptyParts, Qt::CaseSensitive);

        if(aryData.at(0).compare("error", Qt::CaseSensitive) == 0)
        {
            if(aryData.at(1).isEmpty())  aryData[1] = tr("Unknown error.");
            emit readError(aryData.at(1));

            return;
        }

        emit readSSHFile(aryData.at(0));
    }
    else if(m_iCommandNumber == 2)
    {   // Reload "sshd_config" file.
        auto strData = QString::fromUtf8(data);
        auto aryData = strData.split("\\\\//", Qt::KeepEmptyParts, Qt::CaseSensitive);

        if(aryData.at(0).compare("error", Qt::CaseSensitive) == 0)
        {
            if(aryData.at(1).isEmpty())  aryData[1] = tr("Unknown error.");
            emit readError(aryData.at(1));

            return;
        }

        emit reloadSSHFile(aryData.at(0));
    }
    else if(m_iCommandNumber == 3)
    {   // Serach Key files.
        auto strData = QString::fromUtf8(data);

        // Check error.
        auto aryStatus = strData.split("\\\\//", Qt::KeepEmptyParts, Qt::CaseSensitive).mid(0, 2);
        if(aryStatus.at(0).compare("error", Qt::CaseSensitive) == 0)
        {
            if(aryStatus.at(1).isEmpty())  aryStatus[1] = tr("Unknown error.");
            emit readError(aryStatus.at(1));

            return;
        }

        // Split directories and files.
        auto aryData = strData.split("\\@\\/@/", Qt::KeepEmptyParts, Qt::CaseSensitive);

        // Get Directories.
        auto aryDirectories = aryData.at(0).split("\\\\//");
        m_aryDirectories    = aryDirectories.mid(1, aryDirectories.length() - 1);
        for(auto i = 0; i < m_aryDirectories.length(); i++)
        {
            if(m_aryDirectories.at(i).isEmpty())
            {
                m_aryDirectories.removeAt(i);
                i--;
            }
        }

        // Get files.
        m_aryFiles = aryData.at(1).split("\\\\//");
        for(auto i = 0; i < m_aryFiles.length(); i++)
        {
            if(m_aryFiles.at(i).isEmpty())
            {
                m_aryFiles.removeAt(i);
                i--;
            }
        }

        emit readDirectory();
    }
    else if(m_iCommandNumber == 4)
    {   // Execute sshd command.
        auto strSSHDResult = QString::fromUtf8(data);
        auto aryData = strSSHDResult.split("\\\\//", Qt::KeepEmptyParts, Qt::CaseSensitive);

        int iRet = 0;
        if(aryData.at(0).compare("error", Qt::CaseSensitive) == 0)
        {
            if(aryData.at(1).isEmpty())  aryData[1] = tr("Unknown error.");
            strSSHDResult = aryData.at(1);
            iRet = -1;
        }

        emit readSSHDCommand(iRet, strSSHDResult);
    }
    else if(m_iCommandNumber == 5 || m_iCommandNumber == 9)
    {   // Start or Reload ssh(d).service.
        auto strSSH = QString::fromUtf8(data);

        auto aryData = strSSH.split("\\\\//", Qt::KeepEmptyParts, Qt::CaseSensitive);
        if(aryData.at(0).compare("error", Qt::CaseSensitive) == 0)
        {   // Error.
            emit readSSH(-1);
        }

        auto ok = false;
        auto iSSH = strSSH.toInt(&ok, 10);
        if(!ok)
        {
            iSSH = -1;
        }

        emit readSSH(iSSH);
    }
    else if(m_iCommandNumber == 6)
    {   // Restart ssh(d).service.
        auto strSSHStatus = QString::fromUtf8(data);

        auto aryData = strSSHStatus.split("\\\\//", Qt::KeepEmptyParts, Qt::CaseSensitive);
        if(aryData.at(0).compare("error", Qt::CaseSensitive) == 0)
        {   // Error.
            emit readSSHStatus(-1);
        }

        int iStatus = 0;
        if(strSSHStatus.compare("running", Qt::CaseSensitive) == 0)
        {
            iStatus = 0;
        }
        else
        {
            iStatus = -1;
        }

        emit readSSHStatus(iStatus);
    }
    else if(m_iCommandNumber == 7)
    {   // Stop ssh(d).service.
        auto strSSHStatus = QString::fromUtf8(data);

        auto aryData = strSSHStatus.split("\\\\//", Qt::KeepEmptyParts, Qt::CaseSensitive);
        if(aryData.at(0).compare("error", Qt::CaseSensitive) == 0)
        {   // Error.
            emit readSSHStatus(-1);
        }

        int iStatus = 0;
        if(strSSHStatus.compare("stop", Qt::CaseSensitive) == 0)
        {
            iStatus = 1;
        }
        else
        {
            iStatus = -1;
        }

        emit readSSHStatus(iStatus);
    }
    else if(m_iCommandNumber == 8)
    {   // Get status ssh(d).service.
        auto strSSHStatus = QString::fromUtf8(data);

        auto aryData = strSSHStatus.split("\\\\//", Qt::KeepEmptyParts, Qt::CaseSensitive);
        if(aryData.at(0).compare("error", Qt::CaseSensitive) == 0)
        {   // Error.
            emit readSSHStatus(-1);
        }

        int iStatus = 0;
        if(strSSHStatus.compare("running", Qt::CaseSensitive) == 0)
        {
            iStatus = 0;
        }
        else if(strSSHStatus.compare("stop", Qt::CaseSensitive) == 0)
        {
            iStatus = 1;
        }
        else
        {
            iStatus = -1;
        }

        emit readSSHStatus(iStatus);
    }
    else if(m_iCommandNumber == 10)
    {   // Search directories and sshd_config file.
        auto strData = QString::fromUtf8(data);

        // Check error.
        auto aryStatus = strData.split("\\\\//", Qt::KeepEmptyParts, Qt::CaseSensitive).mid(0, 2);
        if(aryStatus.at(0).compare("error", Qt::CaseSensitive) == 0)
        {
            if(aryStatus.at(1).isEmpty())  aryStatus[1] = tr("Unknown error.");
            emit readError(aryStatus.at(1));

            return;
        }

        // Split directories and files.
        auto aryData = strData.split("\\\\//", Qt::KeepEmptyParts, Qt::CaseSensitive);

        // Get Directories.
        m_aryDirectories = aryData.mid(1, aryData.length() - 1);
        for(auto i = 0; i < m_aryDirectories.length(); i++)
        {
            if(m_aryDirectories.at(i).isEmpty())
            {
                m_aryDirectories.removeAt(i);
                i--;
            }
        }

        emit readDirectory();
    }
    else if(m_iCommandNumber == 11)
    {   // Upload sshd_config file.
        auto strData = QString::fromUtf8(data);
        auto aryData = strData.split("\\\\//", Qt::KeepEmptyParts, Qt::CaseSensitive);

        if(aryData.at(0).compare("error", Qt::CaseSensitive) == 0)
        {
            if(aryData.at(1).isEmpty())  aryData[1] = tr("Unknown error.");
            emit uploadedSSHFile(-1, aryData.at(1));

            return;
        }

        emit uploadedSSHFile(0, "");
    }

    return;
}


// Get directories.
QStringList CClient::directories()
{
    return m_aryDirectories;
}


// Get files.
QStringList CClient::files()
{
    return m_aryFiles;
}


// Convert integer to QByteArray.
QByteArray CClient::IntToArray(qint32 source) //Use qint32 to ensure that the number have 4 bytes
{
    //Avoid use of cast, this is the Qt way to serialize objects
    QByteArray temp = {};
    QDataStream data(&temp, QIODevice::ReadWrite);
    data << source;

    return temp;
}


// Convert QByteArray to integer.
qint32 CClient::ArrayToInt(QByteArray source)
{
    qint32 temp;
    QDataStream data(&source, QIODevice::ReadWrite);
    data >> temp;

    return temp;
}


// Get TCP connect errors.
void CClient::SocketErr(QAbstractSocket::SocketError socketError)
{
    auto *pSocket = reinterpret_cast<QTcpSocket*>(sender());

    switch(socketError)
    {
        case QAbstractSocket::RemoteHostClosedError:
        {
            QString strHostAddress  = pSocket->QAbstractSocket::peerAddress().toString();
            QString strStateMessage = tr("Client [%1] disconnected.").arg(strHostAddress) + QString("\n");
            QTextStream ts(stderr);
            ts << strStateMessage;
            ts.flush();

            break;
        }
        default:
        {
            QString strErrorMessage = tr("Error Name : %1").arg(socketError) + QString("\n") + pSocket->errorString() + QString("\n");
            QTextStream ts(stderr);
            ts << strErrorMessage;
            ts.flush();

            break;
        }
    }
}

// Get TCP/SSL connect errors.
void CClient::SSLErrors(const QList<QSslError> &errors)
{
    foreach(const auto &error, errors)
    {
        m_strErrorMessage = tr("SSL error : %1").arg(error.error()) + QString("\n") + error.errorString() + QString("\n");
        QTextStream ts(stderr);
        ts << m_strErrorMessage;
        ts.flush();
    }
}


void CClient::sslErrorOccured(const QList<QSslError> &error)
{
    auto *pSocket = reinterpret_cast<QSslSocket*>(sender());
    pSocket->ignoreSslErrors(error);
}


void CClient::Show(QByteArray data, QString strHostAddress)
{
    QString strMessage = QString::fromUtf8(data) + QString(" from ") + strHostAddress + QString("\n");
    QTextStream ts(stderr);
    ts << strMessage;
    ts.flush();
}


// Get error message.
QString CClient::getErrorMessage()
{
    return m_strErrorMessage;
}
