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

		readonly property int frameLength: 16;

		property real quality: 2.0;
		property bool smoothing: false;
		property size resolutionProp: Qt.size(main.width / quality, main.height / quality);
		property point mouseProp: Qt.point(0, 0);
		property string defaultFont: "Courier New";
		property real timeProp: 0;
		property real startTime: 0;
		property var shaderEffect: null;

		property string imageURL: "";
		property string shaderEdit: "";
		property string lastValidShader: ""
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
				main.smoothing = !main.smoothing;
				break;
			case Qt.Key_F10:
				tempQ *= 2.0;
				if (tempQ > 16.0)
					tempQ = 16.0;
				quality = tempQ;
				break;
			case Qt.Key_F11:
				tempQ *= 0.5;
				if (tempQ < 0.25)
					tempQ = 0.25;
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

		/*
		Image {
			id: imageSource;
			anchors.fill: parent;
			source: main.imageURL;
			// why the flipping here??
			transform: Scale { xScale: 1; yScale: -1; origin.x: main.width / 2; origin.y: main.height / 2; }
		}
		*/

		ShaderItem {
			id: shaderItem
			anchors.fill: parent;
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

		/* a timer to update the 'time' property in the shader */
		Timer {
			id: fpsTimer
			interval: main.frameLength;
			running: true
			repeat: true

			onTriggered: {
				main.timeProp = (Date.now() - main.startTime) / 1000;
				/*
				if (main.shaderEdit === editor.getText())
					return;
				main.shaderEdit = editor.getText();
				main.renderShader();
				*/
			}

			Component.onCompleted: {
				main.startTime = Date.now();
				main.shaderEdit = editor.getText();
				main.renderShader();
			}
		}

		/* a mouse area to catch movements */
		MouseArea {
			id: mouseArea
			anchors.fill: parent
			hoverEnabled: true
			propagateComposedEvents: true
			preventStealing: false

			onPositionChanged: {
				main.mouseProp.x = mouse.x / main.width;
				main.mouseProp.y = 1.0 - mouse.y / main.height;
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

		function checkErrors(activeObject) {
			if (main.shaderEffect != activeObject)
				return;
			if (main.shaderEffect.status === ShaderEffect.Compiled) {
				main.lastValidShader = main.shaderEffect.fragmentShader;
				editor.setLogText("Compiled " + (new Date()).toTimeString(), false);
				return;
			}
			if (main.shaderEffect.status === ShaderEffect.Error)
				editor.setLogText(main.shaderEffect.log, true);
		}

		/* updating the .fragmentShader of a ShaderEffect desn't work, which makes
		 * ShaderEffects non-reusable. to work around the issue we create a
		 * new 'shaderEffect' instance on each text change */
		function renderShader()
		{
			shaderItem.fragmentShaderSource = main.shaderEdit;
			/*
			var shaderEffectOld = shaderEffect;
			var sh = Shader.getDefaultItem();
			shaderEffect = Qt.createQmlObject(sh, imageSource, "shader");
			var baseZ = shaderEffect.z;
			editor.z = baseZ + 1;
			cursor.z = baseZ + 2;
			mouseArea.z = baseZ + 3;
			fpsCounter.z = baseZ + 4;

			if (shaderEffectOld != null) {
				shaderEffectOld.visible = false
				shaderEffectOld.destroy(main.frameLength / 2);
			}
			*/
		}
	}
}
