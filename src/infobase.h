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
    bool readFileAsString(const QString &filename, QString &output) const;
    bool readFileAsInteger(const QString &filename, int &output) const;

};

// -----------------------------------------------------------------------

#endif // INFOBASE_H
