// by candycat @ shadertoy

uniform highp float time;
uniform highp vec2 mouse;
uniform highp vec2 resolution;
varying highp vec2 texCoord;
uniform sampler2D texture;

float sdfCircle(vec2 center, float radius, vec2 coord )
{
    vec2 offset = coord - center;
    
    return sqrt((offset.x * offset.x) + (offset.y * offset.y)) - radius;
}

float sdfEllipse(vec2 center, float a, float b, vec2 coord)
{
    float a2 = a * a;
    float b2 = b * b;
    return (b2 * (coord.x - center.x) * (coord.x - center.x) + 
        a2 * (coord.y - center.y) * (coord.y - center.y) - a2 * b2)/(a2 * b2);
}

float sdfLine(vec2 p0, vec2 p1, float width, vec2 coord)
{
    vec2 dir0 = p1 - p0;
	vec2 dir1 = coord - p0;
	float h = clamp(dot(dir0, dir1)/dot(dir0, dir0), 0.0, 1.0);
	return (length(dir1 - dir0 * h) - width * 0.5);
}

float sdfUnion( const float a, const float b )
{
    return min(a, b);
}

float sdfDifference( const float a, const float b)
{
    return max(a, -b);
}

float sdfIntersection( const float a, const float b )
{
    return max(a, b);
}

vec4 render(float d, vec3 color, float stroke)
{
    //stroke = fwidth(d) * 2.0;
    float anti = fwidth(d) * 1.0;
    vec4 strokeLayer = vec4(vec3(0.05), 1.0-smoothstep(-anti, anti, d - stroke));
    vec4 colorLayer = vec4(color, 1.0-smoothstep(-anti, anti, d));

    if (stroke < 0.000001) {
    	return colorLayer;
    }
    return vec4(mix(strokeLayer.rgb, colorLayer.rgb, colorLayer.a), strokeLayer.a);
}

void main()
{
	float size = min(resolution.x, resolution.y);
    float pixSize = 1.0 / size;
	vec2 uv = gl_FragCoord.xy / resolution.x;
    float stroke = pixSize * 1.5;
    vec2 center = vec2(0.5, 0.5 * resolution.y/resolution.x);
    
    float a = sdfEllipse(vec2(0.5, center.y*2.0-0.34), 0.25, 0.25, uv);
    float b = sdfEllipse(vec2(0.5, center.y*2.0+0.03), 0.8, 0.35, uv);
    b = sdfIntersection(a, b);
    vec4 layer1 = render(b, vec3(0.32, 0.56, 0.53), fwidth(b) * 2.0);
    
    // Draw strips
    vec4 layer2 = layer1;
    float t, r0, r1, r2, e, f;
    vec2 sinuv = vec2(uv.x, (sin(uv.x*40.0)*0.02 + 1.0)*uv.y);
    for (float i = 0.0; i < 10.0; i++) {
    	t = mod(time + 0.3 * i, 3.0) * 0.2;
    	r0 = (t - 0.15) / 0.2 * 0.9 + 0.1;
    	r1 = (t - 0.15) / 0.2 * 0.1 + 0.9;
        r2 = (t - 0.15) / 0.2 * 0.15 + 0.85;
        e = sdfEllipse(vec2(0.5, center.y*2.0+0.37-t*r2), 0.7*r0, 0.35*r1, sinuv);
    	f = sdfEllipse(vec2(0.5, center.y*2.0+0.41-t), 0.7*r0, 0.35*r1, sinuv);
    	f = sdfDifference(e, f);
    	f = sdfIntersection(f, b);
    	vec4 layer = render(f, vec3(1.0, 0.81, 0.27), 0.0);
        layer2 = mix(layer2, layer, layer.a);
    }
    
    
    // Draw the handle
    float bottom = 0.08;
    float handleWidth = 0.01;
    float handleRadius = 0.04;
    float d = sdfCircle(vec2(0.5-handleRadius+0.5*handleWidth, bottom), handleRadius, uv);
    float c = sdfCircle(vec2(0.5-handleRadius+0.5*handleWidth, bottom), handleRadius-handleWidth, uv);
    d = sdfDifference(d, c);
    c = uv.y - bottom;
    d = sdfIntersection(d, c);
    c = sdfLine(vec2(0.5, center.y*2.0-0.05), vec2(0.5, bottom), handleWidth, uv);
    d = sdfUnion(d, c);
    c = sdfCircle(vec2(0.5, center.y*2.0-0.05), 0.01, uv);
    d = sdfUnion(c, d);
    c = sdfCircle(vec2(0.5-handleRadius*2.0+handleWidth, bottom), handleWidth*0.5, uv);
    d = sdfUnion(c, d);
    vec4 layer0 = render(d, vec3(0.404, 0.298, 0.278), stroke);
    
    vec2 p = (2.0*gl_FragCoord.xy-resolution.xy)/min(resolution.y,resolution.x);
    vec3 bcol = vec3(1.0,0.8,0.7-0.07*p.y)*(1.0-0.25*length(p));
    gl_FragColor = vec4(bcol, 1.0);  
    gl_FragColor.rgb = mix(gl_FragColor.rgb, layer0.rgb, layer0.a);
    gl_FragColor.rgb = mix(gl_FragColor.rgb, layer1.rgb, layer1.a);
    gl_FragColor.rgb = mix(gl_FragColor.rgb, layer2.rgb, layer2.a);
    
    gl_FragColor.rgb = pow(gl_FragColor.rgb, vec3(1.0/2.2));
}
