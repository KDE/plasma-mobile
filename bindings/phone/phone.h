// LICENSE

#ifndef PLASMA_PHONE
#define PLASMA_PHONE

#include <QObject>
#include <QtDBus>
#include <QDBusError>

class Phone : public QObject
{
    Q_OBJECT

public:
    Phone(QObject *parent = 0);
    ~Phone();

public slots:
    void call(const QString &number);
    void hangup();

signals:
    void calling();
    void receiving();

protected slots:
    void callReturned();
    void callError(QDBusError &error);
    void callStatus(int value);

private:
    QDBusInterface *m_dbusPhone;
    QDBusInterface *m_dbusPhoneInstance;
};

#endif
