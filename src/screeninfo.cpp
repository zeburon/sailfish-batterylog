#include "screeninfo.h"

// -----------------------------------------------------------------------

const QString ScreenInfo::BASE_PATH_SYSFS           = "/sys/class/leds/lcd-backlight/";
const QString ScreenInfo::BASE_PATH_STATEFS         = "/run/state/namespaces/Screen/";
const QString ScreenInfo::FILENAME_SYSFS_BRIGHTNESS = "brightness";
const QString ScreenInfo::FILENAME_STATEFS_BLANKED  = "Blanked";

// -----------------------------------------------------------------------

ScreenInfo::ScreenInfo(QObject *parent) :
    QObject(parent), m_on(false)
{
}

// -----------------------------------------------------------------------

ScreenInfo::~ScreenInfo()
{
}

// -----------------------------------------------------------------------

void ScreenInfo::update()
{
    updateOn();
}

// -----------------------------------------------------------------------

void ScreenInfo::updateOn()
{
    // try to read sysfs brightness ...
    bool new_on = false;
    int brightness = 0, blanked = 0;
    if (readFileAsInteger(BASE_PATH_SYSFS + FILENAME_SYSFS_BRIGHTNESS, brightness))
        new_on = brightness > 0;
    // ... or blanked statefs state
    else if (readFileAsInteger(BASE_PATH_STATEFS + FILENAME_STATEFS_BLANKED, blanked))
        new_on = blanked == 0;

    if (new_on != m_on)
    {
        m_on = new_on;
        emit signalOnChanged();
    }
}
