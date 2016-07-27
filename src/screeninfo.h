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
    static const QString BASE_PATH_SYSFS;
    static const QString FILENAME_SYSFS_BRIGHTNESS;

    static const QString BASE_PATH_STATEFS;
    static const QString FILENAME_STATEFS_BLANKED;

    void updateOn();

    bool m_on;

};

#endif // SCREENINFO_H
