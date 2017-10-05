module.exports = ->
  EditorTemplate = require "../templates/editor"

  sourceCanvas = document.createElement 'canvas'
  destinationCanvas = document.createElement 'canvas'

  editorElement = EditorTemplate
    sourceCanvas: sourceCanvas
    destinationCanvas: destinationCanvas

  element: editorElement
  open: (file) ->
    Image.fromBlob(file)
    .then (img) ->
      {width, height} = img

      sourceCanvas.width = width
      sourceCanvas.height = height

      context = sourceCanvas.getContext('2d')
      context.drawImage(img, 0, 0, width, height)
