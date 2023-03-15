#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include <QSettings>
#include <QIcon>
#include <QLocale>
#include <QTranslator>
#include <QMessageBox>
#include "CWindowState.h"
#include "CSSHServer.h"
#include "CSSHValue.h"
#include "CSSHService.h"
#include "CSSHTest.h"


int main(int argc, char *argv[])
{
    //qputenv("QT_QUICK_CONTROLS_STYLE", QByteArray("Material"));
    //qputenv("QT_QUICK_CONTROLS_MATERIAL_THEME", QByteArray("Dark"));

#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif
    QApplication app(argc, argv);

// Get the name of the user under which it is running.
// If it is the root user, display a warning.
#ifdef Q_OS_LINUX
    QString RunUser = "";
    QProcess Proc;
    QObject::connect(&Proc, static_cast<void(QProcess::*)(int, QProcess::ExitStatus)>(&QProcess::finished),
                     [&Proc, &RunUser]([[maybe_unused]] int exitCode, [[maybe_unused]] QProcess::ExitStatus exitStatus) {
                        RunUser = QString::fromLocal8Bit(Proc.readAllStandardOutput());
                        RunUser.replace("\n", "");
                    });
    Proc.start("whoami", QStringList({}));
    Proc.waitForFinished();

    if(RunUser.compare("root", Qt::CaseSensitive) == 0)
    {
        auto ret = QMessageBox(QMessageBox::Warning, QMessageBox::tr("Security Risks"),
                               QMessageBox::tr("Running SSHConfig as root can be dangerous.\nPlease be careful."),
                               QMessageBox::Ok | QMessageBox::Cancel, nullptr).exec();
        if(ret == QMessageBox::Cancel)
        {
            app.quit();
            return 0;
        }
    }
#endif

    app.setOrganizationName("SSHConfig");
    //app.setOrganizationDomain("Presire");
    app.setApplicationName("SSHConfig");

    // Select language.
    QTranslator translator;
    auto iLang = CWindowState::getLanguage();
    if(iLang == 1)
    {
        translator.load(":/i18n/SSHConfig_ja_JP.qm");
        app.installTranslator(&translator);
    }

    // Set SSHConfig's Icon
    app.setWindowIcon(QIcon(":/Image/SSHConfig.png"));

    QSettings settings;
    bool bColorMode = CWindowState::getColorMode();
    if (bColorMode)
    {
        QQuickStyle::setStyle("Material");
    }
    else
    {
        QQuickStyle::setStyle("Universal");
    }

    // Register the class so that it can be used in QML
    qmlRegisterType<CWindowState>("WindowState", 1, 0, "CWindowState");
    qmlRegisterType<CSSHServer>("SSHServer", 1, 0, "CSSHServer");
    qmlRegisterType<CSSHService>("SSHService", 1, 0, "CSSHService");
    qmlRegisterType<CSSHValue>("SSHValue", 1, 0, "CSSHValue");
    qmlRegisterType<CSSHTest>("SSHTest", 1, 0, "CSSHTest");

    QQmlApplicationEngine engine;

#ifdef PINEPHONE
    const QUrl url(QStringLiteral("qrc:/PP/SSHConfigMainPP.qml"));
#else
    const QUrl url(QStringLiteral("qrc:/SSHConfigMain.qml"));
#endif

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
