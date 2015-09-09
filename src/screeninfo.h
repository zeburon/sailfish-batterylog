#ifndef SCREENINFO_H
#define SCREENINFO_H

#include <QObject>
#include <QString>

#include "infobase.h"

// -----------------------------------------------------------------------

class ScreenInfo : public QObject, public InfoBase
{
    Q_OBJECT

    Q_PROPERTY(bool on READ isOn NOTIFY signalOnChanged)

public:
    explicit ScreenInfo(QObject *parent = 0);
    virtual ~ScreenInfo();

    Q_INVOKABLE void update();

    bool isOn() const { return m_on; }

signals:
    void signalOnChanged();

private:
    static const QString BASE_PATH;
    static const QString FILENAME_BRIGHTNESS;

    void updateOn();

    bool m_on;

};

#endif // SCREENINFO_H
