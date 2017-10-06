module.exports = ->
  EditorTemplate = require "../templates/editor"
  PaletteTemplate = require "../templates/palette"

  sourceCanvas = document.createElement 'canvas'
  destinationCanvas = document.createElement 'canvas'
  debugCanvas = document.createElement 'canvas'

  paletteSource = """
    20 12 28
    68 36 52
    48 52 109
    78 74 78
    133 76 48
    52 101 36
    208 70 72
    117 113 97
    89 125 206
    210 125 44
    133 149 161
    109 170 44
    210 170 153
    109 194 202
    218 212 94
    222 238 214
  """

  editorElement = EditorTemplate
    sourceCanvas: sourceCanvas
    destinationCanvas: destinationCanvas
    debugCanvas: debugCanvas
    paletteElement: PaletteTemplate
      source: paletteSource

  palette = paletteSource.split("\n").map (line) ->
    line.split(" ").map (value) ->
      parseInt value, 10

  toRGB = ([r, g, b]) ->
    "rgb(#{r},#{g},#{b})"

  colorStrings = palette.map toRGB

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

  atkinson = (errors, error, index, width) ->
    r = error[0] >> 3
    g = error[1] >> 3
    b = error[2] >> 3

    [1, 2, width - 1, width, width + 1, 2 * width].forEach (n) ->
      i = (index + n) * 4
      errors[i] += r
      errors[i + 1] += g
      errors[i + 2] += b

    return

  floydSteinbergKernel = [7, 3, 5, 1].map (n) -> n / 16

  floydSteinberg = (errors, error, index, width) ->
    [r, g, b] = error

    k = floydSteinbergKernel

    [1, width - 1, width, width + 1].forEach (n, z) ->
      i = (index + n) * 4

      c = k[z]

      errors[i] += r * c
      errors[i + 1] += g * c
      errors[i + 2] += b * c

  diffuseError = (errors, error, index, width) ->
    atkinson(errors, error, index, width)
    #floydSteinberg(errors, error, index, width)

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

    console.log errors
    
    debugCanvas.width = width
    debugCanvas.height = height
    debugger
    errorData = new Uint8ClampedArray(errors)
    i = 3
    while i < errorData.length
      errorData[i] = 255 # Set full alpha
      i += 4
    debugCanvas.getContext('2d').putImageData(new ImageData(errorData, width, height), 0, 0)

    return

  element: editorElement
  open: (file) ->
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
