Dithering = require "../dithering"

module.exports = (system) ->
  EditorTemplate = require "../templates/editor"

  PaletteView = require "./palette"
  paletteView = PaletteView(system)

  sourceCanvas = document.createElement 'canvas'
  destinationCanvas = document.createElement 'canvas'

  editorElement = EditorTemplate
    sourceCanvas: sourceCanvas
    destinationCanvas: destinationCanvas
    paletteElement: paletteView.element

  dithering = Dithering()
  ditherStyle = "atkinson"

  distance3Squared = (a1, a2, a3, b1, b2, b3) ->
    x = a1 - b1
    y = a2 - b2
    z = a3 - b3

    x * x + y * y + z * z

  add3 = (a, b) ->
    a[0] += b[0]
    a[1] += b[1]
    a[2] += b[2]

    return a

  diffuseError = (errors, error, index, width) ->
    dithering[ditherStyle](errors, error, index, width)

  closestColor = ([r, g, b], palette, colorStrings) ->
    minDistance = Infinity
    index = null

    palette.forEach ([rp, gp, bp], i) ->
      distance = distance3Squared(r, g, b, rp, gp, bp)

      if distance < minDistance
        minDistance = distance
        index = i

    [rp, gp, bp] = palette[index]

    color: colorStrings[index]
    error: [rp - r, gp - g, bp - b]

  applyFilter = (imageData, palette, colorStrings, destinationCanvas) ->
    {width, height} = imageData
    context = destinationCanvas.getContext('2d')
    errors = new Int8Array(imageData.data.length)

    x = y = 0
    while y < height
      x = 0
      while x < width
        index = (x + y * width) * 4
        rgb = add3 imageData.data.slice(index, index + 3), errors.slice(index, index + 3)

        {color, error} = closestColor(rgb, palette, colorStrings)

        context.fillStyle = color
        context.fillRect(x, y, 1, 1)

        # Difuse error
        diffuseError(errors, error, index, width)

        x += 1
      y += 1

    return

  element: editorElement
  open: (file) ->
    palette = paletteView.palette()
    colorStrings = paletteView.paletteStrings()

    Image.fromBlob(file)
    .then (img) ->
      {width, height} = img

      sourceCanvas.width = width
      sourceCanvas.height = height

      destinationCanvas.width = width
      destinationCanvas.height = height

      context = sourceCanvas.getContext('2d')
      context.drawImage(img, 0, 0, width, height)

      data = context.getImageData(0, 0, width, height)
      applyFilter(data, palette, colorStrings, destinationCanvas)
