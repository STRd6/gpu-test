module.exports = """
  precision mediump float;
  attribute vec2 position;

  attribute vec2 a_texCoord;
  varying vec2 v_texCoord;

  void main(void) {
    gl_Position = vec4(position, 0, 1);
    v_texCoord = a_texCoord;
  }
"""
