import QtQuick 2.5

Item {
	id: cursor
	visible: false
	property int cWidth: 1;
	property string color: "#ff00ff00";

	Rectangle {
		id: cursorX
		width: cursor.cWidth
		height: main.height
		color: cursor.color
	}

	Rectangle {
		id: cursorY
		color: cursor.color
		width: main.width
		height: cursor.cWidth
	}

	Text {
		id: cursorText
		x: main.width - cursorText.width;
		font.family: "Courier New";
		color: cursor.color;
		renderType: Text.NativeRendering
	}

	function setPosition(x, y)
	{
		cursorX.x = x;
		cursorY.y = y;
		cursorText.text = x + ", " + y;
	}
}

