common = require '../common/common'
clear = require('gl-clear') { color: [0.1, 0.1, 0.1, 1.0] }
{ vec3, mat4 } = require 'gl-matrix'
keydown = require 'keydown'

vShaderSource = """
    attribute   vec4 a_Position;
    attribute   vec4 a_Color;
    uniform     mat4 u_ViewMatrix;
    uniform     mat4 u_ProjMatrix;
    varying     vec4 v_Color;
    void main() {
        gl_Position = u_ProjMatrix * u_ViewMatrix * a_Position;
        v_Color = a_Color;
    }
"""

fShaderSource = """
    precision   mediump float;
    varying     vec4    v_Color;
    void main() {
        gl_FragColor = v_Color;
    }
"""

vertexNum = 0

u_ViewMatrix = null

# Eye position
g_eyeX = 0.20
g_eyeY = 0.25
g_eyeZ = 0.25

keyUp = keydown(['<right>']).on 'pressed', ->
    g_eyeX += 0.01

keyDown = keydown(['<left>']).on 'pressed', ->
    g_eyeX -= 0.01

initMatrix = (gl) ->
    u_ViewMatrix = gl.getUniformLocation gl.program, 'u_ViewMatrix'
    u_ProjMatrix = gl.getUniformLocation gl.program, 'u_ProjMatrix'
    if !u_ProjMatrix or !u_ViewMatrix
        console.log 'Failed to get the storage locations of u_ProjMatrix or u_ViewMatrix'
        return

    # Create the matrix to specify the viewing volume and pass it to u_ProjMatrix
    projMatrix = mat4.create()
    # (out, left, right, bottom, top, near, far)
    mat4.ortho projMatrix, -1.0, 1.0, -1.0, 1.0, 0.0, 2.0

    # Set the view matrix
    gl.uniformMatrix4fv u_ProjMatrix, false, projMatrix

initVertexBuffers = (gl) ->
    verticesColors = new Float32Array [
        # Vertex coordinates and color(RGBA)
         0.0,  0.5,  -0.4,  0.4,  1.0,  0.4, # The back green one
        -0.5, -0.5,  -0.4,  0.4,  1.0,  0.4,
         0.5, -0.5,  -0.4,  1.0,  0.4,  0.4,

         0.5,  0.4,  -0.2,  1.0,  0.4,  0.4, # The middle yellow one
        -0.5,  0.4,  -0.2,  1.0,  1.0,  0.4,
         0.0, -0.6,  -0.2,  1.0,  1.0,  0.4,

         0.0,  0.5,   0.0,  0.4,  0.4,  1.0, # The front blue one
        -0.5, -0.5,   0.0,  0.4,  0.4,  1.0,
         0.5, -0.5,   0.0,  1.0,  0.4,  0.4,
    ]
    n = verticesColors.length / 6

    # Create a buffer object
    vertexColorbuffer = gl.createBuffer()
    if !vertexColorbuffer
        console.error 'Failed to create the buffer object'
        return -1

    # Bind the buffer object to target
    gl.bindBuffer gl.ARRAY_BUFFER, vertexColorbuffer
    # Write data into the buffer object
    gl.bufferData gl.ARRAY_BUFFER, verticesColors, gl.STATIC_DRAW

    FSIZE = verticesColors.BYTES_PER_ELEMENT

    a_Position = gl.getAttribLocation gl.program, 'a_Position'
    if a_Position < 0
        console.error 'Failed to get the storage location of a_Position'
        return -1

    gl.vertexAttribPointer a_Position, 3, gl.FLOAT, false, FSIZE * 6, 0
    gl.enableVertexAttribArray a_Position

    a_Color = gl.getAttribLocation gl.program, 'a_Color'
    if a_Color < 0
        console.log 'Failed to get the storage location of a_Color'
        return -1

    gl.vertexAttribPointer a_Color, 3, gl.FLOAT, false, FSIZE * 6, FSIZE * 3
    gl.enableVertexAttribArray a_Color

    # Unbind the buffer object
    gl.bindBuffer gl.ARRAY_BUFFER, null

    n

ready = (gl) ->
    canvasApp = @

    vertexNum = initVertexBuffers gl
    if vertexNum < 0
        console.error 'Failed to set the positions of the vertices'

    initMatrix gl

# called every frame
render = (gl, width, height, dt) ->
    viewMatrix = mat4.create()
    eye = vec3.fromValues g_eyeX, g_eyeY, g_eyeZ
    center = vec3.fromValues 0, 0, 0
    up = vec3.fromValues 0, 1, 0
    mat4.lookAt viewMatrix, eye, center, up

    gl.uniformMatrix4fv u_ViewMatrix, false, viewMatrix

    clear gl
    gl.drawArrays gl.TRIANGLES, 0, vertexNum

common ready, render, vShaderSource, fShaderSource