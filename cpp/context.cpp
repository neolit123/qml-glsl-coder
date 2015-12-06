#include "context.h"

#include <QGuiApplication>
#include <QVariant>
#include <QMetaObject>
#include <QQuickItem>
#include <QFile>
#include <QDir>
#include <QQuickTextDocument>
#include <QTextDocument>
#include <QStandardPaths>
#include <QDebug>

#include "highlighter.h"

#include <typeinfo>
#define cDebug() qDebug() << "cpp:" << QString("%1::%2():").arg(typeid(this).name()).arg(__func__)

Context::Context() : highlighter(NULL)
{
	m_buildTime = QString("%1, %2").arg(__DATE__).arg(__TIME__);
}

Context::~Context()
{
	// delete highlighter;
}

QString Context::buildName()
{
	return m_buildName;
}

void Context::setBuildName(const QString& name)
{
	m_buildName = name;
}

QString Context::buildVersion()
{
	return m_buildVersion;
}

void Context::setBuildVersion(const QString& ver)
{
	m_buildVersion = ver;
}

QString Context::buildTime()
{
	return m_buildTime;
}

void Context::receiveMessage(enum MessageType type, const QString& message)
{
	cDebug() << type << message;
}

void Context::registerRootElement(QQuickItem *_root)
{
	root = _root;
	emit contextMessage(INIT, "Context::registerRootElement()");
}

void Context::registerTextDocument(QQuickTextDocument *doc)
{
	cDebug() << doc;
	highlighter = new Highlighter(doc->textDocument());
}

bool Context::writeFile(const QString& url, const QString& text)
{
	QString path = QUrl(url).toLocalFile();
	QFile file(path);
	cDebug() << path << "exists:" << file.exists();
	if (!file.open(QFile::WriteOnly)) {
		cDebug() << "error opening file" << path;
		return false;
	}
	file.write(text.toUtf8().constData(), text.toUtf8().length());
	file.close();
	return true;
}

QString Context::readFile(const QString& url)
{
	QString path = QUrl(url).toLocalFile();
	QFile file(path);
	cDebug() << path << "exists:" << file.exists();
	if (!file.open(QFile::ReadOnly)) {
		cDebug() << "error opening file" << path;
		return NULL;
	}
	return QString(file.readAll());
}

bool Context::fileExists(const QString& url)
{
	QString path = QUrl(url).toLocalFile();
	QFile file(path);
	return file.exists();
}

QString Context::applicationPath(void)
{
	return QGuiApplication::applicationDirPath();
}

QString Context::currentPath(void)
{
	return QDir::currentPath();
}

QString Context::storagePath(void)
{
#ifdef Q_OS_WIN32
	QString path = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
#else
	QString path = QStandardPaths::writableLocation(QStandardPaths::DataLocation);
#endif
	QDir dir(path);
	if (!dir.exists())
		dir.mkpath(path);
	return path;
}
