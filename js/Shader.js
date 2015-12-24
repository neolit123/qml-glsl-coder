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
SHADER_DEFAULT = "\
uniform sampler2D source;
varying highp vec2 coord;
uniform highp vec2 mouse;
uniform highp vec2 resolution;
uniform highp float time;

void main()
{
	vec2 pos = gl_FragCoord.xy / resolution.xy;
	vec3 c = vec3(pos.x, pos.y, sin(time));
	gl_FragColor = vec4(c, 1.0);
}
";
