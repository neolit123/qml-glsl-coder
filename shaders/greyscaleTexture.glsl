varying highp vec2 coord;
uniform sampler2D source;
uniform lowp float qt_Opacity;

void main()
{
	lowp vec4 tex = texture2D(source, coord);
	gl_FragColor = vec4(vec3(dot(tex.rgb,
		vec3(0.344, 0.5, 0.156))),
		tex.a) * qt_Opacity;

}
