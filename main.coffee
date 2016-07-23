webGLStart = -> 
  canvas = document.createElement("canvas")
  document.body.appendChild(canvas)

  gl = getGL(canvas)

  fragmentShader = compileShader(gl, require("./shaders/fragment"), gl.FRAGMENT_SHADER)
  vertexShader = compileShader(gl, require("./shaders/vertex"), gl.VERTEX_SHADER)

  program = createProgram(gl, vertexShader, fragmentShader)
  vertexPositionBuffer = createBuffer(gl)

  gl.clearColor(0.0, 0.0, 0.0, 1.0)
  gl.enable(gl.DEPTH_TEST)

  drawScene(gl, program, vertexPositionBuffer)

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

createBuffer = (gl) ->
  vertexPositionBuffer = gl.createBuffer()
  gl.bindBuffer(gl.ARRAY_BUFFER, vertexPositionBuffer)
  vertices = [
       1.0,  1.0
      -1.0,  1.0
       1.0, -1.0
      -1.0, -1.0
  ]

  gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(vertices), gl.STATIC_DRAW)
  vertexPositionBuffer.itemSize = 2
  vertexPositionBuffer.numItems = 4

  return vertexPositionBuffer

baseCorners = [
  [ 0.7,  1.2]
  [-2.2,  1.2]
  [ 0.7, -1.2]
  [-2.2, -1.2]
]

zoom = 1
centerOffsetX = 0
centerOffsetY = 0

drawScene = (gl, program, vertexPositionBuffer) ->
  aVertexPosition = gl.getAttribLocation(program, "aVertexPosition")
  gl.enableVertexAttribArray(aVertexPosition)

  aPlotPosition = gl.getAttribLocation(program, "aPlotPosition")
  gl.enableVertexAttribArray(aPlotPosition)

  gl.viewport(0, 0, gl.viewportWidth, gl.viewportHeight)
  gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)
  gl.bindBuffer(gl.ARRAY_BUFFER, vertexPositionBuffer)
  gl.vertexAttribPointer(aVertexPosition, vertexPositionBuffer.itemSize, gl.FLOAT, false, 0, 0)

  plotPositionBuffer = gl.createBuffer()
  gl.bindBuffer(gl.ARRAY_BUFFER, plotPositionBuffer)

  corners = []
  baseCorners.forEach ([x, y]) ->
    corners.push(x / zoom + centerOffsetX)
    corners.push(y / zoom + centerOffsetY)

  gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(corners), gl.STATIC_DRAW)
  gl.vertexAttribPointer(aPlotPosition, 2, gl.FLOAT, false, 0, 0)
  gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4)
  gl.deleteBuffer(plotPositionBuffer)

webGLStart()
