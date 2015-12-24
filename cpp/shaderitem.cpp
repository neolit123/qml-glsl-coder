#include "shaderitem.h"

#include <QQuickWindow>
#include <QOpenGLShaderProgram>
#include <QOpenGLShader>
#include <QSGSimpleTextureNode>
#include <QSGTexture>

#include <QDateTime>

ShaderItem::ShaderItem()
{
	setFlags(ItemHasContents);

	m_time = 0;
	m_smooth = true;
	m_smoothFilter = GL_LINEAR;
	m_quality = 1.f;
	m_mousePositionX = 0.f;
	m_mousePositionY = 0.f;
	m_dispose = false;
	m_init = true;
	m_update = true;
	m_updateSize = true;
	m_updateImage = true;
	m_updateSmooth = true;
	m_imageSource = "";
	m_updateVertexShaderSource = true;
	m_updateFragmentShaderSource = true;
	m_startTime = QDateTime::currentMSecsSinceEpoch();

	m_program = NULL;
	m_vertexShader = NULL;
	m_fragmentShader = NULL;
	m_SGNode = NULL;
	m_SGNodeTexture = NULL;

	m_vertexShaderSource = "attribute highp vec4 vertexAttrib;\n"
	                       "attribute highp vec4 texCoordAttrib;\n"
	                       "varying highp vec2 texCoord;\n"
	                       "uniform highp mat4 matrix;\n"
	                       "\n"
	                       "void main(void)\n"
	                       "{\n"
	                       "	gl_Position = matrix * vertexAttrib;\n"
	                       "	texCoord = texCoordAttrib.xy;\n"
	                       "}\n";

	m_fragmentShaderSource = "uniform highp float time;\n"
	                         "uniform highp vec2 mouse;\n"
	                         "uniform highp vec2 resolution;\n"
	                         "varying highp vec2 texCoord;\n"
	                         "uniform sampler2D texture;\n"
	                         "\n"
	                         "void main(void)\n"
	                         "{\n"
	                         "	gl_FragColor = texture2D(texture, texCoord);\n"
	                         "}\n";

	connect(this, SIGNAL(windowChanged(QQuickWindow*)), this, SLOT(onWindowChanged(QQuickWindow*)));
}

ShaderItem::~ShaderItem()
{
}

void ShaderItem::dispose()
{
	if (m_init || m_dispose)
		return;

	qDebug() << this << "dispose()";
	m_dispose = true;

	/* calling dispose() on the item sets m_dipose to true and on the next onSync()
	 * everything is cleaned up, which makes updatePaintNode() to never be called again.
	 * the item is no longer valid!
	 */
}

void ShaderItem::itemChange(ItemChange change, const ItemChangeData &value)
{
	QQuickItem::itemChange(change, value);
}

void ShaderItem::releaseResources()
{
	// qDebug() << this << "releaseResources()";
}

void ShaderItem::onContextDestroyed()
{
	qDebug() << this << "onContextDestroyed()";
}

qreal ShaderItem::time() const
{
	return m_time;
}

QSize ShaderItem::imageSize() const
{
	return m_imageSize;
}

void ShaderItem::setImageSize(const QSize &size)
{
	m_imageSize = size;
	emit imageSizeChanged();
}

QString ShaderItem::fragmentShaderSource() const
{
	return m_fragmentShaderSource;
}

void ShaderItem::setFragmentShaderSource(const QString &source)
{
	if (m_fragmentShaderSource == source)
		return;
	m_fragmentShaderSource = source;
	m_update = true;
	m_updateFragmentShaderSource = true;
	emit fragmentShaderSourceChanged();
}

QString ShaderItem::vertexShaderSource() const
{
	return m_vertexShaderSource;
}

void ShaderItem::setVertexShaderSource(const QString &source)
{
	if (m_vertexShaderSource == source)
		return;
	m_vertexShaderSource = source;
	m_update = true;
	m_updateVertexShaderSource = true;
	emit vertexShaderSourceChanged();
}

bool ShaderItem::smooth() const
{
	return m_smooth;
}

void ShaderItem::setSmooth(const bool smooth)
{
	if (m_smooth == smooth)
		return;
	m_smooth = smooth;
	m_smoothFilter = smooth ? GL_LINEAR : GL_NEAREST;
	m_update = true;
	m_updateSmooth = true;
	emit smoothChanged();
}

QString ShaderItem::log() const
{
	return m_log;
}

void ShaderItem::setLog(const QString &log)
{
	m_log = log;
	emit logChanged();
}

QString ShaderItem::imageSource() const
{
	return m_imageSource;
}

void ShaderItem::setImageSource(const QString &imageSource)
{
	if (m_imageSource == imageSource)
		return;
	m_imageSource = imageSource;
	m_update = true;
	m_updateImage = true;
	emit imageSourceChanged();
}

qreal ShaderItem::quality() const
{
	return m_quality;
}

void ShaderItem::setQuality(const qreal quality)
{
	if (m_quality == quality)
		return;

	static const qreal qualityMin = 0.01;
	static const qreal qualityMax = 4.0;

	m_quality = quality;
	if (m_quality < qualityMin)
		m_quality = qualityMin;
	else if (m_quality > qualityMax)
		m_quality = qualityMax;

	m_sizeWidthQ = m_sizeWidth * m_quality;
	m_sizeHeightQ = m_sizeHeight * m_quality;
	m_update = true;
	m_updateSize = true;

	emit qualityChanged();
}

QPointF ShaderItem::mousePosition() const
{
	return m_mousePosition;
}

void ShaderItem::setMousePosition(const QPointF &mousePosition)
{
	if (m_mousePosition == mousePosition)
		return;
	m_mousePosition = mousePosition;
	m_mousePositionX = m_mousePosition.x();
	m_mousePositionY = m_mousePosition.y();
	emit mousePositionChanged();
}

void ShaderItem::setSGNodeTexture(const GLuint textureId, const GLsizei width, const GLsizei height)
{
	if (m_SGNodeTexture)
		delete m_SGNodeTexture;
	m_SGNodeTexture = window()->createTextureFromId(textureId, QSize(width, height));
	m_SGNode->setTexture(m_SGNodeTexture);
}

QSGNode *ShaderItem::updatePaintNode(QSGNode *, UpdatePaintNodeData *)
{
	if (m_dispose)
		return NULL;

	if (!m_SGNode) {
		m_SGNode = new QSGSimpleTextureNode();
		m_SGNode->setTextureCoordinatesTransform(QSGSimpleTextureNode::MirrorVertically);
	}

	// render the item
	paint();

	// mark and return
	m_SGNode->setRect(this->boundingRect());
	m_SGNode->markDirty(QSGNode::DirtyMaterial);
	return m_SGNode;
}

void ShaderItem::onWindowChanged(QQuickWindow *window)
{
	if (!window)
		return;

	connect(window, SIGNAL(beforeSynchronizing()), this, SLOT(onSync()), Qt::DirectConnection);
	connect(window, SIGNAL(sceneGraphInvalidated()), this, SLOT(onInvalidate()), Qt::DirectConnection);
}

void ShaderItem::onSync()
{
	if (m_dispose) {
		disconnect(this, SIGNAL(windowChanged(QQuickWindow*)), this, SLOT(onWindowChanged(QQuickWindow*)));
		disconnect(window(), SIGNAL(beforeSynchronizing()), this, SLOT(onSync()));
		disconnect(window(), SIGNAL(sceneGraphInvalidated()), this, SLOT(onInvalidate()));

		delete m_program;
		delete m_vertexShader;
		delete m_fragmentShader;
		delete m_SGNode;
		delete m_SGNodeTexture;

		glDeleteFramebuffers(1, &m_frameBuffer);
		glDeleteTextures(1, &m_renderTexture);
		glDeleteTextures(1, &m_imageTexture);
		return;
	}

	m_time = ((qreal)QDateTime::currentMSecsSinceEpoch() - m_startTime) * 0.001;
	setSize(QSize(width(), height()) * window()->devicePixelRatio());

	update();
}

void ShaderItem::onInvalidate()
{
	qDebug() << this << "onInvalidate()";
}

void ShaderItem::setSize(const QSize &size)
{
	if (m_size == size)
		return;
	m_size = size;
	m_sizeWidth = m_size.width();
	m_sizeHeight = m_size.height();
	m_sizeWidthQ = m_sizeWidth * m_quality;
	m_sizeHeightQ = m_sizeHeight * m_quality;
	m_update = true;
	m_updateSize = true;
}

#define PROGRAM_VERTEX_ATTRIBUTE 0
#define PROGRAM_TEXCOORD_ATTRIBUTE 1

void ShaderItem::paintSetup()
{
	if (m_init) {
		// bind the functions to the current context and create the shader program

		initializeOpenGLFunctions();

		m_program = new QOpenGLShaderProgram();
		m_vertexShader = new QOpenGLShader(QOpenGLShader::Vertex);
		m_fragmentShader = new QOpenGLShader(QOpenGLShader::Fragment);

		// connect(window()->openglContext(), SIGNAL(aboutToBeDestroyed()), this, SLOT(onContextDestroyed()), Qt::DirectConnection);
	}

	// update the QImage

	if (m_updateImage) {
		QString filePath;
		if (m_imageSource.indexOf("://") == -1)
			filePath = m_imageSource;
		else
			filePath = QUrl(m_imageSource).toLocalFile();
		if (QFile(filePath).exists()) {
			m_image = QImage(filePath).mirrored();
			m_image = m_image.convertToFormat(QImage::Format_RGB888);
		} else {
			m_image = QImage();
		}
		setImageSize(m_image.size());
	}

	// update the shader program

	if (!m_init)
		m_program->release();

	QString tempLog = "";
	if (m_updateVertexShaderSource) {
		m_program->removeShader(m_vertexShader);
		if (!m_vertexShader->compileSourceCode(m_vertexShaderSource)) {
			tempLog += m_vertexShader->log();
			m_vertexShader->compileSourceCode(m_vertexShaderSourceValid);
		} else {
			m_vertexShaderSourceValid = m_vertexShaderSource;
		}
		m_program->addShader(m_vertexShader);
	}

	if (m_updateFragmentShaderSource) {
		m_program->removeShader(m_fragmentShader);
		if (!m_fragmentShader->compileSourceCode(m_fragmentShaderSource)) {
			tempLog += m_fragmentShader->log();
			m_fragmentShader->compileSourceCode(m_fragmentShaderSourceValid);
		} else {
			m_fragmentShaderSourceValid = m_fragmentShaderSource;
		}
		m_program->addShader(m_fragmentShader);
	}
	setLog(tempLog);

	m_program->bindAttributeLocation("vertexAttrib", PROGRAM_VERTEX_ATTRIBUTE);
	m_program->bindAttributeLocation("texCoordAttrib", PROGRAM_TEXCOORD_ATTRIBUTE);
	m_program->link();
	m_program->bind();
	m_program->setUniformValue("texture", 0);
	m_program->setUniformValue("matrix", m_matrix);
	m_program->release();

	// update framebuffer, render texture and image texture

	if (m_updateSize || m_updateSmooth) {
		if (!m_init) {
			glDeleteFramebuffers(1, &m_frameBuffer);
			glDeleteTextures(1, &m_renderTexture);
		}
		glGenFramebuffers(1, &m_frameBuffer);
		glBindFramebuffer(GL_FRAMEBUFFER, m_frameBuffer);
		glGenTextures(1, &m_renderTexture);
		glBindTexture(GL_TEXTURE_2D, m_renderTexture);
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, m_sizeWidthQ, m_sizeHeightQ, 0, GL_RGB, GL_UNSIGNED_BYTE, 0);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, m_smoothFilter);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, m_smoothFilter);
		glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, m_renderTexture, 0);

		// update the SG note texture from the framebuffer texture

		m_SGNode->setFiltering(m_smooth ? QSGTexture::Linear : QSGTexture::Nearest);
		setSGNodeTexture(m_renderTexture, m_sizeWidthQ, m_sizeHeightQ);
	}

	if (m_updateImage || m_updateSize || m_updateSmooth) {
		if (!m_init)
			glDeleteTextures(1, &m_imageTexture);
		glGenTextures(1, &m_imageTexture);
		glBindTexture(GL_TEXTURE_2D, m_imageTexture);
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, m_image.width(), m_image.height(), 0, GL_RGB, GL_UNSIGNED_BYTE, m_image.bits());
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, m_smoothFilter);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, m_smoothFilter);
	}

	m_init = false;
	m_update = false;
	m_updateSize = false;
	m_updateSmooth = false;
	m_updateImage = false;
	m_updateFragmentShaderSource = false;
	m_updateVertexShaderSource = false;
}

void ShaderItem::paint()
{
	if (m_update)
		paintSetup();

	// bind the framebuffer

	glBindFramebuffer(GL_FRAMEBUFFER, m_frameBuffer);

	// bind the shader program and set values and attributes

	m_program->bind();
	m_program->enableAttributeArray(PROGRAM_VERTEX_ATTRIBUTE);
	m_program->enableAttributeArray(PROGRAM_TEXCOORD_ATTRIBUTE);

	static const GLfloat coordVert[] = {
	    -1.f, -1.f,
	    +1.f, -1.f,
	    -1.f, +1.f,
	    +1.f, +1.f
	};

	static const GLfloat coordTex[] = {
	    0.f, 0.f,
	    1.f, 0.f,
	    0.f, 1.f,
	    1.f, 1.f
	};

	m_program->setAttributeArray(PROGRAM_VERTEX_ATTRIBUTE, GL_FLOAT, coordVert, 2);
	m_program->setAttributeArray(PROGRAM_TEXCOORD_ATTRIBUTE, GL_FLOAT, coordTex, 2);
	m_program->setUniformValue("time", (GLfloat)m_time);
	m_program->setUniformValue("mouse", m_mousePositionX, m_mousePositionY);
	m_program->setUniformValue("resolution", (GLfloat)m_sizeWidthQ, (GLfloat)m_sizeHeightQ);

	// bind the shader image texture

	glBindTexture(GL_TEXTURE_2D, m_imageTexture);

	// draw the quad

	glViewport(0, 0, m_sizeWidthQ, m_sizeHeightQ);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

	// release the shader program

	m_program->disableAttributeArray(PROGRAM_VERTEX_ATTRIBUTE);
	m_program->disableAttributeArray(PROGRAM_TEXCOORD_ATTRIBUTE);
	m_program->release();
}
