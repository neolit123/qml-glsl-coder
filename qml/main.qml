import QtQuick 2.5
import QtQuick.Window 2.2
import MessageType 1.0
import ShaderItem 1.0
import "qrc:/js/Shader.js" as Shader

Window {
	id: window
	visible: true
	width: 800
	height: 480
	visibility: Window.Windowed
	title: context.buildName()

	onClosing: {
		close.accepted = false;
		dialogs.showExit();
	}

	Item {
		id: main
		anchors.fill: parent

		property real quality: 1.0;
		property bool smooth: false;
		property point mousePosition: Qt.point(0, 0);
		property string defaultFont: "Courier New";

		property string imageURL: "";
		property string shaderEdit: "";
		property string defaultShader: Shader.getDefault();

		property var windowVisibility: ""

		Connections {
			target: context
			onContextMessage: {
				print("onContextMessage:", type, message);
			}
		}

		Component.onCompleted: {
			context.registerRootElement(main);
		}

		function openFileCallback(str)
		{
			if (str != "") {
				editor.setText(str);
				main.shaderEdit = str;
				main.renderShader();
			}
			restoreWindowVisibility();
		}

		function openImageFileCallback(url)
		{
			if (url != "") {
				shaderEffect.imageSrouce = url;
				print("image loaded: " + url);
			}
			restoreWindowVisibility();
		}

		function saveFileCallback()
		{
			restoreWindowVisibility();
		}

		function restoreWindowVisibility()
		{
			window.visibility = windowVisibility;
		}

		function setWindowVisibilityWindowedStore()
		{
			windowVisibility = window.visibility;
			window.visibility = Window.Windowed;
		}

		Keys.onPressed: {
			var tempQ = quality;
			switch (event.key) {
			case Qt.Key_F1:
				dialogs.showHelp();
				break;
			case Qt.Key_F2:
				fpsCounter.visible = !fpsCounter.visible;
				break;
			case Qt.Key_F3:
				cursor.visible = !cursor.visible;
				break;
			case Qt.Key_F4:
				editor.visible = !editor.visible;
				break;
			case Qt.Key_F5:
				main.shaderEdit = editor.getText();
				main.renderShader();
				break;
			case Qt.Key_F6:
				setWindowVisibilityWindowedStore();
				dialogs.openImageFile(openImageFileCallback);
				break;
			case Qt.Key_F7:
				setWindowVisibilityWindowedStore();
				dialogs.openFile(openFileCallback);
				break;
			case Qt.Key_F8:
				setWindowVisibilityWindowedStore();
				dialogs.saveFile(saveFileCallback, editor.getText());
				break;
			case Qt.Key_F9:
				main.smooth = !main.smooth;
				break;
			case Qt.Key_F10:
				tempQ *= 0.5;
				if (tempQ < 0.015625)
					tempQ = 0.015625;
				quality = tempQ;
				break;
			case Qt.Key_F11:
				tempQ *= 2.0;
				if (tempQ > 2.0)
					tempQ = 2.0;
				quality = tempQ;
				break;
			case Qt.Key_F12:
				window.visibility = (window.visibility == Window.Windowed) ?
					Window.FullScreen : Window.Windowed;
				break;
			case Qt.Key_Escape:
				dialogs.showExit();
				break;
			case Qt.Key_PageUp:
				editor.pageNavigation(false);
				break;
			case Qt.Key_PageDown:
				editor.pageNavigation(true);
				break;
			}

		}

		Dialogs {
			id: dialogs;
		}

		ShaderItem {
			id: shaderItem
			anchors.fill: parent;

			onLogChanged: {
				if (shaderItem.log === "")
					editor.setLogText("Compiled " + (new Date()).toTimeString(), false);
				else
					editor.setLogText(shaderItem.log, true);
			}

			smooth: main.smooth;
			quality: main.quality;
			fragmentShaderSource: main.defaultShader;
		}

		Cursor {
			id: cursor;
		}

		Editor {
			id: editor;
		}

		FpsCounter {
			id: fpsCounter
			x: parent.width - fpsCounter.width - 10;
			visible: false
			y: 25
		}

		/* a mouse area to catch movements */
		MouseArea {
			id: mouseArea
			anchors.fill: parent
			hoverEnabled: true
			propagateComposedEvents: true
			preventStealing: false

			onPositionChanged: {
				main.mousePosition.x = mouse.x / main.width;
				main.mousePosition.y = mouse.y / main.height;
				shaderItem.mousePosition = main.mousePosition;
				cursor.setPosition(mouse.x, mouse.y);
			}

			onWheel: {
				var flick = editor.getFlick();
				var step = editor.getLineHeight() * 20;
				if (wheel.angleDelta.y < 0)
					flick.contentY += step;
				else
					flick.contentY -= step;
				if (flick.contentY < 0)
					flick.contentY = 0;
				var clip = flick.contentHeight - flick.height;
				if (clip < 0)
					clip = 0;
				if (flick.contentY > clip)
					flick.contentY = clip;
			}

			onClicked: mouse.accepted = false;
			onPressed: mouse.accepted = false;
			onReleased: mouse.accepted = false;
			onDoubleClicked: mouse.accepted = false;
			onPressAndHold: mouse.accepted = false;
		}

		function renderShader()
		{
			shaderItem.fragmentShaderSource = main.shaderEdit;
		}
	}
}
