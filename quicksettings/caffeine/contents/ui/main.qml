/*
 *   SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import org.kde.plasma.private.mobileshell.quicksettingsplugin as QS
import org.kde.plasma.plasma5support 2.0 as P5Support

QS.QuickSetting {
    text: i18n("Caffeine")
    icon: "system-suspend-hibernate"
    status: enabled ? i18n("Tap to disable sleep suspension") : i18n("Tap to suspend sleep")
    enabled: false

    P5Support.DataSource {
        id: pmSource
        engine: "powermanagement"
        connectedSources: sources
        onSourceAdded: source => {
            disconnectSource(source);
            connectSource(source);
        }
        onSourceRemoved: source => {
            disconnectSource(source);
        }
    }

    property int cookie1: -1
    property int cookie2: -1

    function toggle() {
        let inhibit = !enabled;
        const service = pmSource.serviceForSource("PowerDevil");
        if (inhibit) {
            const reason = i18n("Plasma Mobile has enabled system-wide inhibition");
            const op1 = service.operationDescription("beginSuppressingSleep");
            op1.reason = reason;
            const op2 = service.operationDescription("beginSuppressingScreenPowerManagement");
            op2.reason = reason;

            const job1 = service.startOperationCall(op1);
            job1.finished.connect(job => {
                cookie1 = job.result;
            });

            const job2 = service.startOperationCall(op2);
            job2.finished.connect(job => {
                cookie2 = job.result;
            });
        } else {
            const op1 = service.operationDescription("stopSuppressingSleep");
            op1.cookie = cookie1;
            const op2 = service.operationDescription("stopSuppressingScreenPowerManagement");
            op2.cookie = cookie2;

            const job1 = service.startOperationCall(op1);
            job1.finished.connect(job => {
                cookie1 = -1;
            });

            const job2 = service.startOperationCall(op2);
            job2.finished.connect(job => {
                cookie2 = -1;
            });

        }
        enabled = inhibit;
    }
}

