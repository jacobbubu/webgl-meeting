common = require '../common/common'
clear = require('gl-clear') { color: [0.1, 0.1, 0.1, 1.0] }

vShaderSource = """
    attribute vec4 a_Position;      // attribute variable
    void main() {
        gl_Position = a_Position;
        gl_PointSize = 10.0;
    }
"""

fShaderSource = """
    void main() {
        gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
    }
"""

# The array for the position of a mouse press
g_points = []

# attribute
a_Position = null

click = (ev) ->
    x = ev.clientX; # x coordinate of a mouse pointer
    y = ev.clientY; # y coordinate of a mouse pointer
    rect = ev.target.getBoundingClientRect()

    canvas = @canvas

    halfWidth = canvas.width / 2 / @_DPR
    halfHeight = canvas.height / 2 / @_DPR
    x = ( x - rect.left - halfWidth ) / halfWidth * 1
    y = ( halfHeight - y + rect.top ) / halfHeight * 1

    # Store the coordinates to g_points array
    g_points.push x
    g_points.push y

ready = (gl) ->
    canvasApp = @
    a_Position = gl.getAttribLocation gl.program, 'a_Position'
    if a_Position < 0
        console.error 'Failed to get the storage location of a_Position'
        return

    # Pass vertex position to attribute variable
    canvasApp.canvas.onmousedown = click.bind canvasApp

# called every frame
render = (gl, width, height, dt) ->
    clear gl
    for i in [0...g_points.length] by 2
        # Pass the position of a point to a_Position variable
        gl.vertexAttrib3f a_Position, g_points[i], g_points[i+1], 0.0

        # Draw a point
        gl.drawArrays gl.POINTS, 0, 1

common ready, render, vShaderSource, fShaderSource