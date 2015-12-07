import QtQuick 2.5
import QtQuick.Dialogs 1.2

Item {
	id: dialogs

	function showExit()
	{
		exitDialog.visible = true;
	}

	function showHelp()
	{
		helpDialog.visible = true;
	}

	readonly property string filterImage: "Image files (*.jpg *.jpeg *.gif *.png *.bmp *.tif *.tiff)";
	readonly property string filterGLSL: "GLSL fragment shaders (*.glsl *.frag)";
	property string currentFolder: "./";
	property string currentFile: "";
	property string saveString: "";
	property var openCallback: null;
	property var openImageCallback: null;
	property var saveCallback: null;

	function openImageFile(callback)
	{
		openCallback = null;
		openImageCallback = callback;
		saveCallback = null;
		saveString = "";
		fileDialog.selectedNameFilter = filterImage;
		fileDialog.folder = currentFolder;
		fileDialog.title = "Open image file";
		fileDialog.selectExisting = true;
		fileDialog.visible = true;
	}

	function openFile(callback)
	{
		openCallback = callback;
		openImageCallback = null;
		saveCallback = null;
		saveString = "";
		fileDialog.selectedNameFilter = filterGLSL;
		fileDialog.folder = currentFolder;
		fileDialog.title = "Open file";
		fileDialog.selectExisting = true;
		fileDialog.visible = true;
	}

	function saveFile(callback, str)
	{
		openCallback = null;
		openImageCallback = null;
		saveCallback = callback;
		saveString = str;
		fileDialog.selectedNameFilter = filterGLSL;
		fileDialog.folder = currentFolder;
		fileDialog.title = "Save file";
		fileDialog.selectExisting = false;
		fileDialog.visible = true;
	}

	FileDialog {
		id: fileDialog
		modality: Qt.ApplicationModal
		title: ""
		folder: shortcuts.home
		nameFilters: [ filterGLSL, filterImage ];
		onAccepted: {
			var str;
			currentFile = fileDialog.fileUrl;
			currentFolder = currentFile.substring(0, currentFile.lastIndexOf("/"));
			if (openCallback) {
				str = context.readFile(currentFile);
				openCallback(str);
				return;
			}
			if (openImageCallback) {
				openImageCallback(currentFile);
				return;
			}
			if (saveString != "") {
				context.writeFile(currentFile, saveString);
				if (saveCallback)
					saveCallback();
				return;
			}
		}
		onRejected:	{
			fileDialog.visible = false;
			if (openCallback) {
				openCallback("");
				return;
			}
			if (openImageCallback) {
				openImageCallback("");
				return;
			}
			if (saveCallback) {
				saveCallback();
				return;
			}
		}
	}

	MessageDialog {
		id: exitDialog
		title: "Exit"
		text: "Are you sure you want to exit?"
		standardButtons: StandardButton.Yes | StandardButton.No
		icon: StandardIcon.Question
		onYes: accepted();
		onAccepted: Qt.quit()
		Component.onCompleted: visible = false
	}

	Dialog {
		id: helpDialog
		title: "Help"
		width: helpDialogText.width;
		height: helpDialogText.height;
		standardButtons: StandardButton.Close

		Text {
			id: helpDialogText
			font.family: main.defaultFont;
			text: "\
" + context.buildName() + " v" + context.buildVersion() + "
by neolit123
" + context.buildTime() + "

ESC: exit
F1:  help
F2:  toggle FPS counter
F3:  toggle cursor
F4:  toggle editor
F5:  recompile
F6:  load image file
F7:  load GLSL file
F8:  save GLSL file
F9:  toggle smoothing
F10: decrease quality
F11: increase quality
F12: toggle fullscreen
			";
		}
	}
}
