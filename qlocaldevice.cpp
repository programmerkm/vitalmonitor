#include "qlocaldevice.h"
#include <unistd.h>
#include <sys/reboot.h>

QLocalDevice::QLocalDevice(QObject *parent)
    : QObject(parent)
{
}

QLocalDevice::~QLocalDevice()
{
}

/*!
 * Reboots the system. Does not return.
 *
 * \sa powerOff()
 */
void QLocalDevice::reboot()
{
    sync();
    ::reboot(RB_AUTOBOOT);
    qWarning("reboot returned");
}


/*!
 * Shuts down the system. Does not return.
 *
 * \sa reboot()
 */
void QLocalDevice::powerOff()
{
    sync();
    ::reboot(RB_POWER_OFF);
    qWarning("powerOff returned");
}
