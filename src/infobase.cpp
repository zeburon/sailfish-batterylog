#include "infobase.h"

#include <QFile>

// -----------------------------------------------------------------------

InfoBase::InfoBase()
{
}

// -----------------------------------------------------------------------

InfoBase::~InfoBase()
{
}

// -----------------------------------------------------------------------

bool InfoBase::readFileAsString(const QString &filename, QString &output) const
{
    QFile file(filename);
    if (!file.open(QIODevice::ReadOnly))
        return false;

    output = file.readAll().trimmed();
    return !output.isEmpty();
}

// -----------------------------------------------------------------------

bool InfoBase::readFileAsInteger(const QString &filename, int &output) const
{
    QString string_data;
    if (!readFileAsString(filename, string_data))
        return false;

    bool ok = false;
    int value = string_data.toInt(&ok);
    if (!ok)
        return false;

    output = value;
    return true;
}
