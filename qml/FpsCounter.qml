import QtQuick 2.1

Item {
	id: fpsCounter
	property int frameCounter: 0
	property int fps: 0

	width: 60
	height: 60

	Rectangle {
		id: spinner
		border.width: 2.0;
		border.color: "#6000ff00"
		width: parent.width
		height: parent.height
		color: "#60000000"
		NumberAnimation on rotation
		{
			from: 0
			to: 360
			duration: 1000
			loops: Animation.Infinite
		}
		onRotationChanged: frameCounter++;
	}

	Text {
		text: fpsCounter.fps + " FPS"
		renderType: Text.NativeRendering
		font.family: editor.defaultFont;
		color: "#ff00ff00"
		anchors
		{
			horizontalCenter: spinner.horizontalCenter
			verticalCenter: spinner.verticalCenter
		}
	}

	Timer {
		interval: 2000
		repeat: true
		running: true
		onTriggered:
		{
			fps = frameCounter * 0.5
			frameCounter = 0
		}
	}
}
