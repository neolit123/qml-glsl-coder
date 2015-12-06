uniform sampler2D source;
varying highp vec2 coord;
uniform highp vec2 mouse;
uniform highp vec2 resolution;
uniform highp float time;
uniform lowp float qt_Opacity;

// shader taken from http://glslsandbox.com

void main()
{
	vec2 position = (gl_FragCoord.xy / resolution.xy) + mouse / 4.0;

	float color = 0.0;
	color += sin(position.x * cos(time / 3.0) * 80.0) + cos(position.y * cos(time / 15.0) * 10.0);
	color += sin(position.y * sin(time / 10.0) * 40.0) + cos(position.x * sin(time / 25.0) * 40.0);
	color += sin(position.x * sin(time / 5.0) * 10.0) + sin(position.y * sin(time / 35.0) * 80.0);
	color *= sin(time / 10.0) * 0.5;

	gl_FragColor = vec4(vec3(color, color * 0.2, sin(color + time / 3.0) * 0.75), 1.0);
}
