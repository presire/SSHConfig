#include "CRemoteWindow.h"
#include "../SSHConfig/CWindowState.h"


CRemoteWindow::CRemoteWindow(QObject *parent) : QObject(parent), m_pQMLEngine(nullptr), m_pComponent(nullptr), m_pObject(nullptr)
{
    // Register the class so that it can be used in QML
    qmlRegisterType<CWindowState>("WindowState", 1, 0, "CWindowState");
    qmlRegisterType<CClient>("ClientSession", 1, 0, "CClient");

    auto iLang = CWindowState::getLanguage();
    if(iLang == 1)
    {
        auto pApp = QCoreApplication::instance();
        if(m_Translator.load(":/i18n/RemoteWindow_ja_JP.qm"))
        {
            pApp->installTranslator(&m_Translator);
        }
    }
}


CRemoteWindow::~CRemoteWindow()
{
    m_pQMLEngine.reset();
    m_pComponent.reset();
    m_pObject.reset();
}


int CRemoteWindow::GetSSHDConfigFile(int width, int height, bool bDark, int fontPadding)
{
    // Initialize component.
    m_pQMLEngine.reset();
    m_pComponent.reset();
    m_pObject.reset();

    // Load QML file.
    m_pQMLEngine = std::make_unique<QQmlApplicationEngine>(QtQml::qmlEngine(this));

#ifdef PINEPHONE
    const QUrl url(QStringLiteral("qrc:/PP/MainPP.qml"));
#else
    const QUrl url(QStringLiteral("qrc:/Main.qml"));
#endif

    m_pComponent = std::make_unique<QQmlComponent>(m_pQMLEngine.get(), url);

#ifdef PINEPHONE
    width  = width > height ? 812 : 375;
    height = width > height ? 375 : 812;
    m_pObject.reset(m_pComponent->createWithInitialProperties({{"viewWidth", width}, {"viewHeight", height},
                                                               {"bDark", bDark}, {"fontPadding", fontPadding},
                                                               {"fileMode", 0}}));
#else
    m_pObject.reset(m_pComponent->createWithInitialProperties({{"viewWidth", width}, {"viewHeight", height},
                                                               {"bDark", bDark}, {"fontPadding", fontPadding},
                                                               {"fileMode", 0}}));
#endif

    // Set RemoteWindow icon.
    auto RootWindow = qobject_cast<QQuickWindow*>(m_pObject.get());
    if(RootWindow != nullptr)
    {
        RootWindow->setIcon(QIcon(":/Image/RemoteWindow.png"));
    }

    QObject::connect(m_pObject.get(), SIGNAL(setRemoteInfo(QString,QString,bool,bool,QString,bool,QString,bool,QString)),
                     this,            SLOT(setRemoteInfo(QString,QString,bool,bool,QString,bool,QString,bool,QString)));
    QObject::connect(m_pObject.get(), SIGNAL(downloadSSHFile(QString,QString)),
                     this,            SIGNAL(downloadSSHFile(QString,QString)));

    if(!m_pObject)
    {
        return -1;
    }

    return 0;
}


int CRemoteWindow::ReloadSSHDConfigFile(bool bDark, int fontPadding, const QString &RemoteFilePath)
{
    // Initialize component.
    m_pQMLEngine.reset();
    m_pComponent.reset();
    m_pObject.reset();

    // Load QML file.
    m_pQMLEngine = std::make_unique<QQmlApplicationEngine>(QtQml::qmlEngine(this));

#ifdef PINEPHONE
    const QUrl url(QStringLiteral("qrc:/PP/ReloadPP.qml"));
#else
    const QUrl url(QStringLiteral("qrc:/Reload.qml"));
#endif

    m_pComponent = std::make_unique<QQmlComponent>(m_pQMLEngine.get(), url);

#ifdef PINEPHONE
    m_pObject.reset(m_pComponent->createWithInitialProperties({
                                                               {"bDark", bDark}, {"fontPadding", fontPadding}, {"fileMode", 0},
                                                               {"hostName", m_strHostName}, {"port", m_strPort}, {"bUseSSL", m_bUseSSL},
                                                               {"bUseCert", m_bUseCert}, {"certFile", m_strCertFile},
                                                               {"bUsePrivateKey", m_bUsePrivateKey}, {"privateKeyFile", m_strPrivateKey},
                                                               {"bUsePassphrase", m_bUsePassphrase}, {"passphrase", m_strPassphrase},
                                                               {"sshdFile", RemoteFilePath}
                                                              }));
#else
    m_pObject.reset(m_pComponent->createWithInitialProperties({
                                                               {"bDark", bDark}, {"fontPadding", fontPadding}, {"fileMode", 0},
                                                               {"hostName", m_strHostName}, {"port", m_strPort}, {"bUseSSL", m_bUseSSL},
                                                               {"bUseCert", m_bUseCert}, {"certFile", m_strCertFile},
                                                               {"bUsePrivateKey", m_bUsePrivateKey}, {"privateKeyFile", m_strPrivateKey},
                                                               {"bUsePassphrase", m_bUsePassphrase}, {"passphrase", m_strPassphrase},
                                                               {"sshdFile", RemoteFilePath}
                                                              }));
#endif

    // Set RemoteWindow icon.
    auto RootWindow = qobject_cast<QQuickWindow*>(m_pObject.get());
    if(RootWindow != nullptr)
    {
        RootWindow->setIcon(QIcon(":/Image/RemoteWindow.png"));
    }

    QObject::connect(m_pObject.get(), SIGNAL(reloadSSHFile(QString,QString)),
                     this,            SIGNAL(reloadSSHFile(QString,QString)));

    if(!m_pObject)
    {
        return -1;
    }

    return 0;
}


void CRemoteWindow::setRemoteInfo(QString strHostName, QString strPort, bool bUseSSL, bool bUseCert, QString strCertFile,
                                  bool bUsePrivateKey, QString strPrivateKey, bool bUsePassphrase, QString strPassphrase)
{
    m_strHostName    = strHostName;
    m_strPort        = strPort;
    m_bUseSSL        = bUseSSL;
    m_bUseCert       = bUseCert;
    m_strCertFile    = strCertFile;
    m_bUsePrivateKey = bUsePrivateKey;
    m_strPrivateKey  = strPrivateKey;
    m_bUsePassphrase = bUsePassphrase;
    m_strPassphrase  = strPassphrase;

    return;
}


int CRemoteWindow::GetKeyFile(int width, int height, bool bDark, int fontPadding, int KeyType)
{
    // Initialize component.
    m_pQMLEngine.reset();
    m_pComponent.reset();
    m_pObject.reset();

    // Load QML file.
    m_pQMLEngine = std::make_unique<QQmlApplicationEngine>(QtQml::qmlEngine(this));

#ifdef PINEPHONE
    const QUrl url(QStringLiteral("qrc:/PP/MainPP.qml"));
#else
    const QUrl url(QStringLiteral("qrc:/Main.qml"));
#endif

    m_pComponent = std::make_unique<QQmlComponent>(m_pQMLEngine.get(), url);

#ifdef PINEPHONE
    width  = width > height ? 812 : 375;
    height = width > height ? 375 : 812;
    m_pObject.reset(m_pComponent->createWithInitialProperties({{"viewWidth", width}, {"viewHeight", height}, {"bDark", bDark}, {"fontPadding", fontPadding},
                                                               {"fileMode", 1}, {"keyType", KeyType}}));
#else
    m_pObject.reset(m_pComponent->createWithInitialProperties({{"viewWidth", width}, {"viewHeight", height}, {"bDark", bDark}, {"fontPadding", fontPadding},
                                                               {"fileMode", 1}, {"keyType", KeyType}}));
#endif

    // Set RemoteWindow icon.
    auto RootWindow = qobject_cast<QQuickWindow*>(m_pObject.get());
    if(RootWindow != nullptr)
    {
        RootWindow->setIcon(QIcon(":/Image/RemoteWindow.png"));
    }

    QObject::connect(m_pObject.get(), SIGNAL(getHostKey(QString)), this, SIGNAL(getHostKey(QString)));
    QObject::connect(m_pObject.get(), SIGNAL(getAuthorizedKey(QString)), this, SIGNAL(getAuthorizedKey(QString)));

    if(!m_pObject)
    {
        return -1;
    }

    return 0;
}


// Get path to  directory in remote server.
int CRemoteWindow::GetDirectory(int width, int height, bool bDark, int fontPadding, int DirectoryType)
{
    // Initialize component.
    m_pQMLEngine.reset();
    m_pComponent.reset();
    m_pObject.reset();

    // Load QML file.
    m_pQMLEngine = std::make_unique<QQmlApplicationEngine>(QtQml::qmlEngine(this));

#ifdef PINEPHONE
    const QUrl url(QStringLiteral("qrc:/PP/MainPP.qml"));
#else
    const QUrl url(QStringLiteral("qrc:/Main.qml"));
#endif

    m_pComponent = std::make_unique<QQmlComponent>(m_pQMLEngine.get(), url);

#ifdef PINEPHONE
    width  = width > height ? 812 : 375;
    height = width > height ? 375 : 812;
    m_pObject.reset(m_pComponent->createWithInitialProperties({{"viewWidth", width}, {"viewHeight", height}, {"bDark", bDark},
                                                               {"fontPadding", fontPadding},
                                                               {"bDirectory", true}, {"directoryType", DirectoryType}}));
#else
    m_pObject.reset(m_pComponent->createWithInitialProperties({{"viewWidth", width}, {"viewHeight", height}, {"bDark", bDark},
                                                               {"fontPadding", fontPadding},
                                                               {"bDirectory", true}, {"directoryType", DirectoryType}}));
#endif

    // Set RemoteWindow icon.
    auto RootWindow = qobject_cast<QQuickWindow*>(m_pObject.get());
    if(RootWindow != nullptr)
    {
        RootWindow->setIcon(QIcon(":/Image/RemoteWindow.png"));
    }

    QObject::connect(m_pObject.get(), SIGNAL(getDirectory(int,QString)), this, SIGNAL(getDirectory(int,QString)));

    if(!m_pObject)
    {
        return -1;
    }

    return 0;
}


// Execute sshd command on remote server.
int CRemoteWindow::ExecRemoteSSHDCommand(const QString &strExecuteCommand)
{
    // Initialize.
    if(m_pClient != nullptr)
    {
        m_pClient.reset();
    }

    m_pClient = std::make_unique<CClient>();

    // Connect remote server.
    auto bRet = m_pClient->connectToServer(m_strHostName,    m_strPort,       m_bUseSSL,        m_bUseCert,      m_strCertFile,
                                           m_bUsePrivateKey, m_strPrivateKey, m_bUsePassphrase, m_strPassphrase, 0);
    if(!bRet)
    {
        return -1;
    }

    // Send sshd command to remote server.
    auto iRet = m_pClient->writeToServer(strExecuteCommand, 4);
    if(iRet != 0)
    {
        return -2;
    }

    QObject::connect(m_pClient.get(), &CClient::readSSHDCommand, this, &CRemoteWindow::sendSSHDResult);

    return 0;
}


// Execute ssh(d).service on remote server.
int CRemoteWindow::ExecRemoteSSHService(int width, int height, bool bDark, int fontPadding, const bool bActionFlag, const bool bStatus)
{
    // Load QML file.
    m_pQMLEngine = std::make_unique<QQmlApplicationEngine>(QtQml::qmlEngine(this));

#ifdef PINEPHONE
    const QUrl url(QStringLiteral("qrc:/PP/AuthForSSHServicePP.qml"));
#else
    const QUrl url(QStringLiteral("qrc:/AuthForSSHService.qml"));
#endif

    m_pComponent = std::make_unique<QQmlComponent>(m_pQMLEngine.get(), url);

#ifdef PINEPHONE
    width  = width > height ? 812 : 375;
    height = width > height ? 375 : 812;
    m_pObject.reset(m_pComponent->createWithInitialProperties({{"viewWidth", width}, {"viewHeight", height}, {"bDark", bDark}, {"fontPadding", fontPadding},
                                                               {"bActionFlag", bActionFlag}, {"bStatus", bStatus}}));
#else
    m_pObject.reset(m_pComponent->createWithInitialProperties({{"viewWidth", width}, {"viewHeight", height}, {"bDark", bDark}, {"fontPadding", fontPadding},
                                                               {"bActionFlag", bActionFlag}, {"bStatus", bStatus}}));
#endif

    // Set RemoteWindow icon.
    auto RootWindow = qobject_cast<QQuickWindow*>(m_pObject.get());
    if(RootWindow != nullptr)
    {
        RootWindow->setIcon(QIcon(":/Image/RemoteWindow.png"));
    }

    QObject::connect(m_pObject.get(), SIGNAL(sendStatus(int)), this, SIGNAL(sendStatus(int)));

    if(!m_pObject)
    {
        return -1;
    }

    return 0;
}


// Upload sshd_config file.
int CRemoteWindow::UploadSSHConfigFile(const QString &strRemoteSSHFile, const QString &strContents)
{
    // Initialize.
    if(m_pClient != nullptr)
    {
        m_pClient.reset();
    }

    m_pClient = std::make_unique<CClient>();

    // Connect remote server.
    auto bRet = m_pClient->connectToServer(m_strHostName,    m_strPort,       m_bUseSSL,        m_bUseCert,      m_strCertFile,
                                           m_bUsePrivateKey, m_strPrivateKey, m_bUsePassphrase, m_strPassphrase, 0);
    if(!bRet)
    {
        m_strErrorMessage = m_pClient->getErrorMessage();
        return -1;
    }

    // Send sshd command to remote server.
    auto strExecuteCommand = QString("push") + QString(" \\\\// ") + strRemoteSSHFile + QString(" \\\\// ") + strContents;
    auto iRet = m_pClient->writeToServer(strExecuteCommand, 11);
    if(iRet != 0)
    {
        m_strErrorMessage = m_pClient->getErrorMessage();
        return -2;
    }

    QObject::connect(m_pClient.get(), &CClient::uploadedSSHFile, this, &CRemoteWindow::uploadedSSHFile);

    return 0;
}


// Get path to sshd_config file on remote server.
QString CRemoteWindow::GetRemoteSSHFile()
{
    return m_strRemoteSSHFile;
}


// Disconnect from remote server.
void CRemoteWindow::DisconnectFromServer()
{
    if(m_pObject != nullptr)    m_pObject.reset();
    if(m_pComponent != nullptr) m_pComponent.reset();
    if(m_pQMLEngine != nullptr) m_pQMLEngine.reset();
    if(m_pClient != nullptr) {
        m_pClient->close();
        //m_pClient->abort();
    }

    return;
}


// Get Error Message.
QString CRemoteWindow::GetErrorMessage()
{
    return m_strErrorMessage;
}
