require "./setup"

gl = canvas.getContext("webgl")

kernels = require "./kernels"
{createProgram} = require "./util"

vertexSource = require "./vertex/convolution"
fragmentSource = require "./fragment/convolution"
program = createProgram(gl, vertexSource, fragmentSource)
gl.useProgram(program)

loadImage = (url) ->
  new Promise (resolve, reject) ->
    image = new Image()
    image.crossOrigin = "Anonymous"

    image.onload = ->
      resolve image
    image.onerror = reject
    image.src = url

loadTexture = (gl, image) ->
  # Create a texture
  texture = gl.createTexture()
  gl.bindTexture(gl.TEXTURE_2D, texture)

  # Set the parameters so we can render any size image
  gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE)
  gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE)
  gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST)
  gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST)

  # Upload the image into the texture
  gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, image)

  # set the size of the image
  textureSizeLocation = gl.getUniformLocation(program, "u_textureSize")
  gl.uniform2f(textureSizeLocation, image.width, image.height)

  return texture

loadDataAsTexture = (gl, width, height, data) ->
  # Create a texture
  texture = gl.createTexture()
  gl.bindTexture(gl.TEXTURE_2D, texture)

  # Set the parameters so we can render any size texture
  gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE)
  gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE)
  gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST)
  gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST)

  gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, width, height, 0, gl.RGBA, gl.UNSIGNED_BYTE, data)

  # set the size of the texture
  textureSizeLocation = gl.getUniformLocation(program, "u_textureSize")
  gl.uniform2f(textureSizeLocation, width, height)

  return texture

configureVertices = (gl) ->
  # Create a buffer and put a single clipspace rectangle in
  # it (2 triangles)
  # We create a buffer, fill it with six pairs of floats (two triangles)
  # and bind it to the a_position attribute
  buffer = gl.createBuffer()
  gl.bindBuffer(gl.ARRAY_BUFFER, buffer)
  gl.bufferData(
    gl.ARRAY_BUFFER
    new Float32Array([
      -1, -1
       1, -1
      -1,  1
      -1,  1
       1, -1
       1,  1
    ])
    gl.STATIC_DRAW
  )
  positionLocation = gl.getAttribLocation(program, "a_position")
  gl.enableVertexAttribArray(positionLocation)
  gl.vertexAttribPointer(positionLocation, 2, gl.FLOAT, false, 0, 0)

  # provide texture coordinates for the rectangle
  # we set six pairs of floats that get bound to a_texCoord attribute
  # this matches the six vertexes we render in the call to gl.drawArrays and
  # the six vertex coordinates added above
  texCoordBuffer = gl.createBuffer()
  gl.bindBuffer(gl.ARRAY_BUFFER, texCoordBuffer)
  gl.bufferData(
    gl.ARRAY_BUFFER
    new Float32Array([
      0.0,  0.0,
      1.0,  0.0,
      0.0,  1.0,
      0.0,  1.0,
      1.0,  0.0,
      1.0,  1.0,
    ])
    gl.STATIC_DRAW
  )
  texCoordLocation = gl.getAttribLocation(program, "a_texCoord")
  gl.enableVertexAttribArray(texCoordLocation)
  gl.vertexAttribPointer(texCoordLocation, 2, gl.FLOAT, false, 0, 0)

render = (texture, kernel="identity", outputBuffer) ->
  gl.bindTexture(gl.TEXTURE_2D, texture)
  gl.bindFramebuffer(gl.FRAMEBUFFER, outputBuffer)

  # Bind our kernel params
  kernelLocation = gl.getUniformLocation(program, "u_kernel[0]")
  kernelWeightLocation = gl.getUniformLocation(program, "u_kernelWeight")
  gl.uniform1fv(kernelLocation, kernels[kernel])
  gl.uniform1f(kernelWeightLocation, 1)

  gl.drawArrays(gl.TRIANGLES, 0, 6)

{spark, histogram} = require "./util/histogram"

configureVertices(gl)

->
  loadImage("https://danielx.whimsy.space/DawnLike/Objects/Wall.png?o_0").then (image) ->
    texture = loadTexture(gl, image)
    render(texture)

rand = ->
  Math.floor Math.random() * 256

show = (data) ->
  sampleChunk = data.slice(0, 1024)
  console.log sampleChunk
  console.log spark histogram sampleChunk

do ->
  # Load random data then guassian blur it into an output buffer
  # also mirror that output buffer to the canvas so we can visually follow its
  # progress
  #
  # The output buffer is then swaped to become the input buffer and the
  # operation is repeated.
  # Eventually we can use this to set up arbitrary pipelines to perform
  # custom programs like fluid dynamics, heat dispersion, or any other
  # computationals simulations.

  {width, height} = require "./pixie"
  data = new Uint8Array width * height * 4
  output = new Uint8Array width * height * 4

  outTexture = loadDataAsTexture(gl, width, height, output)
  outBuffer = gl.createFramebuffer()
  gl.bindFramebuffer(gl.FRAMEBUFFER, outBuffer)
  gl.framebufferTexture2D(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, gl.TEXTURE_2D, outTexture, 0)

  data.forEach (v, i) ->
    data[i] = rand()

  inTexture = loadDataAsTexture(gl, width, height, data)
  inBuffer = gl.createFramebuffer()
  gl.bindFramebuffer(gl.FRAMEBUFFER, inBuffer)
  gl.framebufferTexture2D(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, gl.TEXTURE_2D, inTexture, 0)

  kernelNames = [
    "gaussianBlur"
    #"moveUp"
  ]

  i = 0
  blur = ->
    # show data
    kernel = kernelNames[i % kernelNames.length]
    render(inTexture, kernel, outBuffer)
    render(inTexture, kernel, null)
    [inTexture, outTexture] = [outTexture, inTexture]
    [inBuffer, outBuffer] = [outBuffer, inBuffer]
    #gl.readPixels(0, 0, width, height, gl.RGBA, gl.UNSIGNED_BYTE, output)
    #[data, output] = [output, data]
    i += 1

  setInterval ->
    n = 1
    console.log "x#{n}"
    console.time("blur")
    [0...n].forEach ->
      blur()
    console.timeEnd("blur")
  , 100
