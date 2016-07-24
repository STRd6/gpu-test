module.exports = """
precision mediump float;
varying vec2 texCoord;

float rand(vec2 co){
  return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

void main() {
  gl_FragColor = vec4(0, 1, 0, 1);  // green
}
"""
