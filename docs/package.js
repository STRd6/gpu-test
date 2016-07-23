(function(pkg) {
  (function() {
  var annotateSourceURL, cacheFor, circularGuard, defaultEntryPoint, fileSeparator, generateRequireFn, global, isPackage, loadModule, loadPackage, loadPath, normalizePath, publicAPI, rootModule, startsWith,
    __slice = [].slice;

  fileSeparator = '/';

  global = self;

  defaultEntryPoint = "main";

  circularGuard = {};

  rootModule = {
    path: ""
  };

  loadPath = function(parentModule, pkg, path) {
    var cache, localPath, module, normalizedPath;
    if (startsWith(path, '/')) {
      localPath = [];
    } else {
      localPath = parentModule.path.split(fileSeparator);
    }
    normalizedPath = normalizePath(path, localPath);
    cache = cacheFor(pkg);
    if (module = cache[normalizedPath]) {
      if (module === circularGuard) {
        throw "Circular dependency detected when requiring " + normalizedPath;
      }
    } else {
      cache[normalizedPath] = circularGuard;
      try {
        cache[normalizedPath] = module = loadModule(pkg, normalizedPath);
      } finally {
        if (cache[normalizedPath] === circularGuard) {
          delete cache[normalizedPath];
        }
      }
    }
    return module.exports;
  };

  normalizePath = function(path, base) {
    var piece, result;
    if (base == null) {
      base = [];
    }
    base = base.concat(path.split(fileSeparator));
    result = [];
    while (base.length) {
      switch (piece = base.shift()) {
        case "..":
          result.pop();
          break;
        case "":
        case ".":
          break;
        default:
          result.push(piece);
      }
    }
    return result.join(fileSeparator);
  };

  loadPackage = function(pkg) {
    var path;
    path = pkg.entryPoint || defaultEntryPoint;
    return loadPath(rootModule, pkg, path);
  };

  loadModule = function(pkg, path) {
    var args, content, context, dirname, file, module, program, values;
    if (!(file = pkg.distribution[path])) {
      throw "Could not find file at " + path + " in " + pkg.name;
    }
    if ((content = file.content) == null) {
      throw "Malformed package. No content for file at " + path + " in " + pkg.name;
    }
    program = annotateSourceURL(content, pkg, path);
    dirname = path.split(fileSeparator).slice(0, -1).join(fileSeparator);
    module = {
      path: dirname,
      exports: {}
    };
    context = {
      require: generateRequireFn(pkg, module),
      global: global,
      module: module,
      exports: module.exports,
      PACKAGE: pkg,
      __filename: path,
      __dirname: dirname
    };
    args = Object.keys(context);
    values = args.map(function(name) {
      return context[name];
    });
    Function.apply(null, __slice.call(args).concat([program])).apply(module, values);
    return module;
  };

  isPackage = function(path) {
    if (!(startsWith(path, fileSeparator) || startsWith(path, "." + fileSeparator) || startsWith(path, ".." + fileSeparator))) {
      return path.split(fileSeparator)[0];
    } else {
      return false;
    }
  };

  generateRequireFn = function(pkg, module) {
    var fn;
    if (module == null) {
      module = rootModule;
    }
    if (pkg.name == null) {
      pkg.name = "ROOT";
    }
    if (pkg.scopedName == null) {
      pkg.scopedName = "ROOT";
    }
    fn = function(path) {
      var otherPackage;
      if (typeof path === "object") {
        return loadPackage(path);
      } else if (isPackage(path)) {
        if (!(otherPackage = pkg.dependencies[path])) {
          throw "Package: " + path + " not found.";
        }
        if (otherPackage.name == null) {
          otherPackage.name = path;
        }
        if (otherPackage.scopedName == null) {
          otherPackage.scopedName = "" + pkg.scopedName + ":" + path;
        }
        return loadPackage(otherPackage);
      } else {
        return loadPath(module, pkg, path);
      }
    };
    fn.packageWrapper = publicAPI.packageWrapper;
    fn.executePackageWrapper = publicAPI.executePackageWrapper;
    return fn;
  };

  publicAPI = {
    generateFor: generateRequireFn,
    packageWrapper: function(pkg, code) {
      return ";(function(PACKAGE) {\n  var src = " + (JSON.stringify(PACKAGE.distribution.main.content)) + ";\n  var Require = new Function(\"PACKAGE\", \"return \" + src)({distribution: {main: {content: src}}});\n  var require = Require.generateFor(PACKAGE);\n  " + code + ";\n})(" + (JSON.stringify(pkg, null, 2)) + ");";
    },
    executePackageWrapper: function(pkg) {
      return publicAPI.packageWrapper(pkg, "require('./" + pkg.entryPoint + "')");
    },
    loadPackage: loadPackage
  };

  if (typeof exports !== "undefined" && exports !== null) {
    module.exports = publicAPI;
  } else {
    global.Require = publicAPI;
  }

  startsWith = function(string, prefix) {
    return string.lastIndexOf(prefix, 0) === 0;
  };

  cacheFor = function(pkg) {
    if (pkg.cache) {
      return pkg.cache;
    }
    Object.defineProperty(pkg, "cache", {
      value: {}
    });
    return pkg.cache;
  };

  annotateSourceURL = function(program, pkg, path) {
    return "" + program + "\n//# sourceURL=" + pkg.scopedName + "/" + path;
  };

  return publicAPI;

}).call(this);

  window.require = Require.generateFor(pkg);
})({
  "source": {
    "LICENSE": {
      "path": "LICENSE",
      "content": "The MIT License (MIT)\n\nCopyright (c) 2016 Daniel X Moore\n\nPermission is hereby granted, free of charge, to any person obtaining a copy\nof this software and associated documentation files (the \"Software\"), to deal\nin the Software without restriction, including without limitation the rights\nto use, copy, modify, merge, publish, distribute, sublicense, and/or sell\ncopies of the Software, and to permit persons to whom the Software is\nfurnished to do so, subject to the following conditions:\n\nThe above copyright notice and this permission notice shall be included in all\ncopies or substantial portions of the Software.\n\nTHE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR\nIMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,\nFITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE\nAUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER\nLIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,\nOUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE\nSOFTWARE.\n",
      "mode": "100644",
      "type": "blob"
    },
    "README.md": {
      "path": "README.md",
      "content": "# gpu-test\nTesting running code on the gpu\n",
      "mode": "100644",
      "type": "blob"
    },
    "main.coffee": {
      "path": "main.coffee",
      "content": "webGLStart = -> \n  canvas = document.createElement(\"canvas\")\n  gl = getGL(canvas)\n\n  fragmentShader = compileShader(gl, require(\"./shaders/fragment\"), gl.FRAGMENT_SHADER)\n  vertexShader = compileShader(gl, require(\"./shaders/vertex\"), gl.VERTEX_SHADER)\n\n  program = createProgram(gl, vertexShader, fragmentShader)\n  vertexPositionBuffer = createBuffer(gl)\n\n  gl.clearColor(0.0, 0.0, 0.0, 1.0)\n  gl.enable(gl.DEPTH_TEST)\n\n  drawScene(gl, program)\n\ngetGL = (canvas) ->\n  try\n    gl = canvas.getContext(\"webgl\")\n    gl.viewportWidth = canvas.width\n    gl.viewportHeight = canvas.height\n\n  if !gl\n    throw new Error \"Could not initialise WebGL, sorry :-(\"\n\n  return gl\n\ncompileShader = (gl, source, type) ->\n  shader = gl.createShader(type)\n\n  gl.shaderSource(shader, source)\n  gl.compileShader(shader)\n\n  if !gl.getShaderParameter(shader, gl.COMPILE_STATUS)\n    throw new Error gl.getShaderInfoLog(shader)\n\n  return shader\n\ncreateProgram = (gl, vertexShader, fragmentShader) ->\n  shaderProgram = gl.createProgram()\n  gl.attachShader(shaderProgram, vertexShader)\n  gl.attachShader(shaderProgram, fragmentShader)\n  gl.linkProgram(shaderProgram)\n\n  if !gl.getProgramParameter(shaderProgram, gl.LINK_STATUS)\n    throw new Error \"Could not initialise shaders\"\n\n  gl.useProgram(shaderProgram)\n\n  return shaderProgram\n\ncreateBuffer = (gl) ->\n  vertexPositionBuffer = gl.createBuffer()\n  gl.bindBuffer(gl.ARRAY_BUFFER, vertexPositionBuffer)\n  vertices = [\n       1.0,  1.0\n      -1.0,  1.0\n       1.0, -1.0\n      -1.0, -1.0\n  ]\n\n  gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(vertices), gl.STATIC_DRAW)\n  vertexPositionBuffer.itemSize = 2\n  vertexPositionBuffer.numItems = 4\n\n  return vertexPositionBuffer\n\nbaseCorners = [\n  [ 0.7,  1.2]\n  [-2.2,  1.2]\n  [ 0.7, -1.2]\n  [-2.2, -1.2]\n]\n\nzoom = 1\ncenterOffsetX = 0\ncenterOffsetY = 0\n\ndrawScene = (gl, program, vertexPositionBuffer) ->\n  aVertexPosition = gl.getAttribLocation(program, \"aVertexPosition\")\n  gl.enableVertexAttribArray(aVertexPosition)\n\n  aPlotPosition = gl.getAttribLocation(program, \"aPlotPosition\")\n  gl.enableVertexAttribArray(aPlotPosition)\n\n  gl.viewport(0, 0, gl.viewportWidth, gl.viewportHeight)\n  gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)\n  gl.bindBuffer(gl.ARRAY_BUFFER, vertexPositionBuffer)\n  gl.vertexAttribPointer(aVertexPosition, vertexPositionBuffer.itemSize, gl.FLOAT, false, 0, 0)\n\n  plotPositionBuffer = gl.createBuffer();\n  gl.bindBuffer(gl.ARRAY_BUFFER, plotPositionBuffer);\n\n  corners = baseCorners.map ([x, y]) ->\n    corners.push(x / zoom + centerOffsetX)\n    corners.push(y / zoom + centerOffsetY)\n\n  gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(corners), gl.STATIC_DRAW)\n  gl.vertexAttribPointer(aPlotPosition, 2, gl.FLOAT, false, 0, 0)\n  gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4)\n  gl.deleteBuffer(plotPositionBuffer)\n\nwebGLStart()\n",
      "mode": "100644"
    },
    "shaders/fragment.coffee": {
      "path": "shaders/fragment.coffee",
      "content": "module.exports = \"\"\"\n  precision mediump float;\n  varying vec2 vPosition;\n  void main(void) {\n    float cx = vPosition.x;\n    float cy = vPosition.y;\n    \n    float hue;\n    float saturation;\n    float value;\n    float hueRound;\n    int hueIndex;\n    float f;\n    float p;\n    float q;\n    float t;\n    \n    float x = 0.0;\n    float y = 0.0;\n    float tempX = 0.0;\n    int i = 0;\n    int runaway = 0;\n    for (int i=0; i < 100; i++) {\n      tempX = x * x - y * y + float(cx);\n      y = 2.0 * x * y + float(cy);\n      x = tempX;\n      if (runaway == 0 && x * x + y * y > 100.0) {\n        runaway = i;\n      }\n    }\n    \n    if (runaway != 0) {\n      hue = float(runaway) / 200.0;\n      saturation = 0.6;\n      value = 1.0;\n      \n      hueRound = hue * 6.0;\n      hueIndex = int(mod(float(int(hueRound)), 6.0));\n      f = fract(hueRound);\n      p = value * (1.0 - saturation);\n      q = value * (1.0 - f * saturation);\n      t = value * (1.0 - (1.0 - f) * saturation);\n      \n      if (hueIndex == 0)\n        gl_FragColor = vec4(value, t, p, 1.0);\n      else if (hueIndex == 1)\n        gl_FragColor = vec4(q, value, p, 1.0);\n      else if (hueIndex == 2)\n        gl_FragColor = vec4(p, value, t, 1.0);\n      else if (hueIndex == 3)\n        gl_FragColor = vec4(p, q, value, 1.0);\n      else if (hueIndex == 4)\n        gl_FragColor = vec4(t, p, value, 1.0);\n      else if (hueIndex == 5)\n        gl_FragColor = vec4(value, p, q, 1.0);\n        \n    } else {\n      gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);\n    }\n  }\n\"\"\"\n",
      "mode": "100644"
    },
    "shaders/vertex.coffee": {
      "path": "shaders/vertex.coffee",
      "content": "module.exports = \"\"\"\n  attribute vec2 aVertexPosition;\n  attribute vec2 aPlotPosition;\n\n  varying vec2 vPosition;\n\n  void main(void) {\n    gl_Position = vec4(aVertexPosition, 1.0, 1.0);\n    vPosition = aPlotPosition;\n  }\n\"\"\"\n",
      "mode": "100644"
    }
  },
  "distribution": {
    "main": {
      "path": "main",
      "content": "(function() {\n  var baseCorners, centerOffsetX, centerOffsetY, compileShader, createBuffer, createProgram, drawScene, getGL, webGLStart, zoom;\n\n  webGLStart = function() {\n    var canvas, fragmentShader, gl, program, vertexPositionBuffer, vertexShader;\n    canvas = document.createElement(\"canvas\");\n    gl = getGL(canvas);\n    fragmentShader = compileShader(gl, require(\"./shaders/fragment\"), gl.FRAGMENT_SHADER);\n    vertexShader = compileShader(gl, require(\"./shaders/vertex\"), gl.VERTEX_SHADER);\n    program = createProgram(gl, vertexShader, fragmentShader);\n    vertexPositionBuffer = createBuffer(gl);\n    gl.clearColor(0.0, 0.0, 0.0, 1.0);\n    gl.enable(gl.DEPTH_TEST);\n    return drawScene(gl, program);\n  };\n\n  getGL = function(canvas) {\n    var gl;\n    try {\n      gl = canvas.getContext(\"webgl\");\n      gl.viewportWidth = canvas.width;\n      gl.viewportHeight = canvas.height;\n    } catch (_error) {}\n    if (!gl) {\n      throw new Error(\"Could not initialise WebGL, sorry :-(\");\n    }\n    return gl;\n  };\n\n  compileShader = function(gl, source, type) {\n    var shader;\n    shader = gl.createShader(type);\n    gl.shaderSource(shader, source);\n    gl.compileShader(shader);\n    if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {\n      throw new Error(gl.getShaderInfoLog(shader));\n    }\n    return shader;\n  };\n\n  createProgram = function(gl, vertexShader, fragmentShader) {\n    var shaderProgram;\n    shaderProgram = gl.createProgram();\n    gl.attachShader(shaderProgram, vertexShader);\n    gl.attachShader(shaderProgram, fragmentShader);\n    gl.linkProgram(shaderProgram);\n    if (!gl.getProgramParameter(shaderProgram, gl.LINK_STATUS)) {\n      throw new Error(\"Could not initialise shaders\");\n    }\n    gl.useProgram(shaderProgram);\n    return shaderProgram;\n  };\n\n  createBuffer = function(gl) {\n    var vertexPositionBuffer, vertices;\n    vertexPositionBuffer = gl.createBuffer();\n    gl.bindBuffer(gl.ARRAY_BUFFER, vertexPositionBuffer);\n    vertices = [1.0, 1.0, -1.0, 1.0, 1.0, -1.0, -1.0, -1.0];\n    gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(vertices), gl.STATIC_DRAW);\n    vertexPositionBuffer.itemSize = 2;\n    vertexPositionBuffer.numItems = 4;\n    return vertexPositionBuffer;\n  };\n\n  baseCorners = [[0.7, 1.2], [-2.2, 1.2], [0.7, -1.2], [-2.2, -1.2]];\n\n  zoom = 1;\n\n  centerOffsetX = 0;\n\n  centerOffsetY = 0;\n\n  drawScene = function(gl, program, vertexPositionBuffer) {\n    var aPlotPosition, aVertexPosition, corners, plotPositionBuffer;\n    aVertexPosition = gl.getAttribLocation(program, \"aVertexPosition\");\n    gl.enableVertexAttribArray(aVertexPosition);\n    aPlotPosition = gl.getAttribLocation(program, \"aPlotPosition\");\n    gl.enableVertexAttribArray(aPlotPosition);\n    gl.viewport(0, 0, gl.viewportWidth, gl.viewportHeight);\n    gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);\n    gl.bindBuffer(gl.ARRAY_BUFFER, vertexPositionBuffer);\n    gl.vertexAttribPointer(aVertexPosition, vertexPositionBuffer.itemSize, gl.FLOAT, false, 0, 0);\n    plotPositionBuffer = gl.createBuffer();\n    gl.bindBuffer(gl.ARRAY_BUFFER, plotPositionBuffer);\n    corners = baseCorners.map(function(_arg) {\n      var x, y;\n      x = _arg[0], y = _arg[1];\n      corners.push(x / zoom + centerOffsetX);\n      return corners.push(y / zoom + centerOffsetY);\n    });\n    gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(corners), gl.STATIC_DRAW);\n    gl.vertexAttribPointer(aPlotPosition, 2, gl.FLOAT, false, 0, 0);\n    gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4);\n    return gl.deleteBuffer(plotPositionBuffer);\n  };\n\n  webGLStart();\n\n}).call(this);\n",
      "type": "blob"
    },
    "shaders/fragment": {
      "path": "shaders/fragment",
      "content": "(function() {\n  module.exports = \"precision mediump float;\\nvarying vec2 vPosition;\\nvoid main(void) {\\n  float cx = vPosition.x;\\n  float cy = vPosition.y;\\n  \\n  float hue;\\n  float saturation;\\n  float value;\\n  float hueRound;\\n  int hueIndex;\\n  float f;\\n  float p;\\n  float q;\\n  float t;\\n  \\n  float x = 0.0;\\n  float y = 0.0;\\n  float tempX = 0.0;\\n  int i = 0;\\n  int runaway = 0;\\n  for (int i=0; i < 100; i++) {\\n    tempX = x * x - y * y + float(cx);\\n    y = 2.0 * x * y + float(cy);\\n    x = tempX;\\n    if (runaway == 0 && x * x + y * y > 100.0) {\\n      runaway = i;\\n    }\\n  }\\n  \\n  if (runaway != 0) {\\n    hue = float(runaway) / 200.0;\\n    saturation = 0.6;\\n    value = 1.0;\\n    \\n    hueRound = hue * 6.0;\\n    hueIndex = int(mod(float(int(hueRound)), 6.0));\\n    f = fract(hueRound);\\n    p = value * (1.0 - saturation);\\n    q = value * (1.0 - f * saturation);\\n    t = value * (1.0 - (1.0 - f) * saturation);\\n    \\n    if (hueIndex == 0)\\n      gl_FragColor = vec4(value, t, p, 1.0);\\n    else if (hueIndex == 1)\\n      gl_FragColor = vec4(q, value, p, 1.0);\\n    else if (hueIndex == 2)\\n      gl_FragColor = vec4(p, value, t, 1.0);\\n    else if (hueIndex == 3)\\n      gl_FragColor = vec4(p, q, value, 1.0);\\n    else if (hueIndex == 4)\\n      gl_FragColor = vec4(t, p, value, 1.0);\\n    else if (hueIndex == 5)\\n      gl_FragColor = vec4(value, p, q, 1.0);\\n      \\n  } else {\\n    gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);\\n  }\\n}\";\n\n}).call(this);\n",
      "type": "blob"
    },
    "shaders/vertex": {
      "path": "shaders/vertex",
      "content": "(function() {\n  module.exports = \"attribute vec2 aVertexPosition;\\nattribute vec2 aPlotPosition;\\n\\nvarying vec2 vPosition;\\n\\nvoid main(void) {\\n  gl_Position = vec4(aVertexPosition, 1.0, 1.0);\\n  vPosition = aPlotPosition;\\n}\";\n\n}).call(this);\n",
      "type": "blob"
    }
  },
  "progenitor": {
    "url": "https://danielx.net/editor/"
  },
  "entryPoint": "main",
  "repository": {
    "branch": "master",
    "default_branch": "master",
    "full_name": "STRd6/gpu-test",
    "homepage": null,
    "description": "Testing running code on the gpu",
    "html_url": "https://github.com/STRd6/gpu-test",
    "url": "https://api.github.com/repos/STRd6/gpu-test",
    "publishBranch": "gh-pages"
  },
  "dependencies": {}
});