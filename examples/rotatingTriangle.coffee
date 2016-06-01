common = require '../common/common'
clear = require('gl-clear') { color: [0.1, 0.1, 0.1, 1.0] }
{ quat, vec3, mat4 } = require 'gl-matrix'
keydown = require 'keydown'

vShaderSource = """
    attribute vec4 a_Position;
    uniform mat4 u_modelMatrix;
    void main() {
        gl_Position = u_modelMatrix * a_Position;
    }
"""

fShaderSource = """
    void main() {
        gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
    }
"""

vertexNum = 0
# Rotation angle (degrees/ms)
ANGLE_STEP = 45.0 / 1e3
currentAngle = 0.0

keyUp = keydown(['<up>']).on 'pressed', ->
    ANGLE_STEP += 10 / 1e3

keyDown = keydown(['<down>']).on 'pressed', ->
    ANGLE_STEP -= 10 / 1e3

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

ready = (gl) ->
    canvasApp = @

    vertexNum = initVertexBuffers gl
    if vertexNum < 0
        console.error 'Failed to set the positions of the vertices'

# called every frame
render = (gl, width, height, dt) ->
    currentAngle += ANGLE_STEP * dt
    radian = Math.PI * currentAngle / 180.0

    modelMatrix = mat4.create()
    mat4.rotateZ modelMatrix, modelMatrix, radian
    # mat4.translate modelMatrix, modelMatrix, vec3.fromValues 0.35, 0, 0

    # Pass the rotation matrix to the vertex shader
    u_modelMatrix = gl.getUniformLocation gl.program, 'u_modelMatrix'
    if !u_modelMatrix
        console.log 'Failed to get the storage location of u_modelMatrix'
        return

    gl.uniformMatrix4fv u_modelMatrix, false, modelMatrix

    clear gl
    gl.drawArrays gl.TRIANGLES, 0, vertexNum

common ready, render, vShaderSource, fShaderSource