#ifndef QLOCALDEVICE_H
#define QLOCALDEVICE_H

#include <qobject.h>

class Q_DECL_EXPORT QLocalDevice : public QObject
{
    Q_OBJECT

public:
    QLocalDevice(QObject *parent = Q_NULLPTR);
    ~QLocalDevice();

public Q_SLOTS:
    void reboot();
    void powerOff();
};

#endif // QLOCALDEVICE_H
