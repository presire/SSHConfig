#include <QCoreApplication>
#include "SSHConfigHelper.h"


int main(int argc, char *argv[])
{
    QCoreApplication a(argc, argv);

    SSHConfigHelper ClientHelper(argc, argv);

    return a.exec();
}
