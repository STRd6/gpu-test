require "./setup"

gl = canvas.getContext("webgl")

{createProgram} = require "./util"

vertexSource = require "./vertex/2d"
fragmentSource = require "./fragment/texture"
program = createProgram(gl, vertexSource, fragmentSource)
gl.useProgram(program)

image = new Image()
image.crossOrigin = "Anonymous"
image.src = "https://danielx.whimsy.space/DawnLike/Objects/Wall.png?o_0"
image.onload = ->
  render(image)

render = (image) ->
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
       1.0,  1.0
    ])
    gl.STATIC_DRAW
  )
  
  positionLocation = gl.getAttribLocation(program, "position")
  gl.enableVertexAttribArray(positionLocation)
  gl.vertexAttribPointer(positionLocation, 2, gl.FLOAT, false, 0, 0)
  
  # look up where the texture coordinates need to go.
  texCoordLocation = gl.getAttribLocation(program, "a_texCoord");
  
  # provide texture coordinates for the rectangle.
  texCoordBuffer = gl.createBuffer();
  gl.bindBuffer(gl.ARRAY_BUFFER, texCoordBuffer);
  gl.bufferData(gl.ARRAY_BUFFER, new Float32Array([
      0.0,  0.0,
      1.0,  0.0,
      0.0,  1.0,
      0.0,  1.0,
      1.0,  0.0,
      1.0,  1.0]), 
    gl.STATIC_DRAW
  )
  gl.enableVertexAttribArray(texCoordLocation);
  gl.vertexAttribPointer(texCoordLocation, 2, gl.FLOAT, false, 0, 0);
  
  # Create a texture.
  texture = gl.createTexture();
  gl.bindTexture(gl.TEXTURE_2D, texture);
  
  # Set the parameters so we can render any size image.
  gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
  gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
  gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST);
  gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST);
  
  # Upload the image into the texture.
  gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, image);
  
  gl.drawArrays(gl.TRIANGLES, 0, 6)
