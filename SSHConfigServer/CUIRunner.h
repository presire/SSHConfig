#pragma once

#include <QObject>
#include <QCoreApplication>
#include <QLocale>
#include <QTranslator>


class CUIRunner : public QCoreApplication
{
   Q_OBJECT

private:
    QStringList m_Args;
    QString     m_strSysConf;
    QTranslator m_Translator;

public:

private:

public:
    CUIRunner(int argc, char *argv[]);
    explicit CUIRunner(QString arg);
    virtual ~CUIRunner();

public slots:
   void run();  // runスロットメソッド内部でメイン処理を実行する
};
