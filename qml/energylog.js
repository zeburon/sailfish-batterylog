// persistent event-based log. each entry consists of the following values:
// time: time of occurrence
// energy: remaining capacity in kWh
// charging: 0 when discharging, 1 when discharging
// active: 0 when in standby, 1 when screen is turned on
// event: type of event, e.g. "Start", "Stop", "Charging", "Discharging", "Full". empty for periodic updates

// -----------------------------------------------------------------------

var lastTime, lastEnergy, lastCharging, lastActive, lastEvent;
var timeoutIntervalInSeconds;

// -----------------------------------------------------------------------

function getDatabase()
{
    return LocalStorage.openDatabaseSync("harbour-batterylog", "1.0", "StorageDatabase", 100000);
}

// -----------------------------------------------------------------------

function init(newTimeoutIntervalInSeconds)
{
    timeoutIntervalInSeconds = newTimeoutIntervalInSeconds;
    getDatabase().transaction(function(tx)
    {
        tx.executeSql("CREATE TABLE IF NOT EXISTS energy_log(time DATE PRIMARY KEY, energy BIGINT, charging SMALLINT, active SMALLINT, event TEXT)");
    });
}

// -----------------------------------------------------------------------

function cleanup(maximumDays)
{
    var cleanupTime = new Date(Date.now());
    cleanupTime.setDate(cleanupTime.getDate() - maximumDays);
    getDatabase().transaction(function(tx)
    {
        var result = tx.executeSql("DELETE FROM energy_log WHERE time < ?;", [cleanupTime]);
    });
}

// -----------------------------------------------------------------------

function reset()
{
    getDatabase().transaction(function(tx)
    {
        var result = tx.executeSql("DELETE FROM energy_log;");
    });
}

// -----------------------------------------------------------------------

function addOrUpdateEntry(energy, charging, active, event)
{
    var currentTime = new Date(Date.now());

    // same event twice in a row: no need to create a new event, just update previous entry
    if (lastEnergy === energy && lastCharging === charging && lastActive === active && lastEvent === event)
    {
        getDatabase().transaction(function(tx)
        {
            var result = tx.executeSql("UPDATE energy_log SET time = ? WHERE time = ?;", [currentTime, lastTime]);
            if (result.rowsAffected === 0)
            {
                console.log("Failed to update previous energy_log entry.");
                return 0;
            }
        });
        lastTime = currentTime;
        return 0;
    }

    // check if we missed a standby event
    // our own timer is unable to wake the device - we have to rely on other processes
    var elapsedSeconds = (currentTime - lastTime) / 1000;
    if (active && active === lastActive && elapsedSeconds > timeoutIntervalInSeconds)
    {
        var missedTime = new Date(lastTime);
        missedTime.setSeconds(lastTime.getSeconds() + timeoutIntervalInSeconds);
        if (!addEntry(missedTime, lastEnergy, lastCharging, false, lastEvent))
        {
            console.log("Failed to add missing energy_log entry.");
            return 0;
        }
    }

    // create new entry
    if (!addEntry(currentTime, energy, charging, active, event))
    {
        console.log("Failed to add new energy_log entry.");
        return 0;
    }

    // store values for next call
    lastTime     = currentTime;
    lastEnergy   = energy;
    lastCharging = charging;
    lastActive   = active;
    lastEvent    = event;
    return currentTime;
}

// -----------------------------------------------------------------------

function addEntry(time, energy, charging, active, event)
{
    getDatabase().transaction(function(tx)
    {
        var result = tx.executeSql("INSERT INTO energy_log VALUES (?,?,?,?,?);", [time, energy, charging, active, event]);
        if (result.rowsAffected === 0)
        {
            return false;
        }
    });
    return true;
}

// -----------------------------------------------------------------------

function getLatestEntries(dayCount, dayOffset)
{
    var currentTime = new Date(Date.now());
    var startTime   = new Date(Date.now());
    startTime.setDate(startTime.getDate() - dayCount - dayOffset);
    var endTime     = new Date(Date.now());
    endTime.setDate(endTime.getDate() - dayOffset);

    // fetch latest stored entries
    var entries = [];
    getDatabase().transaction(function(tx)
    {
        var result = tx.executeSql("SELECT time,energy,charging,active,event FROM energy_log WHERE time > ? AND time < ? ORDER BY time ASC;", [startTime, endTime]);
        for(var idx = 0; idx < result.rows.length; idx++)
        {
            var time     = new Date(result.rows.item(idx).time);
            time.setMinutes(time.getMinutes() + currentTime.getTimezoneOffset());
            var energy   = result.rows.item(idx).energy;
            var charging = result.rows.item(idx).charging;
            var active   = result.rows.item(idx).active;
            var event    = result.rows.item(idx).event;
            entries.push([time, energy, charging, active, event]);
        }
    });
    return entries;
}

// -----------------------------------------------------------------------

function getLatestEvents(dayCount)
{
    var currentTime = new Date(Date.now());
    var startTime = new Date(Date.now());
    startTime.setDate(startTime.getDate() - dayCount);

    // fetch latest stored entries
    var entries = [];
    var lastEvent;
    getDatabase().transaction(function(tx)
    {
        var result = tx.executeSql("SELECT time,energy,charging,event FROM energy_log WHERE time > ? AND event != '' AND event != 'Stop' ORDER BY time ASC LIMIT 400;", [startTime]);
        for(var idx = 0; idx < result.rows.length; idx++)
        {
            var time = new Date(result.rows.item(idx).time);
            time.setMinutes(time.getMinutes() + currentTime.getTimezoneOffset());
            var energy = result.rows.item(idx).energy;
            var charging = result.rows.item(idx).charging;
            var event = result.rows.item(idx).event;
            if (event !== lastEvent)
            {
                entries.push([time, energy, charging, event]);
                lastEvent = event;
            }
        }
    });
    return entries;
}

// -----------------------------------------------------------------------

function getAveragePower(dayCount)
{
    var startTime = new Date(Date.now());
    startTime.setDate(startTime.getDate() - dayCount);

    var averagePower = 0.0;

    // fetch latest stored entries
    getDatabase().transaction(function(tx)
    {
        var result = tx.executeSql("SELECT time,energy,event FROM energy_log WHERE time > ? and charging = ? ORDER BY time ASC LIMIT 1000;", [startTime, false]);
        if (result.rows.length > 1)
        {
            var sum = 0, duration = 0, lastEnergy = result.rows.item(0).energy, lastTime = new Date(result.rows.item(0).time), lastEvent = result.rows.item(0).event;
            for(var idx = 1; idx < result.rows.length; idx++)
            {
                var time = new Date(result.rows.item(idx).time);
                var energy = result.rows.item(idx).energy;
                var event = result.rows.item(idx).event;
                if (energy <= lastEnergy && lastEvent !== "Stop")
                {
                    sum += lastEnergy - energy;
                    duration += (time - lastTime);
                }

                lastTime = time;
                lastEnergy = energy;
                lastEvent = event;
            }
            if (sum > 0)
            {
                averagePower = Math.round((sum * 3600) / (duration / 1000));
            }
        }
    });
    return averagePower;
}

// -----------------------------------------------------------------------

function getStoredDayCount()
{
    var currentTime = new Date(Date.now());
    var count = 0.0;
    getDatabase().transaction(function(tx)
    {
        var result = tx.executeSql("SELECT time FROM energy_log ORDER BY time ASC LIMIT 1;");
        if (result.rows.length === 1)
        {
            var time = new Date(result.rows.item(0).time);
            time.setMinutes(time.getMinutes() + currentTime.getTimezoneOffset());

            count = (currentTime - time) / 1000 / 3600 / 24;
        }
    });
    return count;
}

// -----------------------------------------------------------------------

function getStoredEventCount()
{
    var count = 0;
    getDatabase().transaction(function(tx)
    {
        var result = tx.executeSql("SELECT COUNT(*) AS count FROM energy_log;");
        if (result.rows.length === 1)
        {
            count = result.rows.item(0).count;
        }
    });
    return count;
}
