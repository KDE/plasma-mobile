// LICENSE

#include <KDebug>

#include "phone.h"

Phone::Phone(QObject *parent)
    : QObject(parent)
{
    QDBusConnection connSystemBus = QDBusConnection::systemBus();
    m_dbusPhone = new QDBusInterface("com.nokia.csd.Call", "/com/nokia/csd/call",
                                     "com.nokia.csd.Call", connSystemBus, this);

    m_dbusPhoneInstance = new QDBusInterface("com.nokia.csd.Call", "/com/nokia/csd/call/1",
                                     "com.nokia.csd.Call.Instance", connSystemBus, this);

    connect(m_dbusPhoneInstance, SIGNAL(CallStatus(int)),
            this, SLOT(callStatus(int)));
}

Phone::~Phone()
{
    delete m_dbusPhone;
}

void Phone::call(const QString &number) {
    kDebug()<<"CALLING NUMBER"<<number;
    QList<QVariant> args;
    args << number;
    args << 0;
    m_dbusPhone->callWithCallback("CreateWith", args, this,
                                  SLOT(callReturned()),
                                  SLOT(callError(QDBusError&)));
}

void Phone::hangup()
{
    QList<QVariant> args;
    m_dbusPhone->callWithCallback("Release", args, this,
                                  SLOT(callReturned()));
}

void Phone::callReturned()
{
}

void Phone::callError(QDBusError &error)
{
}

void Phone::callStatus(int value)
{
    // >= 2 (=CSD_CALL_STATUS_COMING)
    if (value >= 2) {
        qWarning() << "----> RECEIVING CALL!!!";
        // answer code?
    }
}

#include "phone.moc"
