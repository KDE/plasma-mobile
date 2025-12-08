// SPDX-FileCopyrightText: 2025 Sebastian Kügler <sebas@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QObject>
#include <kscreen/config.h>
#include <qqmlregistration.h>

class KScreenOSDUtil : public QObject
{
    Q_OBJECT
    QML_SINGLETON
    Q_PROPERTY(int outputs READ outputs WRITE setOutputs NOTIFY outputsChanged);

public:
    KScreenOSDUtil(QObject *parent = nullptr);

    Q_INVOKABLE void showKScreenOSD();

    int outputs() const;
    void setOutputs(int _outputs);

Q_SIGNALS:
    void outputsChanged();

private:
    void retrieveKScreen();

    KScreen::ConfigPtr m_config{nullptr};
    int m_outputs{0};

};
