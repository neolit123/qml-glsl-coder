#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickWindow>
#include <QQuickItem>
#include <QQmlContext>
#include <QUrl>
#include <QPixmap>
#include <QIcon>
#include <QDebug>

#ifndef BUILD_VERSION
#define BUILD_VERSION "1.2.0"
#endif

#ifndef BUILD_NAME
#define BUILD_NAME "QML GLSL Coder"
#endif

#include "cpp/context.h"
#include "cpp/shaderitem.h"

int main(int argc, char **argv)
{
	QGuiApplication app(argc, argv);
	app.setWindowIcon(QPixmap(":/images/icon.png"));
	app.setApplicationName(BUILD_NAME);

	qmlRegisterType<Context>("MessageType", 1, 0, "MessageType");
	qmlRegisterType<ShaderItem>("ShaderItem", 1, 0, "ShaderItem");

	Context context;
	context.setBuildName(BUILD_NAME);
	context.setBuildVersion(BUILD_VERSION);

	QQmlApplicationEngine engine;
	engine.addImportPath(":/qml");
	engine.addImportPath(":/js");
	engine.rootContext()->setContextProperty("context", &context);
	engine.load(QUrl("qrc:/qml/main.qml"));

	QQuickWindow *window = qobject_cast<QQuickWindow *>(engine.rootObjects().at(0));
	if (!window) {
		qFatal("error: the root item has to be a window.");
		return 1;
	}
	window->show();

	return app.exec();
}
