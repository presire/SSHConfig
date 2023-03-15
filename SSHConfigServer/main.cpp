#include <QCoreApplication>
#include <QTextStream>
#include <QTimer>
#include "CUIRunner.h"


int main(int argc, char *argv[])
{
    QCoreApplication app(argc, argv);
    auto Args = app.arguments();

    // Start runner.
    CUIRunner runner(argc, argv);
    QTimer::singleShot(0, &runner, &CUIRunner::run);

    return app.exec();
}
