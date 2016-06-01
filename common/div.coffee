domready = require 'domready'

module.exports = (innerHTML) ->
    div = document.createElement 'div'
    div.style.position = 'absolute'
    div.style.left = '0'
    div.style.bottom = '0'
    div.style.backgroundColor = 'rgba(255, 255, 255, 0.85)'
    div.style.fontSize = '150%'
    div.style.color = 'red'
    div.innerHTML = innerHTML ? ''

    domready ->
        document.body.appendChild div

    div
