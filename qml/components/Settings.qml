import QtQuick 2.0
import QtQuick.LocalStorage 2.0

import "../settings.js" as Storage
import "../globals.js" as Globals

QtObject
{
    property int updateInterval: 300;                          property string updateIntervalKey: "updateInterval"

    // -----------------------------------------------------------------------

    function loadValues()
    {
        Storage.startInit();

        // load thinking
        var storedUpdateInterval = Storage.getValue(updateIntervalKey);
        if (storedUpdateInterval)
            updateInterval = storedUpdateInterval;
    }

    // -----------------------------------------------------------------------

    function startStoringValueChanges()
    {
        Storage.finishInit();
    }

    // -----------------------------------------------------------------------

    onUpdateIntervalChanged:
    {
        Storage.setValue(updateIntervalKey, updateInterval);
    }
}
