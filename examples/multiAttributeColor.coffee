common = require '../common/common'
clear = require('gl-clear') { color: [0.1, 0.1, 0.1, 1.0] }

vShaderSource = """
    attribute vec4 a_Position;
    attribute vec4 a_Color;
    varying vec4 v_Color;
    void main() {
        gl_Position = a_Position;
        gl_PointSize = 10.0;
        v_Color = a_Color;
    }
"""

fShaderSource = """
    precision mediump float;
    varying vec4 v_Color;
    void main() {
        gl_FragColor = v_Color;
    }
"""

# attribute
a_Position = null
vertexNum = 0

initVertexBuffers = (gl) ->
    verticesColors = new Float32Array [
        # Vertex coordinates and color
         0.0,  0.5,  1.0,  0.0,  0.0,
        -0.5, -0.5,  0.0,  1.0,  0.0,
         0.5, -0.5,  0.0,  0.0,  1.0,
    ]
    n = verticesColors.length / 5 # The number of vertices

    # Create a buffer object
    vertexSizeBuffer = gl.createBuffer()
    if !vertexSizeBuffer
        console.error 'Failed to create the buffer object'
        return -1

    # Write vertex coordinates to the buffer object and enable it
    gl.bindBuffer gl.ARRAY_BUFFER, vertexSizeBuffer
    gl.bufferData gl.ARRAY_BUFFER, verticesColors, gl.STATIC_DRAW

    FSIZE = verticesColors.BYTES_PER_ELEMENT

    a_Position = gl.getAttribLocation gl.program, 'a_Position'
    if a_Position < 0
        console.error 'Failed to get the storage location of a_Position'
        return -1
    gl.vertexAttribPointer a_Position, 2, gl.FLOAT, false, FSIZE * 5, 0
    gl.enableVertexAttribArray a_Position

    a_Color = gl.getAttribLocation gl.program, 'a_Color'
    if a_Color < 0
        console.log 'Failed to get the storage location of a_Color'
        return -1
    gl.vertexAttribPointer a_Color, 3, gl.FLOAT, false, FSIZE * 5, FSIZE * 2
    gl.enableVertexAttribArray a_Color

    # Unbind the buffer object
    gl.bindBuffer gl.ARRAY_BUFFER, null

    n

ready = (gl) ->
    a_Position = gl.getAttribLocation gl.program, 'a_Position'
    if a_Position < 0
        console.error 'Failed to get the storage location of a_Position'
        return

    # Pass vertex position to attribute variable
    gl.vertexAttrib3f a_Position, 0.0, 0.0, 0.0

    vertexNum = initVertexBuffers gl
    if vertexNum < 0
        console.error 'Failed to set the positions of the vertices'

# called every frame
render = (gl, width, height, dt) ->
    clear gl

    # Draw a point
    gl.drawArrays gl.POINTS, 0, vertexNum

common ready, render, vShaderSource, fShaderSource