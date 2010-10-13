/*
 *   Copyright 2008 Chani Armitage <chani@kde.org>
 *   Copyright 2008, 2009 Aaron Seigo <aseigo@kde.org>
 *   Copyright 2010 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#ifndef APPLETINTERFACE_H
#define APPLETINTERFACE_H

#include <QAbstractAnimation>
#include <QObject>
#include <QSizePolicy>
#include <QScriptValue>

#include <Plasma/Applet>
#include <Plasma/PopupApplet>
#include <Plasma/DataEngine>
#include <Plasma/Theme>

#include "abstractjsappletscript.h"

class QAction;
class QmlAppletScript;
class QSignalMapper;
class QSizeF;


namespace Plasma
{
    class ConfigLoader;
    class Extender;
} // namespace Plasa

class AppletInterface : public QObject
{
    Q_OBJECT
    Q_ENUMS(FormFactor)
    Q_ENUMS(Location)
    Q_ENUMS(AspectRatioMode)
    Q_ENUMS(BackgroundHints)
    Q_ENUMS(QtOrientation)
    Q_ENUMS(QtModifiers)
    Q_ENUMS(QtAnchorPoint)
    Q_ENUMS(QtCorner)
    Q_ENUMS(QtSizePolicy)
    Q_ENUMS(QtAlignment)
    Q_ENUMS(QtMouseButton)
    Q_ENUMS(AnimationDirection)
    Q_ENUMS(IntervalAlignment)
    Q_ENUMS(ThemeColors)
    Q_PROPERTY(AspectRatioMode aspectRatioMode READ aspectRatioMode WRITE setAspectRatioMode)
    Q_PROPERTY(FormFactor formFactor READ formFactor NOTIFY formFactorChanged)
    Q_PROPERTY(Location location READ location NOTIFY locationChanged)
    Q_PROPERTY(QString currentActivity READ currentActivity NOTIFY contextChanged)
    Q_PROPERTY(bool shouldConserveResources READ shouldConserveResources)
    Q_PROPERTY(QString activeConfig WRITE setActiveConfig READ activeConfig)
    Q_PROPERTY(bool busy WRITE setBusy READ isBusy)
    Q_PROPERTY(BackgroundHints backgroundHints WRITE setBackgroundHints READ backgroundHints)
    Q_PROPERTY(bool immutable READ immutable NOTIFY immutableChanged)
    Q_PROPERTY(bool userConfiguring READ userConfiguring) // @since 4.5
    Q_PROPERTY(int apiVersion READ apiVersion CONSTANT)
    Q_PROPERTY(QRectF rect READ rect)
    Q_PROPERTY(QSizeF size READ size)
#ifdef USE_JS_SCRIPTENGINE
    Q_PROPERTY(QGraphicsLayout *layout WRITE setLayout READ layout)
    Q_PROPERTY(QObject *sender READ sender)
#endif

public:
    AppletInterface(AbstractJsAppletScript *parent);
    ~AppletInterface();

//------------------------------------------------------------------
//enums copy&pasted from plasma.h because qtscript is evil

enum FormFactor {
    Planar = 0,  /**< The applet lives in a plane and has two
                    degrees of freedom to grow. Optimize for
                    desktop, laptop or tablet usage: a high
                    resolution screen 1-3 feet distant from the
                    viewer. */
    MediaCenter, /**< As with Planar, the applet lives in a plane
                    but the interface should be optimized for
                    medium-to-high resolution screens that are
                    5-15 feet distant from the viewer. Sometimes
                    referred to as a "ten foot interface".*/
    Horizontal,  /**< The applet is constrained vertically, but
                    can expand horizontally. */
    Vertical     /**< The applet is constrained horizontally, but
                    can expand vertically. */
};

enum Location {
    Floating = 0, /**< Free floating. Neither geometry or z-ordering
                     is described precisely by this value. */
    Desktop,      /**< On the planar desktop layer, extending across
                     the full screen from edge to edge */
    FullScreen,   /**< Full screen */
    TopEdge,      /**< Along the top of the screen*/
    BottomEdge,   /**< Along the bottom of the screen*/
    LeftEdge,     /**< Along the left side of the screen */
    RightEdge     /**< Along the right side of the screen */
};

enum AspectRatioMode {
    InvalidAspectRatioMode = -1, /**< Unsetted mode used for dev convenience
                                    when there is a need to store the
                                    aspectRatioMode somewhere */
    IgnoreAspectRatio = 0,       /**< The applet can be freely resized */
    KeepAspectRatio = 1,         /**< The applet keeps a fixed aspect ratio */
    Square = 2,                  /**< The applet is always a square */
    ConstrainedSquare = 3,       /**< The applet is no wider (in horizontal
                                    formfactors) or no higher (in vertical
                                    ones) than a square */
    FixedSize = 4                /** The applet cannot be resized */
};

//From Qt namespace
enum QtModifiers {
    QtNoModifier = Qt::NoModifier,
    QtShiftModifier = Qt::ShiftModifier,
    QtControlModifier = Qt::ControlModifier,
    QtAltModifier = Qt::AltModifier,
    QtMetaModifier = Qt::MetaModifier
};

enum QtOrientation {
    QtHorizontal= Qt::Horizontal,
    QtVertical = Qt::Vertical
};

enum QtAnchorPoint {
    QtAnchorLeft = Qt::AnchorLeft,
    QtAnchorRight = Qt::AnchorRight,
    QtAnchorBottom = Qt::AnchorBottom,
    QtAnchorTop = Qt::AnchorTop,
    QtAnchorHorizontalCenter = Qt::AnchorHorizontalCenter,
    QtAnchorVerticalCenter = Qt::AnchorVerticalCenter
};

enum QtCorner {
    QtTopLeftCorner = Qt::TopLeftCorner,
    QtTopRightCorner = Qt::TopRightCorner,
    QtBottomLeftCorner = Qt::BottomLeftCorner,
    QtBottomRightCorner = Qt::BottomRightCorner
};

enum QtSizePolicy {
    QSizePolicyFixed = QSizePolicy::Fixed,
    QSizePolicyMinimum = QSizePolicy::Minimum,
    QSizePolicyMaximum = QSizePolicy::Maximum,
    QSizePolicyPreferred = QSizePolicy::Preferred,
    QSizePolicyExpanding = QSizePolicy::Expanding,
    QSizePolicyMinimumExpanding = QSizePolicy::MinimumExpanding,
    QSizePolicyIgnored = QSizePolicy::Ignored
};

enum BackgroundHints {
    NoBackground = Plasma::Applet::NoBackground,
    StandardBackground = Plasma::Applet::StandardBackground,
    TranslucentBackground = Plasma::Applet::TranslucentBackground,
    DefaultBackground = Plasma::Applet::DefaultBackground
};

enum ThemeColors {
    TextColor = Plasma::Theme::TextColor,
    HighlightColor = Plasma::Theme::HighlightColor,
    BackgroundColor = Plasma::Theme::BackgroundColor,
    ButtonTextColor = Plasma::Theme::ButtonTextColor,
    ButtonBackgroundColor = Plasma::Theme::ButtonBackgroundColor,
    LinkColor = Plasma::Theme::LinkColor,
    VisitedLinkColor = Plasma::Theme::VisitedLinkColor
};

enum QtAlignment {
    QtAlignLeft = 0x0001,
    QtAlignRight = 0x0002,
    QtAlignHCenter = 0x0004,
    QtAlignJustify = 0x0005,
    QtAlignTop = 0x0020,
    QtAlignBottom = 0x0020,
    QtAlignVCenter = 0x0080
};

enum QtMouseButton {
    QtNoButton = Qt::NoButton,
    QtLeftButton = Qt::LeftButton,
    QtRightButton = Qt::RightButton,
    QtMidButton = Qt::MidButton,
    QtXButton1 = Qt::XButton1,
    QtXButton2 = Qt::XButton2
};

enum QtScrollBarPolicy {
    QtScrollBarAsNeeded = Qt::ScrollBarAsNeeded,
    QtScrollBarAlwaysOff = Qt::ScrollBarAlwaysOff,
    QtScrollBarAlwaysOn = Qt::ScrollBarAlwaysOn
};

enum AnimationDirection {
    AnimationForward = QAbstractAnimation::Forward,
    AnimationBackward = QAbstractAnimation::Backward
};

enum IntervalAlignment {
    NoAlignment = 0,
    AlignToMinute,
    AlignToHour
};
//-------------------------------------------------------------------

    Q_INVOKABLE void gc();
    Q_INVOKABLE FormFactor formFactor() const;

    Location location() const;
    QString currentActivity() const;
    bool shouldConserveResources() const;

    Q_INVOKABLE AspectRatioMode aspectRatioMode() const;
    Q_INVOKABLE void setAspectRatioMode(AspectRatioMode mode);

    Q_INVOKABLE void setFailedToLaunch(bool failed, const QString &reason = QString());

    Q_INVOKABLE bool isBusy() const;
    Q_INVOKABLE void setBusy(bool busy);

    Q_INVOKABLE BackgroundHints backgroundHints() const;
    Q_INVOKABLE void setBackgroundHints(BackgroundHints hint);

    Q_INVOKABLE void setConfigurationRequired(bool needsConfiguring, const QString &reason = QString());

    Q_INVOKABLE QSizeF size() const;
    Q_INVOKABLE QRectF rect() const;

    Q_INVOKABLE void setAction(const QString &name, const QString &text,
                               const QString &icon = QString(), const QString &shortcut = QString());

    Q_INVOKABLE void removeAction(const QString &name);

    Q_INVOKABLE void resize(qreal w, qreal h);

    Q_INVOKABLE void setMinimumSize(qreal w, qreal h);

    Q_INVOKABLE void setPreferredSize(qreal w, qreal h);

    Q_INVOKABLE QString activeConfig() const;

    Q_INVOKABLE void setActiveConfig(const QString &name);

    Q_INVOKABLE QScriptValue readConfig(const QString &entry) const;

    Q_INVOKABLE void writeConfig(const QString &entry, const QVariant &value);

    Q_INVOKABLE QString file(const QString &fileType);
    Q_INVOKABLE QString file(const QString &fileType, const QString &filePath);

    Q_INVOKABLE bool include(const QString &script);

    Q_INVOKABLE void debug(const QString &msg);
    Q_INVOKABLE QObject *findChild(const QString &name) const;

    Q_INVOKABLE Plasma::Extender *extender() const;

#ifdef USE_JS_SCRIPTENGINE
    Q_INVOKABLE void update(const QRectF &rect = QRectF());
    QGraphicsLayout *layout() const;
    void setLayout(QGraphicsLayout *);
#endif

    Plasma::DataEngine *dataEngine(const QString &name);

    QList<QAction*> contextualActions() const;
    bool immutable() const;
    bool userConfiguring() const;
    int apiVersion() const;

    static AppletInterface *extract(QScriptEngine *engine);
    inline Plasma::Applet *applet() const { return m_appletScriptEngine->applet(); }

Q_SIGNALS:
    void releaseVisualFocus();
    void configNeedsSaving();

    void formFactorChanged();
    void locationChanged();
    void contextChanged();
    void immutableChanged();

protected:
    AbstractJsAppletScript *m_appletScriptEngine;

private:
    QSet<QString> m_actions;
    QSignalMapper *m_actionSignals;
    QString m_currentConfig;
    QMap<QString, Plasma::ConfigLoader*> m_configs;
};

class PopupAppletInterface : public AppletInterface
{
    Q_OBJECT
    Q_PROPERTY(QIcon popupIcon READ popupIcon WRITE setPopupIcon)
    Q_PROPERTY(bool passivePopup READ isPassivePopup WRITE setPassivePopup)
    Q_PROPERTY(QGraphicsWidget *popupWidget READ popupWidget WRITE setPopupWidget)

public:
    PopupAppletInterface(AbstractJsAppletScript *parent);

    void setPopupIcon(const QIcon &icon);
    QIcon popupIcon();

    inline Plasma::PopupApplet *popupApplet() const { return static_cast<Plasma::PopupApplet *>(m_appletScriptEngine->applet()); }

    void setPassivePopup(bool passive);
    bool isPassivePopup() const;

    void setPopupWidget(QGraphicsWidget *widget);
    QGraphicsWidget *popupWidget();

public Q_SLOTS:
    void setPopupIconByName(const QString &name);
    void togglePopup();
    void hidePopup();
    void showPopup();
};

#endif
