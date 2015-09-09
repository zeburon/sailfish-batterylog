#include <QQuickView>
#include <QScopedPointer>
#include <QtQuick>
#include <sailfishapp.h>

#include "batteryinfo.h"
#include "screeninfo.h"

// -----------------------------------------------------------------------

int main(int argc, char *argv[])
{
    qmlRegisterType<BatteryInfo>("harbour.batterylog.BatteryInfo", 1, 0, "BatteryInfo");
    qmlRegisterType<ScreenInfo>("harbour.batterylog.ScreenInfo", 1, 0, "ScreenInfo");

    QScopedPointer<QGuiApplication> app(SailfishApp::application(argc, argv));
    QScopedPointer<QQuickView> view(SailfishApp::createView());
    view->setSource(SailfishApp::pathTo("qml/harbour-batterylog.qml"));
    view->show();
    return app->exec();
}
