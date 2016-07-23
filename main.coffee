{mat4} = glMatrix = require "./lib/gl-matrix.min"
console.log glMatrix

webGLStart = -> 
  canvas = document.createElement("canvas")
  canvas.width = canvas.height = 500
  document.body.appendChild(canvas)

  gl = getGL(canvas)

  fragmentShader = compileShader(gl, require("./shaders/fragment"), gl.FRAGMENT_SHADER)
  vertexShader = compileShader(gl, require("./shaders/vertex"), gl.VERTEX_SHADER)

  program = createProgram(gl, vertexShader, fragmentShader)
  addLocationsToProgram(gl, program)
  
  triangleBuffer = createTriangleBuffer(gl)
  squareBuffer = createSquareBuffer(gl)
  
  pMatrix = mat4.create()
  mvMatrix = mat4.create()
  
  gl.uniformMatrix4fv(program.pMatrixUniform, false, pMatrix)
  gl.uniformMatrix4fv(program.mvMatrixUniform, false, mvMatrix)

  gl.clearColor(0.0, 0.0, 0.0, 1.0)
  gl.enable(gl.DEPTH_TEST)

  drawScene(gl, program, triangleBuffer, squareBuffer, pMatrix, mvMatrix)

getGL = (canvas) ->
  try
    gl = canvas.getContext("webgl")
    gl.viewportWidth = canvas.width
    gl.viewportHeight = canvas.height

  if !gl
    throw new Error "Could not initialise WebGL, sorry :-("

  return gl

compileShader = (gl, source, type) ->
  shader = gl.createShader(type)

  gl.shaderSource(shader, source)
  gl.compileShader(shader)

  if !gl.getShaderParameter(shader, gl.COMPILE_STATUS)
    throw new Error gl.getShaderInfoLog(shader)

  return shader

createProgram = (gl, vertexShader, fragmentShader) ->
  shaderProgram = gl.createProgram()
  gl.attachShader(shaderProgram, vertexShader)
  gl.attachShader(shaderProgram, fragmentShader)
  gl.linkProgram(shaderProgram)

  if !gl.getProgramParameter(shaderProgram, gl.LINK_STATUS)
    throw new Error "Could not initialise shaders"

  gl.useProgram(shaderProgram)

  return shaderProgram

addLocationsToProgram = (gl, program) ->
  program.vertexPositionAttribute = gl.getAttribLocation(program, "aVertexPosition")
  gl.enableVertexAttribArray(program.vertexPositionAttribute)

  program.pMatrixUniform = gl.getUniformLocation(program, "uPMatrix")
  program.mvMatrixUniform = gl.getUniformLocation(program, "uMVMatrix")

  return program

createTriangleBuffer = (gl) ->
  triangleVertexPositionBuffer = gl.createBuffer()
  gl.bindBuffer(gl.ARRAY_BUFFER, triangleVertexPositionBuffer)

  vertices = [
       0.0,  1.0,  0.0
      -1.0, -1.0,  0.0
       1.0, -1.0,  0.0
  ]
  gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(vertices), gl.STATIC_DRAW)

  triangleVertexPositionBuffer.itemSize = 3
  triangleVertexPositionBuffer.numItems = 3

  return triangleVertexPositionBuffer

createSquareBuffer = (gl) ->
  squareVertexPositionBuffer = gl.createBuffer()
  gl.bindBuffer(gl.ARRAY_BUFFER, squareVertexPositionBuffer)
  vertices = [
       1.0,  1.0,  0.0
      -1.0,  1.0,  0.0
       1.0, -1.0,  0.0
      -1.0, -1.0,  0.0
  ]
  gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(vertices), gl.STATIC_DRAW)

  squareVertexPositionBuffer.itemSize = 3
  squareVertexPositionBuffer.numItems = 4

  return squareVertexPositionBuffer

drawScene = (gl, program, triangleVertexPositionBuffer, squareVertexPositionBuffer, pMatrix, mvMatrix) ->
  gl.viewport(0, 0, gl.viewportWidth, gl.viewportHeight)
  gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)

  mat4.perspective(45, gl.viewportWidth / gl.viewportHeight, 0.1, 100.0, pMatrix)
  mat4.identity(mvMatrix)

  mat4.translate(mvMatrix, [-1.5, 0.0, -7.0])
  gl.bindBuffer(gl.ARRAY_BUFFER, triangleVertexPositionBuffer)
  gl.vertexAttribPointer(program.vertexPositionAttribute, triangleVertexPositionBuffer.itemSize, gl.FLOAT, false, 0, 0)
  setMatrixUniforms()
  gl.drawArrays(gl.TRIANGLES, 0, triangleVertexPositionBuffer.numItems)
  
  mat4.translate(mvMatrix, [3.0, 0.0, 0.0])
  gl.bindBuffer(gl.ARRAY_BUFFER, squareVertexPositionBuffer)
  gl.vertexAttribPointer(program.vertexPositionAttribute, squareVertexPositionBuffer.itemSize, gl.FLOAT, false, 0, 0)
  setMatrixUniforms()
  gl.drawArrays(gl.TRIANGLE_STRIP, 0, squareVertexPositionBuffer.numItems)


webGLStart()
