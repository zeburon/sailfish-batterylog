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
        batteryInfo.update();
        screenInfo.update();
        logs.init();
        eventPage.init();
        mainPage.refreshDrawings();
        coverPage.refreshDrawings();
        logs.capacityUpdated.connect(mainPage.refreshDrawings);
        logs.capacityUpdated.connect(coverPage.refreshDrawings);
        logs.energyEventAdded.connect(mainPage.refreshDrawings);
        logs.energyEventAdded.connect(coverPage.refreshDrawings);
        logs.energyEventAdded.connect(eventPage.addItem);

        initialized = true;
    }

    // -----------------------------------------------------------------------

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
    AboutPage
    {
        id: aboutPage
    }

    CoverPage
    {
        id: coverPage
    }
}
