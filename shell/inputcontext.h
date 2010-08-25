

#ifndef INPUTCONTEXT_H
#define INPUTCONTEXT_H

#include <QtGui/QInputContext>

class LocalPlasmaKeyboardInterface;

class InputContext : public QInputContext
{
    Q_OBJECT

public:
    InputContext();
    ~InputContext();

    bool filterEvent(const QEvent* event);

    QString identifierName();
    QString language();

    bool isComposing() const;

    void reset();

private:
    LocalPlasmaKeyboardInterface *m_keyboard;
};



#endif
