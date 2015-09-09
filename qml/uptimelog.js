function getDatabase()
{
    return LocalStorage.openDatabaseSync("harbour-batterylog", "1.0", "StorageDatabase", 100000);
}

// -----------------------------------------------------------------------

function init()
{
    // create tables
    getDatabase().transaction(function(tx)
    {
        tx.executeSql("CREATE TABLE IF NOT EXISTS uptime_log(time DATE PRIMARY KEY, duration BIGINT, continuous SMALLINT)");
    });
}

// -----------------------------------------------------------------------

function reset()
{
    getDatabase().transaction(function(tx)
    {
        tx.executeSql("DROP TABLE uptime_log");
    });
    init();
}

// -----------------------------------------------------------------------

function addEntry(startTime, continous)
{
    var currentDate = new Date(Date.now());
    var duration = Math.round((currentDate - startTime) / 1000);

    getDatabase().transaction(function(tx)
    {
        var result = tx.executeSql("INSERT INTO uptime_log VALUES (?,?,?);", [startTime, duration, continous]);
        if (result.rowsAffected === 0)
        {
            return false;
        }
    });
    var cleanupTime = new Date(Date.now());
    cleanupTime.setDate(cleanupTime.getDate() - 100);
    getDatabase().transaction(function(tx)
    {
        var result = tx.executeSql("DELETE FROM uptime_log WHERE time < ?;", [cleanupTime]);
    });
    return true;
}

// -----------------------------------------------------------------------

function getLatestEntries(dayCount)
{
    var timeValues       = [];
    var durationValues   = [];
    var continuousValues = [];

    var startTime = new Date(Date.now());
    startTime.setDate(startTime.getDate() - dayCount);

    // fetch latest stored entries
    getDatabase().transaction(function(tx)
    {
        var result = tx.executeSql("SELECT time,duration,continuous FROM uptime_log WHERE time > ? ORDER BY time;", [startTime]);
        for(var idx = 0; idx < result.rows.length; idx++)
        {
            timeValues.push(result.rows.item(idx).time);
            durationValues.push(result.rows.item(idx).duration);
            continuousValues.push(result.rows.item(idx).continuous);
        }
    });

    return [timeValues, durationValues, continuousValues];
}

// -----------------------------------------------------------------------

function getAverageUptime(dayCount)
{
    var startTime = new Date(Date.now());
    startTime.setDate(startTime.getDate() - dayCount);

    var averageUptime = 0.0;

    // fetch latest stored entries
    getDatabase().transaction(function(tx)
    {
        var result = tx.executeSql("SELECT duration FROM uptime_log WHERE time > ? and continuous = ?;", [startTime, true]);
        if (result.rows.length > 1)
        {
            var sum = 0;
            for(var idx = 0; idx < result.rows.length; idx++)
            {
                var duration = result.rows.item(idx).duration;
                sum += duration;
            }
            if (sum > 0)
            {
                averageUptime = Math.round(sum / result.rows.length);
            }
        }
    });
    return averageUptime;
}
