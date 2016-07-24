styleNode = document.createElement("style")
styleNode.innerHTML = require "./style"

document.head.appendChild(styleNode)

{width, height} = require "./pixie"

canvas = document.createElement("canvas")
canvas.width = width
canvas.height = height
document.body.appendChild canvas

global.canvas = canvas
