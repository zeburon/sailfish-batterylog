#include "batteryinfo.h"

// -----------------------------------------------------------------------

const QString BatteryInfo::BASE_PATH_SYSFS                   = "/sys/class/power_supply/battery/";
const QString BatteryInfo::FILENAME_SYSFS_CAPACITY           = "capacity";
const QString BatteryInfo::FILENAME_SYSFS_CURRENT            = "current_now";
const QString BatteryInfo::FILENAME_SYSFS_VOLTAGE            = "voltage_now";
const QString BatteryInfo::FILENAME_SYSFS_ENERGY             = "energy_now";
const QString BatteryInfo::FILENAME_SYSFS_ENERGY_FULL        = "energy_full";
const QString BatteryInfo::FILENAME_SYSFS_ENERGY_FULL_DESIGN = "energy_full_design";
const QString BatteryInfo::FILENAME_SYSFS_STATUS             = "status";
const QString BatteryInfo::FILENAME_SYSFS_HEALTH             = "health";

const QString BatteryInfo::BASE_PATH_BATTERY_BMS_FILE        = "/sys/class/power_supply/battery/subsystem/bms/uevent";
const QString BatteryInfo::FILENAME_SYSFS_CHARGE             = "POWER_SUPPLY_CHARGE_NOW_RAW";
const QString BatteryInfo::FILENAME_SYSFS_CHARGE_FULL        = "POWER_SUPPLY_CHARGE_FULL";
const QString BatteryInfo::FILENAME_SYSFS_CHARGE_FULL_DESIGN = "POWER_SUPPLY_CHARGE_FULL_DESIGN";

const QString BatteryInfo::OS_RELEASE_FILE                   = "/etc/os-release";
const QString BatteryInfo::OS_VERSION_STRING                 = "VERSION_ID";

const QString BatteryInfo::BASE_PATH_STATEFS                 = "/run/state/namespaces/Battery/";
const QString BatteryInfo::FILENAME_STATEFS_CAPACITY         = "ChargePercentage";
const QString BatteryInfo::FILENAME_STATEFS_CURRENT          = "Current";
const QString BatteryInfo::FILENAME_STATEFS_VOLTAGE          = "Voltage";
const QString BatteryInfo::FILENAME_STATEFS_ENERGY           = "Energy";
const QString BatteryInfo::FILENAME_STATEFS_ENERGY_FULL      = "EnergyFull";
const QString BatteryInfo::FILENAME_STATEFS_STATUS           = "State";

const QString BatteryInfo::UNKNOWN_STATUS                    = "Unknown";
const QString BatteryInfo::UNKNOWN_HEALTH                    = "Unknown";

// -----------------------------------------------------------------------

BatteryInfo::BatteryInfo(QObject *parent) :
    QObject(parent), m_valid(false), m_capacity(0), m_current(0), m_voltage(0), m_energy(0), m_energy_full(0),
    m_energy_full_design(0), m_status(UNKNOWN_STATUS), m_health(UNKNOWN_HEALTH)
{
    m_os_version = get_value(OS_RELEASE_FILE, OS_VERSION_STRING).split(".")[0].toInt();
    if(m_os_version == 0)
        m_os_version = 4;
}

// -----------------------------------------------------------------------

BatteryInfo::~BatteryInfo()
{
}

// -----------------------------------------------------------------------

void BatteryInfo::update()
{
    updateCapacity();
    updateCurrent();
    updateVoltage();
    updateEnergy();
    updateStatus();
    updateHealth();
    updateValidity();
}

// -----------------------------------------------------------------------

void BatteryInfo::updateCapacity()
{
    int new_capacity = 0;
    if (readFileAsInteger(BASE_PATH_SYSFS + FILENAME_SYSFS_CAPACITY, new_capacity) || readFileAsInteger(BASE_PATH_STATEFS + FILENAME_STATEFS_CAPACITY, new_capacity))
    {
        if (new_capacity != m_capacity)
        {
            m_capacity = new_capacity;
            emit signalCapacityChanged();
        }
    }
}

// -----------------------------------------------------------------------

void BatteryInfo::updateCurrent()
{
    int new_current = 0;
    if (readFileAsInteger(BASE_PATH_SYSFS + FILENAME_SYSFS_CURRENT, new_current) || readFileAsInteger(BASE_PATH_STATEFS + FILENAME_STATEFS_CURRENT, new_current))
    {
        new_current = qRound(new_current / 1000.0f);
        if (new_current != m_current)
        {
            m_current = new_current;
            emit signalCurrentChanged();
        }
    }
}

// -----------------------------------------------------------------------

void BatteryInfo::updateVoltage()
{
    int new_voltage = 0;
    if (readFileAsInteger(BASE_PATH_SYSFS + FILENAME_SYSFS_VOLTAGE, new_voltage) || readFileAsInteger(BASE_PATH_STATEFS + FILENAME_STATEFS_VOLTAGE, new_voltage))
    {
        new_voltage = qRound(new_voltage / 1000.0f);
        if (new_voltage != m_voltage)
        {
            m_voltage = new_voltage;
            m_voltage_V = qRound(new_voltage / 1000.0f);
            emit signalVoltageChanged();
        }
    }
}

// -----------------------------------------------------------------------

void BatteryInfo::updateEnergy()
{
    if(m_os_version < 4) {
        // full energy level
        int new_energy_full = 0;
        if (readFileAsInteger(BASE_PATH_SYSFS + FILENAME_SYSFS_ENERGY_FULL, new_energy_full) || readFileAsInteger(BASE_PATH_STATEFS + FILENAME_STATEFS_ENERGY_FULL, new_energy_full))
        {
            new_energy_full = qRound(new_energy_full / 1000.0f);
            if (new_energy_full != m_energy_full)
            {
                m_energy_full = new_energy_full;
                emit signalEnergyFullChanged();
            }
        }

        // energy level (value for a brand new battery)
        int new_energy_full_design = 0;
        if (readFileAsInteger(BASE_PATH_SYSFS + FILENAME_SYSFS_ENERGY_FULL_DESIGN, new_energy_full_design))
            new_energy_full_design = qRound(new_energy_full_design / 1000.0f);
        else
            new_energy_full_design = new_energy_full;

        if (new_energy_full_design != m_energy_full_design)
        {
            m_energy_full_design = new_energy_full_design;
            emit signalEnergyFullDesignChanged();
        }

        // current energy level
        int new_energy = 0;
        if (readFileAsInteger(BASE_PATH_SYSFS + FILENAME_SYSFS_ENERGY, new_energy) || readFileAsInteger(BASE_PATH_STATEFS + FILENAME_STATEFS_ENERGY, new_energy))
            new_energy = qRound(new_energy / 1000.0f);
        else
            new_energy = m_energy_full * m_capacity / 100.0f;

        if (new_energy > new_energy_full)
            new_energy = m_energy_full * m_capacity / 100.0f;

        if (new_energy != m_energy)
        {
            m_energy = new_energy;
            emit signalEnergyChanged();
        }

    }
    else 
    {
        // full energy level
        int new_energy_full = 0;
        int get_energy = get_value(BASE_PATH_BATTERY_BMS_FILE, FILENAME_SYSFS_CHARGE_FULL).toInt();
        get_energy *= m_voltage_V;
        
        if (get_energy != 0)
        {
            new_energy_full = qRound(get_energy / 1000.0f);
            if (new_energy_full != m_energy_full)
            {
                m_energy_full = new_energy_full;
                emit signalEnergyFullChanged();
            }
        }

        // energy level (value for a brand new battery)
        int new_energy_full_design = 0;
        int get_energy_design = get_value(BASE_PATH_BATTERY_BMS_FILE, FILENAME_SYSFS_CHARGE_FULL_DESIGN).toInt();
        get_energy_design *= m_voltage_V;

        if (get_energy_design != 0)
            new_energy_full_design = qRound(get_energy_design / 1000.0f);
        else
            new_energy_full_design = new_energy_full;

        if (new_energy_full_design != m_energy_full_design)
        {
            m_energy_full_design = new_energy_full_design;
            emit signalEnergyFullDesignChanged();
        }

        // current energy level
        int new_energy = 0;
        int get_energy_now = get_value(BASE_PATH_BATTERY_BMS_FILE, FILENAME_SYSFS_CHARGE).toInt();
        get_energy_now *= m_voltage_V;

        if (get_energy_now != 0)
            new_energy = qRound(get_energy_now / 1000.0f);
        else
            new_energy = m_energy_full * m_capacity / 100.0f;

        if (new_energy > new_energy_full)
            new_energy = m_energy_full * m_capacity / 100.0f;

        if (new_energy != m_energy)
        {
            m_energy = new_energy;
            emit signalEnergyChanged();
        }
    }
}

// -----------------------------------------------------------------------

void BatteryInfo::updateStatus()
{
    QString new_status;
    if (readFileAsString(BASE_PATH_SYSFS + FILENAME_SYSFS_STATUS, new_status) || readFileAsString(BASE_PATH_STATEFS + FILENAME_STATEFS_STATUS, new_status))
    {
        if (new_status.isEmpty())
            new_status = UNKNOWN_STATUS;

        QChar first_letter = new_status[0];
        new_status.remove(0, 1);
        new_status.prepend(first_letter.toUpper());

        if (new_status != m_status)
        {
            m_status = new_status;
            emit signalStatusChanged();
        }
    }
}

// -----------------------------------------------------------------------

void BatteryInfo::updateHealth()
{
    QString new_health;
    readFileAsString(BASE_PATH_SYSFS + FILENAME_SYSFS_HEALTH, new_health);
    if (new_health.isEmpty())
        new_health = UNKNOWN_HEALTH;

    if (new_health != m_health)
    {
        m_health = new_health;
        emit signalHealthChanged();
    }
}

// -----------------------------------------------------------------------

void BatteryInfo::updateValidity()
{
    bool new_valid =
            m_status != UNKNOWN_STATUS &&
            //m_health != UNKNOWN_HEALTH &&
            m_capacity > 0 &&
            m_energy > 0 &&
            m_energy_full > 0 &&
            m_energy_full_design > 0;

    if (new_valid != m_valid)
    {
        m_valid = new_valid;
        emit signalValidChanged();
    }
}
