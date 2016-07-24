require "./setup"

gl = canvas.getContext("webgl")

{createProgram} = require "./util"

vertexSource = require "./vertex/2d"
fragmentSource = require "./fragment/texture"
program = createProgram(gl, vertexSource, fragmentSource)
gl.useProgram(program)

# Create a buffer and put a single clipspace rectangle in
# it (2 triangles)
buffer = gl.createBuffer()
gl.bindBuffer(gl.ARRAY_BUFFER, buffer)
gl.bufferData(
  gl.ARRAY_BUFFER
  new Float32Array([
      -1.0, -1.0
       1.0, -1.0
      -1.0,  1.0
      -1.0,  1.0
       1.0, -1.0
       1.0,  1.0])
  gl.STATIC_DRAW
)

positionLocation = gl.getAttribLocation(program, "position")
gl.enableVertexAttribArray(positionLocation)
gl.vertexAttribPointer(positionLocation, 2, gl.FLOAT, false, 0, 0)

gl.drawArrays(gl.TRIANGLES, 0, 6)
