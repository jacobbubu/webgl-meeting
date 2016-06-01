common = require '../common/common'
clear = require('gl-clear') { color: [0.1, 0.1, 0.1, 1.0] }

vShaderSource = """
    attribute vec4 a_Position;
    uniform vec4 u_Translation;
    void main() {
        gl_Position = a_Position + u_Translation;
    }
"""

fShaderSource = """
    void main() {
        gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
    }
"""

vertexNum = 0

# The translation distance for x, y, and z direction
[Tx, Ty, Tz] = [0.5, 0.5, 0.0]

initVertexBuffers = (gl) ->
    vertices = new Float32Array [
         0,     0.5
      -0.5,    -0.5
       0.5,    -0.5
    ]
    n = vertices.length / 2 # The number of vertices

    # Create a buffer object
    vertexBuffer = gl.createBuffer()
    if !vertexBuffer
        console.error 'Failed to create the buffer object'
        return -1

    # Bind the buffer object to target
    gl.bindBuffer gl.ARRAY_BUFFER, vertexBuffer
    # Write data into the buffer object
    gl.bufferData gl.ARRAY_BUFFER, vertices, gl.STATIC_DRAW

    a_Position = gl.getAttribLocation gl.program, 'a_Position'
    if a_Position < 0
        console.error 'Failed to get the storage location of a_Position'
        return -1

    # Assign the buffer object to a_Position variable
    gl.vertexAttribPointer a_Position, 2, gl.FLOAT, false, 0, 0

    # Enable the assignment to a_Position variable
    gl.enableVertexAttribArray a_Position

    n

initUniform = (gl) ->
    # Pass the translation distance to the vertex shader
    u_Translation = gl.getUniformLocation gl.program, 'u_Translation'
    if !u_Translation
        console.log 'Failed to get the storage location of u_Translation'
        return
    gl.uniform4f u_Translation, Tx, Ty, Tz, 0.0

ready = (gl) ->
    canvasApp = @

    vertexNum = initVertexBuffers gl
    if vertexNum < 0
        console.error 'Failed to set the positions of the vertices'

    initUniform gl

# called every frame
render = (gl, width, height, dt) ->
    clear gl
    gl.drawArrays gl.TRIANGLES, 0, vertexNum

common ready, render, vShaderSource, fShaderSource