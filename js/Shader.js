.pragma library

// declarations
var SHADER_DEFAULT;

// -----------------------------------------------------------------------------
// methods
function getDefault()
{
	return SHADER_DEFAULT;
}

// -----------------------------------------------------------------------------
function getDefaultItem()
{
	return "\
import QtQuick 2.5;

ShaderEffect {
	id: shader

	width: parent.width
	height: parent.height
	layer.enabled: true
	layer.textureSize: Qt.size(main.width / main.quality, main.height / main.quality)
	layer.smooth: main.smoothing

	property variant source: imageSource
	property variant mouse: main.mouseProp
	property variant resolution: main.resolutionProp
	property real time: main.timeProp

	vertexShader: \"
		uniform highp mat4 qt_Matrix;
		attribute highp vec4 qt_Vertex;
		attribute highp vec2 qt_MultiTexCoord0;
		varying highp vec2 coord;
		void main()
		{
			coord = qt_MultiTexCoord0;
			coord.y = 1.0 - coord.y; // why??
			gl_Position = qt_Matrix * qt_Vertex;
		}\";

	fragmentShader: main.shaderEdit
	onStatusChanged: main.checkErrors(this)
}
";
}

// -----------------------------------------------------------------------------
SHADER_DEFAULT = "\
uniform sampler2D source;
varying highp vec2 coord;
uniform highp vec2 mouse;
uniform highp vec2 resolution;
uniform highp float time;
uniform lowp float qt_Opacity;

void main()
{
	vec2 pos = gl_FragCoord.xy / resolution.xy;
	vec3 c = vec3(pos.x, pos.y, sin(time));
	gl_FragColor = vec4(c, 1.0);
}
";
