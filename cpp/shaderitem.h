#ifndef SHADERITEM_H
#define SHADERITEM_H

#include <QQuickItem>
#include <QOpenGLFunctions>
#include <QImage>
#include <QMatrix4x4>

class QSGSimpleTextureNode;
class QSGTexture;
class QOpenGLShaderProgram;
class QOpenGLShader;
class ShaderItemRenderer;

class ShaderItem : public QQuickItem, protected QOpenGLFunctions
{
	Q_OBJECT

	Q_PROPERTY(bool smooth READ smooth WRITE setSmooth NOTIFY smoothChanged)
	Q_PROPERTY(qreal time READ time)
	Q_PROPERTY(qreal quality READ quality WRITE setQuality NOTIFY qualityChanged)
	Q_PROPERTY(QSize imageSize READ imageSize NOTIFY imageSizeChanged)
	Q_PROPERTY(QString log READ log NOTIFY logChanged)
	Q_PROPERTY(QString imageSource READ imageSource WRITE setImageSource NOTIFY imageSourceChanged)
	Q_PROPERTY(QString vertexShaderSource READ vertexShaderSource WRITE setVertexShaderSource NOTIFY vertexShaderSourceChanged)
	Q_PROPERTY(QString fragmentShaderSource READ fragmentShaderSource WRITE setFragmentShaderSource NOTIFY fragmentShaderSourceChanged)
	Q_PROPERTY(QPointF mousePosition READ mousePosition WRITE setMousePosition NOTIFY mousePositionChanged)

public:
	ShaderItem();
	~ShaderItem();

	void setSGNodeTexture(const GLuint textureId, const GLsizei width, const GLsizei height);

	qreal time() const;

	QSize imageSize() const;
	void setImageSize(const QSize &size);

	QString vertexShaderSource() const;
	void setVertexShaderSource(const QString &source);

	QString fragmentShaderSource() const;
	void setFragmentShaderSource(const QString &source);

	QString log() const;
	void setLog(const QString &log);

	bool smooth() const;
	void setSmooth(const bool smooth);

	QString imageSource() const;
	void setImageSource(const QString &imageSource);

	qreal quality() const;
	void setQuality(const qreal quality);

	QPointF mousePosition() const;
	void setMousePosition(const QPointF &mousePosition);

signals:
	void vertexShaderSourceChanged();
	void fragmentShaderSourceChanged();
	void logChanged();
	void smoothChanged();
	void imageSourceChanged();
	void qualityChanged();
	void imageSizeChanged();
	void mousePositionChanged();

public slots:
	void dispose();
	void onSync();
	void onInvalidate();

private slots:
	void onWindowChanged(QQuickWindow *win);
	void onContextDestroyed();

protected:
	QSGNode *updatePaintNode(QSGNode *, UpdatePaintNodeData *);
	void itemChange(ItemChange change, const ItemChangeData &value);
	void releaseResources();

private:
	void paint();
	void paintSetup();
	void setSize(const QSize &size);

	qreal m_quality;
	qreal m_time, m_startTime;

	QSize m_size;
	QSize m_imageSize;
	QPointF m_mousePosition;

	QString m_vertexShaderSource;
	QString m_vertexShaderSourceValid;
	QString m_fragmentShaderSource;
	QString m_fragmentShaderSourceValid;
	QString m_imageSource;
	QString m_log;

	QMatrix4x4 m_matrix;
	QImage m_image;

	QSGSimpleTextureNode *m_SGNode;
	QSGTexture *m_SGNodeTexture;
	QOpenGLShaderProgram *m_program;
	QOpenGLShader *m_vertexShader;
	QOpenGLShader *m_fragmentShader;

	GLint m_smoothFilter;
	GLuint m_frameBuffer;
	GLuint m_renderTexture;
	GLuint m_imageTexture;
	GLsizei m_sizeWidth;
	GLsizei m_sizeHeight;
	GLsizei m_sizeWidthQ;
	GLsizei m_sizeHeightQ;
	GLfloat m_mousePositionX;
	GLfloat m_mousePositionY;

	bool m_init;
	bool m_dispose;
	bool m_update;
	bool m_updateSize;
	bool m_updateImage;
	bool m_updateSmooth;
	bool m_updateVertexShaderSource;
	bool m_updateFragmentShaderSource;
	bool m_smooth;
};

#endif
