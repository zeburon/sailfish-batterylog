// persistent application settings
// start saving value changes as soon as init process is completed

// -----------------------------------------------------------------------

var finishedLoading = false;

// -----------------------------------------------------------------------

function startInit()
{
    getDatabase().transaction(function(tx)
    {
        tx.executeSql('CREATE TABLE IF NOT EXISTS settings(name TEXT UNIQUE, value TEXT)');
    });
}

// -----------------------------------------------------------------------

function finishInit()
{
    finishedLoading = true;
}

// -----------------------------------------------------------------------

function destroyData()
{
    getDatabase().transaction(function(tx)
    {
        tx.executeSql('DROP TABLE settings');
    });
}

// -----------------------------------------------------------------------

function getDatabase()
{
    return LocalStorage.openDatabaseSync("harbour-batterylog", "1.0", "StorageDatabase", 100000);
}

// -----------------------------------------------------------------------

function setValue(name, value)
{
    if (!finishedLoading)
    {
        // ignore value changes as long as app is still loading
        return false;
    }

    getDatabase().transaction(function(tx)
    {
        var result = tx.executeSql('INSERT OR REPLACE INTO settings VALUES (?,?);', [name, value.toString()]);
        if (result.rowsAffected === 0)
        {
            return false;
        }
    });
    return true;
}

// -----------------------------------------------------------------------

function getValue(name)
{
    var value = "";
    getDatabase().transaction(function(tx)
    {
        var result = tx.executeSql('SELECT value FROM settings WHERE name=?;', [name]);
        if (result.rows.length > 0)
        {
            value = result.rows.item(0).value;
        }
    });
    return value;
}
