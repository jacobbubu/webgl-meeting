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

ready = (gl) ->
    a_Position = gl.getAttribLocation gl.program, 'a_Position'
    if a_Position < 0
        console.error 'Failed to get the storage location of a_Position'
        return

    # Pass vertex position to attribute variable
    gl.vertexAttrib3f a_Position, 0.0, 0.5, 0.0

# called every frame
render = (gl, width, height, dt) ->
    clear gl

    # Draw a point
    gl.drawArrays gl.POINTS, 0, 1

common ready, render, vShaderSource, fShaderSource