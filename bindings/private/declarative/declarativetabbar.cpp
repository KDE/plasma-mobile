 

#include "private/declarative/declarativetabbar_p.h"

TabBarAttached::TabBarAttached(QObject *parent)
    : QObject(parent)
{
}

void TabBarAttached::setTabText(const QString &text)
{
    if (text == m_tabText)
        return;

    m_tabText = text;
    emit tabTextChanged(reinterpret_cast<DeclarativeTabBar*>(parent()), m_tabText);
}

QString TabBarAttached::tabText()const
{
    return m_tabText;
}

DeclarativeTabBar::DeclarativeTabBar(QObject *parent)
  : Plasma::TabBar(qobject_cast<QGraphicsWidget *>(parent))
{}

DeclarativeTabBar::~DeclarativeTabBar()
{}

void DeclarativeTabBar::updateTabText(QGraphicsLayoutItem *item, const QString &text)
{
    for (int i=0; i < count(); ++i) {
        if (item == tabAt(i)) {
            setTabText(i, text);
            break;
        }
    }
}

QHash<QGraphicsLayoutItem*, TabBarAttached*> DeclarativeTabBar::m_attachedProperties;

TabBarAttached *DeclarativeTabBar::qmlAttachedProperties(QObject *obj)
{
    // ### This is not allowed - you must attach to any object
    if (!qobject_cast<QGraphicsLayoutItem*>(obj)) {
        return 0;
    }

    TabBarAttached *attached = new TabBarAttached(obj);
    m_attachedProperties.insert(qobject_cast<QGraphicsLayoutItem*>(obj), attached);
    return attached;
}

#include "declarativetabbar_p.moc"