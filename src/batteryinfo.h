#ifndef BATTERYINFO_H
#define BATTERYINFO_H

#include <QObject>
#include <QString>

#include "infobase.h"

// -----------------------------------------------------------------------

class BatteryInfo : public QObject, public InfoBase
{
    Q_OBJECT

    Q_PROPERTY(bool valid READ isValid NOTIFY signalValidChanged)
    Q_PROPERTY(int capacity READ getCapacity NOTIFY signalCapacityChanged)
    Q_PROPERTY(int current READ getCurrent NOTIFY signalCurrentChanged)
    Q_PROPERTY(int voltage READ getVoltage NOTIFY signalVoltageChanged)
    Q_PROPERTY(int energy READ getEnergy NOTIFY signalEnergyChanged)
    Q_PROPERTY(int energyFull READ getEnergyFull NOTIFY signalEnergyFullChanged)
    Q_PROPERTY(int energyFullDesign READ getEnergyFullDesign NOTIFY signalEnergyFullDesignChanged)
    Q_PROPERTY(QString status READ getStatus NOTIFY signalStatusChanged)
    Q_PROPERTY(QString health READ getHealth NOTIFY signalHealthChanged)

public:
    explicit BatteryInfo(QObject *parent = 0);
    virtual ~BatteryInfo();

    Q_INVOKABLE void update();

    bool isValid() const { return m_valid; }
    int getCapacity() const { return m_capacity; }
    int getCurrent() const { return m_current; }
    int getVoltage() const { return m_voltage; }
    int getEnergy() const { return m_energy; }
    int getEnergyFull() const { return m_energy_full; }
    int getEnergyFullDesign() const { return m_energy_full_design; }
    const QString &getStatus() const { return m_status; }
    const QString &getHealth() const { return m_health; }

signals:
    void signalValidChanged();
    void signalCapacityChanged();
    void signalCurrentChanged();
    void signalVoltageChanged();
    void signalEnergyChanged();
    void signalEnergyFullChanged();
    void signalEnergyFullDesignChanged();
    void signalStatusChanged();
    void signalHealthChanged();

private:
    static const QString BASE_PATH;
    static const QString FILENAME_CAPACITY;
    static const QString FILENAME_CURRENT;
    static const QString FILENAME_VOLTAGE;
    static const QString FILENAME_ENERGY;
    static const QString FILENAME_ENERGY_FULL;
    static const QString FILENAME_ENERGY_FULL_DESIGN;
    static const QString FILENAME_STATUS;
    static const QString FILENAME_HEALTH;
    static const QString UNKNOWN_STATUS;
    static const QString UNKNOWN_HEALTH;

    void updateCapacity();
    void updateCurrent();
    void updateVoltage();
    void updateEnergy();
    void updateStatus();
    void updateHealth();
    void updateValidity();

    bool m_valid;
    int m_capacity;           // 0 - 100 %
    int m_current;            // [mA]
    int m_voltage;            // [mV]
    int m_energy;             // [mWh]
    int m_energy_full;        // [mWh]
    int m_energy_full_design; // [mWh]
    QString m_status;
    QString m_health;

};

// -----------------------------------------------------------------------

#endif // BATTERYINFO_H
