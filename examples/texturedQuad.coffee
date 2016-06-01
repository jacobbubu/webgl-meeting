common = require '../common/common'
clear = require('gl-clear') { color: [0.1, 0.1, 0.1, 1.0] }

vShaderSource = """
    attribute   vec4 a_Position;
    attribute   vec2 a_TexCoord;
    varying     vec2 v_TexCoord;
    void main() {
        gl_Position = a_Position;
        v_TexCoord = a_TexCoord;
    }
"""

fShaderSource = """
    precision mediump float;
    uniform sampler2D u_Sampler;
    varying vec2 v_TexCoord;
    void main() {
        gl_FragColor = texture2D(u_Sampler, v_TexCoord);
    }
"""

vertexNum = 0
u_Sampler = null

initVertexBuffers = (gl) ->
    verticesTexCoords = new Float32Array [
        # Vertex coordinates, texture coordinate
        -0.5,  0.5,   0.0, 1.0,
        -0.5, -0.5,   0.0, 0.0,
         0.5,  0.5,   1.0, 1.0,
         0.5, -0.5,   1.0, 0.0,
    ]
    n = verticesTexCoords.length / 4 # The number of verticesTexCoords

    # Create a buffer object
    vertexBuffer = gl.createBuffer()
    if !vertexBuffer
        console.error 'Failed to create the buffer object'
        return -1

    # Bind the buffer object to target
    gl.bindBuffer gl.ARRAY_BUFFER, vertexBuffer
    gl.bufferData gl.ARRAY_BUFFER, verticesTexCoords, gl.STATIC_DRAW
    FSIZE = verticesTexCoords.BYTES_PER_ELEMENT

    a_Position = gl.getAttribLocation gl.program, 'a_Position'
    if a_Position < 0
        console.error 'Failed to get the storage location of a_Position'
        return -1

    gl.vertexAttribPointer a_Position, 2, gl.FLOAT, false, FSIZE * 4, 0
    gl.enableVertexAttribArray a_Position

    a_TexCoord = gl.getAttribLocation gl.program, 'a_TexCoord'
    if a_TexCoord < 0
        console.log 'Failed to get the storage location of a_TexCoord'
        return -1
    # Assign the buffer object to a_TexCoord variable
    gl.vertexAttribPointer a_TexCoord, 2, gl.FLOAT, false, FSIZE * 4, FSIZE * 2
    gl.enableVertexAttribArray a_TexCoord  # Enable the assignment of the buffer object

    n

initTextures = (gl, vertexNum) ->
    image = new Image()  #Create the image object
    if !image
        console.log 'Failed to create the image object'
        return false

    # Register the event handler to be called on loading an image
    image.onload = -> loadTexture gl, vertexNum, image
    # Tell the browser to load an image
    image.src = 'examples/resources/sky.jpg'

    true

loadTexture = (gl, vertexNum, image) ->
    texture = gl.createTexture()   #Create a texture object
    if !texture
        console.log 'Failed to create the texture object'
        return

    gl.pixelStorei gl.UNPACK_FLIP_Y_WEBGL, 1    # Flip the image's y axis
    # Enable texture unit0
    gl.activeTexture gl.TEXTURE0
    #  Bind the texture object to the target
    gl.bindTexture gl.TEXTURE_2D, texture

    # Set the texture parameters
    gl.texParameteri gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR
    # Set the texture image
    gl.texImage2D gl.TEXTURE_2D, 0, gl.RGB, gl.RGB, gl.UNSIGNED_BYTE, image

    # Get the storage location of u_Sampler
    u_Sampler = gl.getUniformLocation gl.program, 'u_Sampler'
    if !u_Sampler
        console.log 'Failed to get the storage location of u_Sampler'
        return

    # Set the texture unit 0 to the sampler
    gl.uniform1i u_Sampler, 0

ready = (gl) ->
    canvasApp = @

    vertexNum = initVertexBuffers gl
    if vertexNum < 0
        console.error 'Failed to set the positions of the vertices'

    initTextures gl, vertexNum

# called every frame
render = (gl, width, height, dt) ->
    clear gl

    if u_Sampler?
        gl.drawArrays gl.TRIANGLE_STRIP, 0, vertexNum

common ready, render, vShaderSource, fShaderSource