common = require '../common/common'
clear = require('gl-clear') { color: [0.1, 0.1, 0.1, 1.0] }
{ vec3, mat4 } = require 'gl-matrix'
keydown = require 'keydown'
info = require('../common/div')()

vShaderSource = """
    attribute   vec4 a_Position;
    attribute   vec4 a_Color;
    uniform     mat4 u_ProjMatrix;
    varying     vec4 v_Color;
    void main() {
        gl_Position = u_ProjMatrix * a_Position;
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
u_ProjMatrix = null

# Eye position
g_near = 0.0
g_far = 0.5

keyUp = keydown(['<right>']).on 'pressed', ->
    g_near += 0.01
    showNearFar()

keyDown = keydown(['<left>']).on 'pressed', ->
    g_near -= 0.01
    showNearFar()

keyUp = keydown(['<up>']).on 'pressed', ->
    g_far += 0.01
    showNearFar()

keyDown = keydown(['<down>']).on 'pressed', ->
    g_far -= 0.01
    showNearFar()

showNearFar = ->
    info.innerHTML = 'near: ' + Math.round(g_near * 100)/100 + ', far: ' + Math.round(g_far*100)/100

initMatrix = (gl) ->
    u_ProjMatrix = gl.getUniformLocation gl.program, 'u_ProjMatrix'
    if !u_ProjMatrix
        console.log 'Failed to get the storage locations of u_ProjMatrix'
        return

initVertexBuffers = (gl) ->
    verticesColors = new Float32Array [
        # Vertex coordinates and color(RGBA)
         0.0,  0.6,  -0.4,  0.4,  1.0,  0.4, # The back green one
        -0.5, -0.4,  -0.4,  0.4,  1.0,  0.4,
         0.5, -0.4,  -0.4,  1.0,  0.4,  0.4,

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
    showNearFar()

# called every frame
render = (gl, width, height, dt) ->

    # Create the matrix to specify the viewing volume and pass it to u_ProjMatrix
    projMatrix = mat4.create()
    mat4.ortho projMatrix, -1.0, 1.0, -1.0, 1.0, g_near, g_far

    gl.uniformMatrix4fv u_ProjMatrix, false, projMatrix

    clear gl
    gl.drawArrays gl.TRIANGLES, 0, vertexNum

common ready, render, vShaderSource, fShaderSource