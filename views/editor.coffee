Dithering = require "../dithering"
Imgur = require "../lib/imgr"

SearchResultsTemplate = require "../templates/search-results"

module.exports = (client) ->
  {system, UI, Observable, util:{FileIO}} = client
  {MenuBar, Modal, Progress, Util:{parseMenu}} = UI

  EditorTemplate = require "../templates/editor"

  PaletteView = require "./palette"
  paletteView = PaletteView(client)

  imgur = Imgur "bb9bdf4c3e7140e"

  filters = require("./filters")()

  sourceCanvas = document.createElement 'canvas'
  destinationCanvas = document.createElement 'canvas'

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

  showLoader = ->
    progressView = Progress
      message: "Loading..."

    Modal.show progressView.element,
      cancellable: false

  self = Object.assign FileIO(client),
    sourceCanvas: sourceCanvas
    destinationCanvas: destinationCanvas
    paletteElement: paletteView.element
    filtersElement: filters.element

    sourceImage: Observable null
    lastOpenURL: Observable ""
    lastSearchQuery: Observable "cat"
    openFromURL: (url) ->
      self.lastOpenURL url

      showLoader()

      fetch(url)
      .then (response) ->
        response.blob()
      .then self.loadFile
      .finally ->
        Modal.hide()

    promptOpenURL: ->
      Modal.prompt "URL", self.lastOpenURL()
      .then (url) ->
        if url
          self.openFromURL url

    searchImgur: ->
      Modal.prompt "Query", self.lastSearchQuery()
      .then (query) ->
        if query
          self.lastSearchQuery query

          showLoader()

          imgur.search(query)
          .then (results) ->
            Modal.hide()
            Modal.show SearchResultsTemplate results, ({cover, id}) ->
              self.openFromURL "https://i.imgur.com/#{cover or id}m.jpg"

    loadFile: (file) ->
      Image.fromBlob(file)
      .then self.sourceImage

  applyDream = (destinationCanvas) ->
    {width, height} = destinationCanvas
    context = destinationCanvas.getContext("2d")

    gradient = context.createLinearGradient(0, 0, 0, height)
    i = 0
    while i <= 6
      gradient.addColorStop(i/6, "hsl(#{i * 60}, 100%, 50%)")
      i += 1

    context.globalCompositeOperation = "screen"
    context.fillStyle = gradient
    context.fillRect(0, 0, width, height)

    context.fillStyle = "white"

    i = 0
    while i < width
      context.fillRect(i, 0, 1, height)
      i += 4

    i = 0
    while i < height
      context.fillRect(0, i, width, 1)
      i += 4

  Observable ->
    img = self.sourceImage()
    return unless img

    palette = paletteView.palette()
    colorStrings = paletteView.paletteStrings()
    filter = filters.filter()

    console.log filter

    {width, height} = img

    sourceCanvas.width = width
    sourceCanvas.height = height

    destinationCanvas.width = width
    destinationCanvas.height = height

    context = sourceCanvas.getContext('2d')
    context.filter = filter
    context.drawImage(img, 0, 0, width, height)

    data = context.getImageData(0, 0, width, height)
    applyFilter(data, palette, colorStrings, destinationCanvas)
    applyDream(destinationCanvas)

  menuBar = MenuBar
    items: parseMenu """
      [F]ile
        [O]pen
        Open [U]RL -> promptOpenURL
        [S]ave
        Save [A]s
        -
        [P]rint
        -
        E[x]it
      [E]dit
        [U]ndo
        Redo
        -
        Cu[t]
        [C]opy
        De[l]ete
        -
        Select [A]ll
        Time/[D]ate
      Search
        Imgr -> searchImgur
      [H]elp
        [A]bout Notepad
    """
    handlers: self

  self.menuBarElement = menuBar.element

  self.element = EditorTemplate self

  return self
