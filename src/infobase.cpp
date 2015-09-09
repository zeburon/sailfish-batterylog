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

QString InfoBase::readFileAsString(const QString &filename) const
{
    QFile file(filename);
    if (!file.open(QIODevice::ReadOnly))
        return QString();

    return file.readAll().trimmed();
}

// -----------------------------------------------------------------------

int InfoBase::readFileAsInteger(const QString &filename) const
{
    QString string_data = readFileAsString(filename);

    bool ok = false;
    int value = string_data.toInt(&ok);
    if (!ok)
        return 0;

    return value;
}
