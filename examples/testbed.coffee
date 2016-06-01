common = require '../common/common'

# called every frame
render = (gl, width, height, dt) ->
    gl.clearColor 0.5, 0.0, 0.0, 1.0
    gl.clear gl.COLOR_BUFFER_BIT

common null, render