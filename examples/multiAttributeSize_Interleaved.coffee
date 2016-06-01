common = require '../common/common'
clear = require('gl-clear') { color: [0.1, 0.1, 0.1, 1.0] }

vShaderSource = """
    attribute vec4 a_Position;
    attribute float a_PointSize;
    void main() {
        gl_Position = a_Position;
        gl_PointSize = a_PointSize;
    }
"""

fShaderSource = """
    void main() {
        gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
    }
"""

# attribute
a_Position = null
vertexNum = 0

initVertexBuffers = (gl) ->
    verticesSizes = new Float32Array [
        0.0,   0.5, 10.0
        -0.5, -0.5, 20.0
        0.5,  -0.5, 30.0
    ]
    n = verticesSizes.length / 3 # The number of vertices

    # Create a buffer object
    vertexSizeBuffer = gl.createBuffer()
    if !vertexSizeBuffer
        console.error 'Failed to create the buffer object'
        return -1

    # Write vertex coordinates to the buffer object and enable it
    gl.bindBuffer gl.ARRAY_BUFFER, vertexSizeBuffer
    gl.bufferData gl.ARRAY_BUFFER, verticesSizes, gl.STATIC_DRAW

    FSIZE = verticesSizes.BYTES_PER_ELEMENT

    a_Position = gl.getAttribLocation gl.program, 'a_Position'
    if a_Position < 0
        console.error 'Failed to get the storage location of a_Position'
        return -1
    gl.vertexAttribPointer a_Position, 2, gl.FLOAT, false, FSIZE * 3, 0
    gl.enableVertexAttribArray a_Position

    a_PointSize = gl.getAttribLocation gl.program, 'a_PointSize'
    if a_PointSize < 0
        console.log 'Failed to get the storage location of a_PointSize'
        return -1
    gl.vertexAttribPointer a_PointSize, 1, gl.FLOAT, false, FSIZE * 3, FSIZE * 2
    gl.enableVertexAttribArray a_PointSize

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