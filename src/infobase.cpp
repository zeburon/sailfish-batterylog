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

//-------------------------------------------------------------------------

QString InfoBase::get_value(const QString &filename, QString in_variable) const
{
    QString value;
    QString szline;
    QByteArray bline;
    int line=1;
    bool found=false;
    QFile file(filename);
    if (file.open(QIODevice::ReadOnly | QIODevice::Text))
    {
        while (!found)
        {
            bline = file.readLine();
            if (bline.contains(in_variable.toUtf8()))
            {
                value = bline.remove(0,in_variable.end()-in_variable.begin()+1);
                value.chop(1);
                found=true;
            }
            line++;
        }
    }
    else
    if(!found)
        return "0";
    return value;
 }