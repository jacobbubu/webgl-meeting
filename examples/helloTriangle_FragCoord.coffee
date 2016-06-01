common = require '../common/common'
clear = require('gl-clear') { color: [0.1, 0.1, 0.1, 1.0] }

vShaderSource = """
    attribute   vec4 a_Position;
    void main() {
        gl_Position = a_Position;
    }
"""

fShaderSource = """
    precision mediump float;
    uniform float u_Width;
    uniform float u_Height;
    void main() {
        gl_FragColor = vec4(gl_FragCoord.x/u_Width, 0.0, gl_FragCoord.y/u_Height, 1.0);
    }
"""

u_Width = null
u_Height = null

vertexNum = 0

initVertexBuffers = (gl) ->
    vertices = new Float32Array [
        0.0,  0.5,
       -0.5, -0.5,
        0.5, -0.5,
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

    gl.vertexAttribPointer a_Position, 2, gl.FLOAT, false, 0, 0

    # Enable the generic vertex attribute array
    gl.enableVertexAttribArray a_Position

    # Unbind the buffer object
    gl.bindBuffer gl.ARRAY_BUFFER, null

    n

initUniform = (gl) ->
    u_Width = gl.getUniformLocation gl.program, 'u_Width'
    if !u_Width
        console.log 'Failed to get the storage location of u_Width'
        return

    u_Height = gl.getUniformLocation gl.program, 'u_Height'
    if !u_Height
        console.log('Failed to get the storage location of u_Height');
        return

ready = (gl) ->
    canvasApp = @

    vertexNum = initVertexBuffers gl
    if vertexNum < 0
        console.error 'Failed to set the positions of the vertices'

    initUniform gl

# called every frame
render = (gl, width, height, dt) ->
    clear gl
    #  Pass the width and hight of the <canvas>
    gl.uniform1f u_Width, width
    gl.uniform1f u_Height, height

    gl.drawArrays gl.TRIANGLES, 0, vertexNum

common ready, render, vShaderSource, fShaderSource