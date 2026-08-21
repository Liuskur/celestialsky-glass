/*
 * Copyright 2016  Christoph Feck <cfeck@kde.org>
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 * NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 */

#ifndef SKELETON_DECORATION_H
#define SKELETON_DECORATION_H 1

#include <KDecoration3/Decoration>
#include <KDecoration3/DecorationButton>

#include <QPointer>
#include <QVariantList>
#include <QVariantMap>

namespace KDecoration3 { class DecorationButtonGroup; }
class QPropertyAnimation;

namespace Skeleton
{

class Decoration : public KDecoration3::Decoration
{
    Q_OBJECT

public:
    explicit Decoration(QObject *parent = nullptr, const QVariantList &args = QVariantList());
    ~Decoration() override;

public:
    bool init() override;
    void paint(QPainter *painter, const QRectF &repaintArea) override;
    void updateHoverAnimation(qreal hoverProgress, const QRect &updateRect);

private:
    void createButtons();
    void deleteButtons();
    void createShadow();

private Q_SLOTS:
    void recreateButtons();
    void updateButtons();
    void updateLayout();

private:
    QRect m_frameRect;
    QRect m_captionRect;
public:
    KDecoration3::DecorationButtonGroup *m_leftButtons;
    KDecoration3::DecorationButtonGroup *m_rightButtons;

    void createPixmaps();
    int buttonSize;
    QPixmap* pinDownPix;
    QPixmap* pinUpPix;
    QPixmap* titlePix;
    QPixmap* rightBtnUpPix[2];
    QPixmap* rightBtnDownPix[2];
    QPixmap* leftBtnUpPix[2];
    QPixmap* leftBtnDownPix[2];
};

class DecorationButton : public KDecoration3::DecorationButton
{
    Q_OBJECT
    Q_PROPERTY(qreal hoverProgress READ hoverProgress WRITE setHoverProgress)

public:
    DecorationButton(KDecoration3::DecorationButtonType type, Decoration *decoration, QObject *parent = nullptr);
    ~DecorationButton() override;

public:
    void paint(QPainter *painter, const QRectF &repaintArea) override;

public:
    qreal hoverProgress() const;
    void setHoverProgress(qreal hoverProgress);

private:
    void startHoverAnimation(qreal endValue);

private:
    QPointer<QPropertyAnimation> m_hoverAnimation;
    qreal m_hoverProgress;

public:
    void setBitmap(const unsigned char *bitmap);
    QPainterPath* deco;
    Decoration *d;
    KDecoration3::DecorationButtonGroup *b;
};

class ThemeLister : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariantMap themes READ themes)

public:
    explicit ThemeLister(QObject *parent = nullptr, const QVariantList &args = QVariantList())
        : QObject(parent)
    {
        Q_UNUSED(args)
    }

    ~ThemeLister() override
    {
    }

public:
    QVariantMap themes() const;
};

} // namespace Skeleton

#endif // SKELETON_DECORATION_H

