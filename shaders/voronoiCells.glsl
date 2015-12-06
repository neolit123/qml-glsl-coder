uniform sampler2D source;
varying highp vec2 coord;
uniform highp vec2 mouse;
uniform highp vec2 resolution;
uniform highp float time;
uniform lowp float qt_Opacity;

// shader from GLSL-sandbox

vec2 random2f(vec2 p)
{
	vec2 tmp = fract(vec2(sin(p.x * 591.32 + p.y * 154.077), cos(p.x * 391.32 + p.y * 49.077)));
	return vec2(0.5 + 0.5 * sin(tmp.x * time * mouse.x + p.y), mouse.y + 0.5 * cos(tmp.y * time * mouse.y + p.x));
}

float voronoi(in vec2 x)
{
	vec2 p = vec2(floor(x));
	vec2 f = fract(x);

	float res = 8.0;
	const float s = 1.0;
	for (float j = -s; j <= s; j++) {
		for (float i = -s; i <= s; i++) {
			vec2 b = vec2(i, j);
			vec2  r = b - f + random2f(b + p);
			float d = length(r);
			res = min(res, d);
		}
	}
	return res;
}

void main(void)
{
	vec2 p = gl_FragCoord.xy / resolution.xy;
	p.x *= resolution.x / resolution.y;
	vec2 q = 2.0 * p - 1.0;

	float col = voronoi(q * 10.0);
	float t0 = cos(time / 20.0) * 0.5;
	float t1 = mouse.x / 2.0 + cos(time / 1000.0) + sin(time / 10.0) * 0.5;
	float t2 = 1.0 / mouse.y + cos(time / 5.0) * 0.5;
	gl_FragColor = vec4(col * t0, col * t1, col * t2, 1.0);
}
