common = require '../common/common'
clear = require('gl-clear') { color: [0.1, 0.1, 0.1, 1.0] }
{ vec3, mat4 } = require 'gl-matrix'

vShaderSource = """
    attribute   vec4 a_Position;
    attribute   vec4 a_Color;
    uniform     mat4 u_MvpMatrix;
    varying     vec4 v_Color;
    void main() {
        gl_Position = u_MvpMatrix * a_Position;
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
u_MvpMatrix = null

modelMatrix1 = null
modelMatrix2 = null
viewMatrix = null
mvpMatrix1 = null
mvpMatrix2 = null

initMatrix = (gl) ->
    u_MvpMatrix = gl.getUniformLocation gl.program, 'u_MvpMatrix'
    if !u_MvpMatrix
        console.log 'Failed to get the storage locations of u_ViewMatrix and/or u_MvpMatrix'
        return

    viewMatrix = mat4.create()
    eye = vec3.fromValues 0, 0, 5
    center = vec3.fromValues 0, 0, -100
    up = vec3.fromValues 0, 1, 0
    # (out, eye, center, up)
    mat4.lookAt viewMatrix, eye, center, up

    modelMatrix1 = mat4.create()
    mat4.translate modelMatrix1, modelMatrix1, vec3.fromValues 0.75, 0, 0

    modelMatrix2 = mat4.create()
    mat4.translate modelMatrix2, modelMatrix2, vec3.fromValues -0.75, 0, 0


initVertexBuffers = (gl) ->
    verticesColors = new Float32Array [
        # Vertex coordinates and color
        0.0,  1.0,  -2.0,  1.0,  1.0,  0.4, # The middle yellow one
       -0.5, -1.0,  -2.0,  1.0,  1.0,  0.4,
        0.5, -1.0,  -2.0,  1.0,  0.4,  0.4,

        0.0,  1.0,   0.0,  0.4,  0.4,  1.0, # The front blue one
       -0.5, -1.0,   0.0,  0.4,  0.4,  1.0,
        0.5, -1.0,   0.0,  1.0,  0.4,  0.4,

        0.0,  1.0,  -4.0,  0.4,  1.0,  0.4, # The back green one
       -0.5, -1.0,  -4.0,  0.4,  1.0,  0.4,
        0.5, -1.0,  -4.0,  1.0,  0.4,  0.4,
    ]

    n = verticesColors.length / 6

    # Create a buffer object
    vertexColorBuffer = gl.createBuffer()
    if !vertexColorBuffer
        console.error 'Failed to create the buffer object'
        return -1

    # Bind the buffer object to target
    gl.bindBuffer gl.ARRAY_BUFFER, vertexColorBuffer
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

    n

ready = (gl) ->
    canvasApp = @

    # fix the order issue
    # gl.enable gl.DEPTH_TEST

    vertexNum = initVertexBuffers gl
    if vertexNum < 0
        console.error 'Failed to set the positions of the vertices'

    initMatrix gl

# called every frame
render = (gl, width, height, dt) ->
    clear gl

    gl.uniformMatrix4fv u_MvpMatrix, false, mvpMatrix1
    gl.drawArrays gl.TRIANGLES, 0, vertexNum

    gl.uniformMatrix4fv u_MvpMatrix, false, mvpMatrix2
    gl.drawArrays gl.TRIANGLES, 0, vertexNum

resize = (gl, width, height) ->
    projMatrix = mat4.create()
    # out, fovy, aspect, near, far
    mat4.perspective projMatrix, 30*Math.PI/180, width/height, 1, 100

    mvpMatrix1 = mat4.create()
    mat4.multiply mvpMatrix1, projMatrix, viewMatrix
    mat4.multiply mvpMatrix1, mvpMatrix1, modelMatrix1

    mvpMatrix2 = mat4.create()
    mat4.multiply mvpMatrix2, projMatrix, viewMatrix
    mat4.multiply mvpMatrix2, mvpMatrix2, modelMatrix2

common ready, render, vShaderSource, fShaderSource, resize