// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include <KConfig>
#include <KSharedConfig>
#include <QObject>

class Settings : public QObject
{
    Q_OBJECT

public:
    Settings(QObject *parent = nullptr);
    static Settings *self();

    bool shouldStartWizard();
    void setWizardFinished();

private:
    KSharedConfig::Ptr m_mobileConfig;
    bool m_isMobilePlatform;
};
