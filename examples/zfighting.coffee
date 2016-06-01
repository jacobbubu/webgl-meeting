common = require '../common/common'
clear = require('gl-clear') { color: [0.1, 0.1, 0.1, 1.0] }
{ vec3, mat4 } = require 'gl-matrix'

vShaderSource = """
    attribute   vec4 a_Position;
    attribute   vec4 a_Color;
    uniform     mat4 u_ViewProjMatrix;
    varying     vec4 v_Color;
    void main() {
        gl_Position = u_ViewProjMatrix * a_Position;
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
u_ViewProjMatrix = null

viewMatrix = null

initMatrix = (gl) ->
    u_ViewProjMatrix = gl.getUniformLocation gl.program, 'u_ViewProjMatrix'
    if !u_ViewProjMatrix
        console.log 'Failed to get the storage locations of u_ViewProjMatrix'
        return

    viewMatrix = mat4.create()
    eye = vec3.fromValues 3.06, 2.5, 10.0
    center = vec3.fromValues 0, 0, -2
    up = vec3.fromValues 0, 1, 0
    # (out, eye, center, up)
    mat4.lookAt viewMatrix, eye, center, up

initVertexBuffers = (gl) ->
    verticesColors = new Float32Array [
        # Vertex coordinates and color
        0.0,  2.5,  -5.0,  0.4,  1.0,  0.4, # The green triangle
       -2.5, -2.5,  -5.0,  0.4,  1.0,  0.4,
        2.5, -2.5,  -5.0,  1.0,  0.4,  0.4,

        0.0,  3.0,  -5.0,  1.0,  0.4,  0.4, # The yellow triagle
       -3.0, -3.0,  -5.0,  1.0,  1.0,  0.4,
        3.0, -3.0,  -5.0,  1.0,  1.0,  0.4,
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
    vertexNum = initVertexBuffers gl
    if vertexNum < 0
        console.error 'Failed to set the positions of the vertices'

    initMatrix gl

    # Enable the polygon offset function
    gl.enable gl.POLYGON_OFFSET_FILL

# called every frame
render = (gl, width, height, dt) ->
    clear gl

    gl.drawArrays gl.TRIANGLES, 0, vertexNum/2  # Draw green triangle
    gl.drawArrays gl.TRIANGLES, vertexNum/2, vertexNum/2 # Draw yellow triangle
    # gl.polygonOffset 1.0, 1.0 # Set the polygon offset


resize = (gl, width, height) ->
    projMatrix = mat4.create()
    # out, fovy, aspect, near, far
    mat4.perspective projMatrix, 30*Math.PI/180, width/height, 1, 100

    mat4.multiply projMatrix, projMatrix, viewMatrix

    gl.uniformMatrix4fv u_ViewProjMatrix, false, projMatrix

common ready, render, vShaderSource, fShaderSource, resize