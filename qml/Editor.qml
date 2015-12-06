import QtQuick 2.5
import QtGraphicalEffects 1.0

Item {
	id: editor
	anchors.fill: parent

	// property var lastPosition: 1;
	readonly property string colorGreen: "#ff00ff00";
	readonly property string colorRed: "#ffff0000";
	readonly property string defaultFont: main.defaultFont;
	readonly property real editorFontSz: 12;
	readonly property real lineHeightScale: 1.55; // this value is 'editorFontSz' based
	readonly property real lineHeight: editorFontSz * lineHeightScale;
	readonly property int logTextHeight: 100;

	function getText()
	{
		return edit.text;
	}

	function setText(str)
	{
		edit.text = str;
	}

	function getFlick()
	{
		return flick;
	}

	function getLineHeight()
	{
		return lineHeight;
	}

	function getLineNumber()
	{
		// if (pos === editor.lastPosition)
			// return;
		var pos = edit.cursorPosition;
		var lineNumber = 0;
		var lines = edit.text.split("\n");
		var len = lines.length;
		var acc = 0;
		for (var i = 0; i < len; i++) {
			acc += lines[i].length + 1;
			if (pos < acc) {
				lineNumber = i + 1;
				break;
			}
		}
		// editor.lastPosition = pos;
		return lineNumber;
	}

	function setPosition(pos)
	{
		positionText.text = "Line: " + getLineNumber();
	}

	function pageNavigation(isDown)
	{
		var pageLines = flick.height / lineHeight;
		var lineBreaks = 0;
		var str = edit.text;
		var pos = edit.cursorPosition;
		var len = edit.length - 1;
		if (isDown) {
			while (pos < len) {
				pos++;
				if (str.charAt(pos) == "\n") {
					lineBreaks++;
					if (lineBreaks == pageLines) {
						pos++;
						break;
					}
				}
			}
		} else {
			while (pos > 0) {
				pos--;
				if (str.charAt(pos) == "\n") {
					lineBreaks++;
					if (lineBreaks == pageLines + 1) {
						pos++;
						break;
					}
				}
			}
		}
		edit.cursorPosition = pos;
	}

	function setLogText(text, isError)
	{
		if (isError)
			text = text.replace("\n\n", "");
		logText.text = text;
		logText.color = !isError ? colorGreen : colorRed;
	}

	Rectangle {
		id: editBack
		anchors.fill: parent
		width: main.width
		height: main.height
		color: "black"
		opacity: 0.8
	}

	Text {
		id: positionText
		font.family: defaultFont
		color: colorGreen;
		text: "Line: 0";
		renderType: Text.NativeRendering
		y: parent.height - positionText.height;
		x: 0;
	}

	Text {
		id: qualityText
		font.family: defaultFont
		color: colorGreen;
		text: "| Quality: " + main.quality;
		renderType: Text.NativeRendering
		y: parent.height - qualityText.height;
		x: positionText.x + positionText.width + 10;
	}

	Text {
		id: smoothText
		font.family: defaultFont
		color: colorGreen;
		text: "| Smooth: " + main.smoothing;
		renderType: Text.NativeRendering
		y: parent.height - qualityText.height;
		x: qualityText.x + qualityText.width + 10;
	}

	Text {
		id: logText
		font.family: defaultFont
		color: colorRed;
		text: "error";
		renderType: Text.NativeRendering
		wrapMode: TextEdit.WordWrap
		width: parent.width;
		y: parent.height - logText.height - positionText.height;
	}

	Rectangle {
		id: flickEnd
		// y: lineHeight * Math.round((parent.height - logTextHeight) / lineHeight) + 5
		y: logText.y - 5;
		gradient: Gradient {
			GradientStop { position: 0.0; color: "#ffffffff" }
			GradientStop { position: 0.5; color: "#8000ff00" }
			GradientStop { position: 1.0; color: "#0000ff00" }
		}
		height: 5
		width: parent.width;
	}

	Flickable {
		id: flick
		// anchors.fill: parent
		width: parent.width;
		// height: lineHeight * Math.round((parent.height - logTextHeight) / lineHeight);
		height: logText.y - 10;
		contentWidth: parent.width;
		clip: true

		function ensureVisible(r)
		{
			if (contentY >= r.y)
				contentY = r.y;
			else if (contentY + height <= r.y + r.height)
				contentY = r.y + r.height - height;
			flick.contentHeight = edit.height;
		}

		TextEdit {
			id: edit
			focus: true
			smooth: false
			visible: true
			selectByMouse: true
			selectedTextColor: "black"
			selectionColor: "white"
			renderType: Text.NativeRendering
			wrapMode: TextEdit.WordWrap
			font.bold: false
			font.pointSize: editorFontSz
			font.family: defaultFont
			width: main.width
			color: "white"
			x: 0
			y: 0
			text: main.defaultShader
			onCursorRectangleChanged: {
				flick.ensureVisible(cursorRectangle);
				editor.setPosition(cursorPosition);
			}

			Component.onCompleted: {
				context.registerTextDocument(edit.textDocument);
			}
		}

		DropShadow {
			id: dropShadow
			anchors.fill: edit
			horizontalOffset: 0
			verticalOffset: 0
			spread: 0.314
			radius: 8
			samples: 16
			color: "black"
			source: edit
		}
	}
}
