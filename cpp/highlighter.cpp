#include "highlighter.h"

Highlighter::Highlighter(QTextDocument *parent)
	: QSyntaxHighlighter(parent)
{
	HighlightingRule rule;
	QColor colorRed(255, 0, 0);
	QColor colorGreen(0, 255, 0);
	QColor colorBlue(0, 255, 255);

	// keywordFormat.setForeground(QColor(0, 255, 0));
	keywordFormat.setFontWeight(QFont::Bold);
	QStringList keywordPatterns;
	keywordPatterns <<
		"\\bfloat\\b" << "\\bint\\b" << "\\buint\\b" << "\\bvoid\\b" <<
		"\\bbool\\b" << "\\bdouble\\b" << "\\bprecision\\b" <<
		"\\bconst\\b" << "\\buniform\\b" << "\\bsampler\\b" <<

		"\\bvarying\\b" << "\\bsampler2D\\b" << "\\btexture2D\\b" << "\\breturn\\b" <<
		"\\blowp\\b" << "\\bmediump\\b" << "\\bhighp\\b" <<

		"\\bfor\\b" << "\\bwhile\\b" << "\\bbuffer\\b" << "\\bstruct\\b" <<

		"\\bgl_FragColor\\b" << "\\bgl_FragCoord\\b" <<

		"\\bqt_Opacity\\b" << "\\bqt_Vertex\\b" << "\\bqt_Matrix\\b" <<
		"\\bqt_MultiTexCoord0\\n" <<

		"\\bin\\b" << "\\bout\\b" << "\\binout\\b" <<

		"\\bvec2\\b" << "\\bvec3\\b" << "\\bvec4\\b" <<
		"\\bivec2\\b" << "\\bivec3\\b" << "\\bivec4\\b" <<
		"\\buvec2\\b" << "\\buvec3\\b" << "\\buvec4\\b" <<
		"\\bdvec2\\b" << "\\bdvec3\\b" << "\\bdvec4\\b" <<

		"\\bmat2\\b" << "\\bmat3\\b" << "\\bmat4\\b" <<
		"\\bmat2x2\\b" << "\\bmat2x3\\b" << "\\bmat2x4\\b" <<
		"\\bmat3x2\\b" << "\\bmat3x3\\b" << "\\bmat3x4\\b" <<
		"\\bmat4x2\\b" << "\\bmat4x3\\b" << "\\bmat4x4\\b";

	foreach (const QString &pattern, keywordPatterns) {
		rule.pattern = QRegExp(pattern);
		rule.format = keywordFormat;
		highlightingRules.append(rule);
	}

	specialCharacterFormat.setForeground(colorBlue);
	rule.pattern = QRegExp("[\\.\\(\\)\\*\\/\\+\\-\\{\\}\\=\\%\\!\\~\\&\\[\\]\\|\\;\\<\\>\\^]");
	rule.format = specialCharacterFormat;
	highlightingRules.append(rule);

	preprocessorFormat.setForeground(colorRed);
	rule.pattern = QRegExp("#[^\n]*");
	rule.format = preprocessorFormat;
	highlightingRules.append(rule);

	quotationFormat.setForeground(colorRed);
	rule.pattern = QRegExp("\".*\"");
	rule.format = quotationFormat;
	highlightingRules.append(rule);

	singleLineCommentFormat.setForeground(colorGreen);
	rule.pattern = QRegExp("//[^\n]*");
	rule.format = singleLineCommentFormat;
	highlightingRules.append(rule);

	multiLineCommentFormat.setForeground(colorGreen);

	commentStartExpression = QRegExp("/\\*");
	commentEndExpression = QRegExp("\\*/");
}

void Highlighter::highlightBlock(const QString &text)
{
	foreach (const HighlightingRule &rule, highlightingRules) {
		QRegExp expression(rule.pattern);
		int index = expression.indexIn(text);
		while (index >= 0) {
			int length = expression.matchedLength();
			setFormat(index, length, rule.format);
			index = expression.indexIn(text, index + length);
		}
	}
	setCurrentBlockState(0);

	int startIndex = 0;
	if (previousBlockState() != 1)
		startIndex = commentStartExpression.indexIn(text);

	while (startIndex >= 0) {
		int endIndex = commentEndExpression.indexIn(text, startIndex);
		int commentLength;
		if (endIndex == -1) {
			setCurrentBlockState(1);
			commentLength = text.length() - startIndex;
		} else {
			commentLength = endIndex - startIndex
							+ commentEndExpression.matchedLength();
		}
		setFormat(startIndex, commentLength, multiLineCommentFormat);
		startIndex = commentStartExpression.indexIn(text, startIndex + commentLength);
	}
}
