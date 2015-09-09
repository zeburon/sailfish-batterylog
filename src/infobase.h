#ifndef INFOBASE_H
#define INFOBASE_H

#include <QString>

// -----------------------------------------------------------------------

class InfoBase
{

public:
    InfoBase();
    virtual ~InfoBase();

protected:
    QString readFileAsString(const QString &filename) const;
    int readFileAsInteger(const QString &filename) const;

};

// -----------------------------------------------------------------------

#endif // INFOBASE_H
