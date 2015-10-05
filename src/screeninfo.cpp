#include "screeninfo.h"

// -----------------------------------------------------------------------

const QString ScreenInfo::BASE_PATH           = "/sys/class/leds/lcd-backlight/";
const QString ScreenInfo::FILENAME_BRIGHTNESS = "brightness";

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
    bool new_on = readFileAsInteger(BASE_PATH + FILENAME_BRIGHTNESS) > 0;
    if (new_on != m_on)
    {
        m_on = new_on;
        emit signalOnChanged();
    }
}
