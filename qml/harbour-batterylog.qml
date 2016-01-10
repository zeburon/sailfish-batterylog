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

    cover: mainCover
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
        mainCover.refreshDrawings();

        settingsPage.lineColorsModified.connect(mainPage.refreshDrawings);
        settingsPage.lineColorsModified.connect(mainCover.refreshDrawings);
        logs.capacityUpdated.connect(mainPage.refreshDrawings);
        logs.capacityUpdated.connect(mainCover.refreshDrawings);
        logs.energyEventAdded.connect(mainPage.refreshDrawings);
        logs.energyEventAdded.connect(mainCover.refreshDrawings);
        logs.energyEventAdded.connect(eventPage.addItem);
        logs.energyEventsCleared.connect(eventPage.clearItems);

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

    MainCover
    {
        id: mainCover
    }
}
