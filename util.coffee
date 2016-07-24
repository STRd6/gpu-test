compileShader = (gl, source, type) ->
  shader = gl.createShader(type)

  gl.shaderSource(shader, source)
  gl.compileShader(shader)

  if !gl.getShaderParameter(shader, gl.COMPILE_STATUS)
    throw new Error gl.getShaderInfoLog(shader)

  return shader

createProgram = (gl, vertexSource, fragmentSource) ->
  vertexShader = compileShader(gl, vertexSource, gl.VERTEX_SHADER)
  fragmentShader = compileShader(gl, fragmentSource, gl.FRAGMENT_SHADER)

  shaderProgram = gl.createProgram()
  gl.attachShader(shaderProgram, vertexShader)
  gl.attachShader(shaderProgram, fragmentShader)
  gl.linkProgram(shaderProgram)

  if !gl.getProgramParameter(shaderProgram, gl.LINK_STATUS)
    throw new Error "Could not initialise shaders"

  gl.useProgram(shaderProgram)

  return shaderProgram
  

module.exports =
  createProgram: createProgram

