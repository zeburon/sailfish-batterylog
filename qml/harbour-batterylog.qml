import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.batterylog.BatteryInfo 1.0
import harbour.batterylog.ScreenInfo 1.0

import "components"
import "cover"
import "pages"

ApplicationWindow
{
    id: app

    // -----------------------------------------------------------------------

    property bool active: Qt.application.state === Qt.ApplicationActive
    property bool initialized: false

    // -----------------------------------------------------------------------

    cover: coverPage
    initialPage: mainPage

    // -----------------------------------------------------------------------

    Component.onCompleted:
    {
        settings.loadValues();
        batteryInfo.update();
        screenInfo.update();
        logs.init();
        eventPage.init();
        settingsPage.init();
        mainPage.refreshDrawings();
        coverPage.refreshDrawings();

        settingsPage.lineColorsModified.connect(mainPage.refreshDrawings);
        settingsPage.lineColorsModified.connect(coverPage.refreshDrawings);
        logs.capacityUpdated.connect(mainPage.refreshDrawings);
        logs.capacityUpdated.connect(coverPage.refreshDrawings);
        logs.energyEventAdded.connect(mainPage.refreshDrawings);
        logs.energyEventAdded.connect(coverPage.refreshDrawings);
        logs.energyEventAdded.connect(eventPage.addItem);

        settings.startStoringValueChanges();
        initialized = true;
    }

    // -----------------------------------------------------------------------

    Settings
    {
        id: settings
    }
    BatteryInfo
    {
        id: batteryInfo
    }
    ScreenInfo
    {
        id: screenInfo
    }
    Logs
    {
        id: logs
    }

    MainPage
    {
        id: mainPage
    }
    EventPage
    {
        id: eventPage
    }
    SettingsPage
    {
        id: settingsPage
    }
    AboutPage
    {
        id: aboutPage
    }

    CoverPage
    {
        id: coverPage
    }
}
