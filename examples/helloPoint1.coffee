common = require '../common/common'
clear = require('gl-clear') { color: [0.1, 0.1, 0.1, 1.0] }

vShaderSource = """
    void main() {
        gl_Position = vec4(0.0, 0.0, 0.0, 1.0);
        gl_PointSize = 10.0;
    }
"""

fShaderSource = """
    void main() {
        gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
    }
"""

# called every frame
render = (gl, width, height, dt) ->
    clear gl

    # Draw a point
    gl.drawArrays gl.POINTS, 0, 1

common null, render, vShaderSource, fShaderSource