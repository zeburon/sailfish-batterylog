#include "batteryinfo.h"

// -----------------------------------------------------------------------

const QString BatteryInfo::BASE_PATH                   = "/sys/class/power_supply/battery/";
const QString BatteryInfo::FILENAME_CAPACITY           = "capacity";
const QString BatteryInfo::FILENAME_CURRENT            = "current_now";
const QString BatteryInfo::FILENAME_VOLTAGE            = "voltage_now";
const QString BatteryInfo::FILENAME_ENERGY             = "energy_now";
const QString BatteryInfo::FILENAME_ENERGY_FULL        = "energy_full";
const QString BatteryInfo::FILENAME_ENERGY_FULL_DESIGN = "energy_full_design";
const QString BatteryInfo::FILENAME_STATUS             = "status";
const QString BatteryInfo::FILENAME_HEALTH             = "health";

// -----------------------------------------------------------------------

BatteryInfo::BatteryInfo(QObject *parent) :
    QObject(parent), m_capacity(0), m_current(0), m_voltage(0), m_energy(0), m_energy_full(0), m_energy_full_design(0)
{
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
}

// -----------------------------------------------------------------------

void BatteryInfo::updateCapacity()
{
    int new_capacity = readFileAsInteger(BASE_PATH + FILENAME_CAPACITY);
    if (new_capacity != m_capacity)
    {
        m_capacity = new_capacity;
        emit signalCapacityChanged();
    }
}

// -----------------------------------------------------------------------

void BatteryInfo::updateCurrent()
{
    int new_current = qRound(readFileAsInteger(BASE_PATH + FILENAME_CURRENT) / 1000.0f);
    if (new_current != m_current)
    {
        m_current = new_current;
        emit signalCurrentChanged();
    }
}

// -----------------------------------------------------------------------

void BatteryInfo::updateVoltage()
{
    int new_voltage = qRound(readFileAsInteger(BASE_PATH + FILENAME_VOLTAGE) / 1000.0f);
    if (new_voltage != m_voltage)
    {
        m_voltage = new_voltage;
        emit signalVoltageChanged();
    }
}

// -----------------------------------------------------------------------

void BatteryInfo::updateEnergy()
{
    int new_energy = qRound(readFileAsInteger(BASE_PATH + FILENAME_ENERGY) / 1000.0f);
    if (new_energy != m_energy)
    {
        m_energy = new_energy;
        emit signalEnergyChanged();
    }

    int new_energy_full = qRound(readFileAsInteger(BASE_PATH + FILENAME_ENERGY_FULL) / 1000.0f);
    if (new_energy_full != m_energy_full)
    {
        m_energy_full = new_energy_full;
        emit signalEnergyFullChanged();
    }

    int new_energy_full_design = qRound(readFileAsInteger(BASE_PATH + FILENAME_ENERGY_FULL_DESIGN) / 1000.0f);
    if (new_energy_full_design != m_energy_full_design)
    {
        m_energy_full_design = new_energy_full_design;
        emit signalEnergyFullDesignChanged();
    }
}

// -----------------------------------------------------------------------

void BatteryInfo::updateStatus()
{
    QString new_status = readFileAsString(BASE_PATH + FILENAME_STATUS);
    if (new_status != m_status)
    {
        m_status = new_status;
        emit signalStatusChanged();
    }
}

// -----------------------------------------------------------------------

void BatteryInfo::updateHealth()
{
    QString new_health = readFileAsString(BASE_PATH + FILENAME_HEALTH);
    if (new_health != m_status)
    {
        m_health = new_health;
        emit signalHealthChanged();
    }
}
