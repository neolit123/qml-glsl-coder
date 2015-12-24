uniform highp float time;
uniform highp vec2 mouse;
uniform highp vec2 resolution;
varying highp vec2 texCoord;
uniform sampler2D texture;

void main()
{
	lowp vec4 tex = texture2D(texture, texCoord);
	gl_FragColor = vec4(vec3(dot(tex.rgb,
		vec3(0.344, 0.5, 0.156))),
		tex.a);

}
