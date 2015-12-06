#ifndef CONTEXT_H
#define CONTEXT_H

#include <QObject>

#define REGISTER_QML_TYPES() \
	qmlRegisterType<Context>("MessageType", 1, 0, "MessageType");

class QQuickItem;
class Highlighter;
class QQuickTextDocument;

class Context : public QObject
{
	Q_OBJECT
	Q_ENUMS(MessageType)

public:
	enum MessageType {
		INIT = 0,
		READY
	};

	Context();
	~Context();
	void init();
	void setBuildName(const QString&);
	void setBuildVersion(const QString&);

signals:
	void contextMessage(enum MessageType type, const QString& message);

public slots:
	QString buildName();
	QString buildVersion();
	QString buildTime();

	void registerRootElement(QQuickItem *);
	void registerTextDocument(QQuickTextDocument *);
	void receiveMessage(enum MessageType type, const QString& message);

	bool writeFile(const QString& url, const QString& text);
	QString readFile(const QString& url);
	bool fileExists(const QString& url);

	QString applicationPath(void);
	QString currentPath(void);
	QString storagePath(void);

private:
	QQuickItem *root;
	Highlighter *highlighter;
	QString m_buildName;
	QString m_buildVersion;
	QString m_buildTime;
};

#endif
