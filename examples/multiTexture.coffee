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
    uniform sampler2D u_Sampler0;
    uniform sampler2D u_Sampler1;
    varying vec2 v_TexCoord;
    void main() {
        vec4 color0 = texture2D(u_Sampler0, v_TexCoord);
        vec4 color1 = texture2D(u_Sampler1, v_TexCoord);
        gl_FragColor = color0 * color1;
    }
"""

# attribute
a_Position = null
vertexNum = 0
u_Sampler0 = null
u_Sampler1 = null

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
    texture0 = gl.createTexture()
    texture1 = gl.createTexture()
    if !texture0 or !texture1
        console.log 'Failed to create the texture object'
        return false

    # Get the storage location of u_Sampler0 and u_Sampler1
    u_Sampler0 = gl.getUniformLocation gl.program, 'u_Sampler0'
    u_Sampler1 = gl.getUniformLocation gl.program, 'u_Sampler1'
    if !u_Sampler0 or !u_Sampler1
        console.log 'Failed to get the storage location of u_Sampler'
        return false

    image0 = new Image()  #Create the image object
    image1 = new Image()  #Create the image object
    if !image0 or !image1
        console.log 'Failed to create the image object'
        return false

    # Register the event handler to be called on loading an image
    image0.onload = -> loadTexture gl, vertexNum, texture0, u_Sampler0, image0, 0
    image1.onload = -> loadTexture gl, vertexNum, texture1, u_Sampler1, image1, 1
    # Tell the browser to load an image
    image0.src = 'examples/resources/sky.jpg'
    image1.src = 'examples/resources/circle.gif'

    true

loadTexture = (gl, vertexNum, texture, u_Sampler, image, texUnit) ->
    gl.pixelStorei gl.UNPACK_FLIP_Y_WEBGL, 1    # Flip the image's y axis
    if texUnit is 0
        # Enable texture unit0
        gl.activeTexture gl.TEXTURE0
    else
        gl.activeTexture gl.TEXTURE1
    #  Bind the texture object to the target
    gl.bindTexture gl.TEXTURE_2D, texture

    # Set the texture parameters
    gl.texParameteri gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR

    # Set the image to texture
    gl.texImage2D gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, image

    # Set the texture unit 0 to the sampler
    gl.uniform1i u_Sampler, texUnit

ready = (gl) ->
    canvasApp = @
    a_Position = gl.getAttribLocation gl.program, 'a_Position'
    if a_Position < 0
        console.error 'Failed to get the storage location of a_Position'
        return

    vertexNum = initVertexBuffers gl
    if vertexNum < 0
        console.error 'Failed to set the positions of the vertices'

    initTextures gl, vertexNum

# called every frame
render = (gl, width, height, dt) ->
    clear gl

    if u_Sampler0? and u_Sampler1?
        gl.drawArrays gl.TRIANGLE_STRIP, 0, vertexNum

common ready, render, vShaderSource, fShaderSource