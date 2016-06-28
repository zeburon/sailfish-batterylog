import QtQuick 2.0
import QtQuick.LocalStorage 2.0

import "../globals.js" as Globals
import "../energylog.js" as EnergyLog
import "../powerlog.js" as PowerLog
import "../timeformat.js" as TimeFormat

Item
{
    property bool initialized: false
    property bool energyLogWorking: true

    property real power: batteryInfo.current * batteryInfo.voltage / 1000 // [mW]
    property real energy: batteryInfo.energy // [mWh]
    property int capacity: batteryInfo.capacity // [0% - 100%]
    property bool charging: batteryInfo.status === "Full" || batteryInfo.status === "Charging"
    property bool full: batteryInfo.status === "Full"
    property string status: batteryInfo.status
    property bool active: screenInfo.on

    // trend: based on values gathered by PowerLog in the last minute
    property int averagePowerTrend
    property string remainingMinutesTrend
    property string remainingTimeTrendShort
    property string remainingTimeTrendLong

    // prognosis: based on values gathered by EnergyLog in the last 24 hours
    property int averagePowerPrognosis
    property string remainingMinutesPrognosis
    property string remainingTimePrognosisShort
    property string remainingTimePrognosisLong

    property string remainingMinutesFullPrognosis
    property string remainingTimeFullPrognosisShort
    property string remainingTimeFullPrognosisLong

    // -----------------------------------------------------------------------

    signal averagePowerUpdated()
    signal averageEnergyUpdated()
    signal energyEventAdded(var time, int energy, int charging, string event)
    signal energyEventsCleared()
    signal capacityUpdated()

    // -----------------------------------------------------------------------

    function init()
    {
        PowerLog.init();
        addPowerEntryAndRestartTimer();

        EnergyLog.init(Globals.UPDATE_ENERGY_INTERVAL * 2);
        addEnergyEntryAndRestartTimer("Start");
        addEnergyEntryAndRestartTimer(status);

        initialized = true;
    }

    function updateAveragePower()
    {
        averagePowerTrend = (full ? 0.0 : PowerLog.getAveragePower());
        remainingMinutesTrend = getRemainingMinutes(averagePowerTrend);
        remainingTimeTrendShort = TimeFormat.getShortTimeString(remainingMinutesTrend);
        remainingTimeTrendLong = TimeFormat.getLongTimeString(remainingMinutesTrend);

        averagePowerUpdated();
    }

    function updateAverageEnergy()
    {
        averagePowerPrognosis = EnergyLog.getAveragePower(1);

        // switch to averagePowerTrend if averagePowerPrognosis is not available
        if (averagePowerPrognosis < 1 && !charging)
            averagePowerPrognosis = averagePowerTrend;

        remainingMinutesPrognosis = getRemainingMinutes(averagePowerPrognosis);
        remainingTimePrognosisShort = TimeFormat.getShortTimeString(remainingMinutesPrognosis);
        remainingTimePrognosisLong = TimeFormat.getLongTimeString(remainingMinutesPrognosis);

        remainingMinutesFullPrognosis = getRemainingMinutesDischargingFull(averagePowerPrognosis);
        remainingTimeFullPrognosisShort = TimeFormat.getShortTimeString(remainingMinutesFullPrognosis);
        remainingTimeFullPrognosisLong = TimeFormat.getLongTimeString(remainingMinutesFullPrognosis);

        averageEnergyUpdated();
    }

    function addPowerEntryAndRestartTimer()
    {
        PowerLog.addEntry(power);
        updateAveragePower();
        updatePowerTimer.start();
    }

    function addEnergyEntryAndRestartTimer(event)
    {
        var eventTime = EnergyLog.addOrUpdateEntry(energy, charging, active, event);
        if (initialized && eventTime !== 0)
        {
            energyEventAdded(eventTime, energy, charging, event);

            if (event === "")
                cleanupEnergyEntries();

            energyLogWorking = true;
        }
        else if (initialized && eventTime === 0)
        {
            energyLogWorking = false;
        }

        updateAverageEnergy();
        updateEnergyTimer.start();
    }

    function cleanupEnergyEntries()
    {
        EnergyLog.cleanup(settings.energyLogDayCount);
    }

    function clearEnergyEntries()
    {
        EnergyLog.reset();
        energyEventsCleared();

        addEnergyEntryAndRestartTimer("Start");
        addEnergyEntryAndRestartTimer(status);
    }

    function getRemainingMinutes(averagePower)
    {
        // charging
        if (averagePower < 0.0)
            return Math.round(60.0 * ((batteryInfo.energyFull - batteryInfo.energy) / Math.abs(averagePower)));
        // discharging
        else if (averagePower > 0.0)
            return Math.round(60.0 * (batteryInfo.energy / averagePower));

        return 0.0;
    }

    function getRemainingMinutesDischargingFull(averagePower)
    {
        return Math.round(60.0 * (batteryInfo.energyFull / averagePower));
    }

    function getLatestEnergyEntries(dayCount, dayOffset)
    {
        return EnergyLog.getLatestEntries(dayCount, dayOffset);
    }

    function getLatestEnergyEvents(dayCount)
    {
        return EnergyLog.getLatestEvents(dayCount);
    }

    function getCurrentEnergyEventCount()
    {
        return EnergyLog.getStoredEventCount();
    }

    function getCurrentEnergyDayCount()
    {
        return EnergyLog.getStoredDayCount();
    }

    // -----------------------------------------------------------------------

    onStatusChanged:
    {
        if (!initialized)
            return;

        addEnergyEntryAndRestartTimer(status);
    }
    onActiveChanged:
    {
        if (!initialized)
            return;

        addEnergyEntryAndRestartTimer("");
    }
    onCapacityChanged:
    {
        if (!initialized)
            return;

        capacityUpdated();
    }
    Component.onDestruction:
    {
        // note: this piece code is not called reliably
        addEnergyEntryAndRestartTimer("Stop");
    }

    // -----------------------------------------------------------------------

    Timer
    {
        id: updatePowerTimer

        interval: Globals.UPDATE_POWER_INTERVAL * 1000
        repeat: false
        onTriggered: {
            screenInfo.update();
            batteryInfo.update();
            addPowerEntryAndRestartTimer();
        }
    }
    Timer
    {
        id: updateEnergyTimer

        interval: Globals.UPDATE_ENERGY_INTERVAL * 1000
        repeat: false
        onTriggered: {
            screenInfo.update();
            batteryInfo.update();

            // only manually add new event if updates have not already generated a event
            if (!running)
                addEnergyEntryAndRestartTimer("");
        }
    }
}
