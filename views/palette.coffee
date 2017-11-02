###
Shuffles array in place.
@param {Array} a items An array containing the items.
###
shuffle = (a) ->
  i = a.length - 1

  while i > 0
    j = Math.floor(Math.random() * (i + 1))
    x = a[i]
    a[i] = a[j]
    a[j] = x
    i--

  return a

module.exports = ({Observable}) ->
  ColorTemplate = require "../templates/color"
  PaletteTemplate = require "../templates/palette"

  originalSource = """
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

  sourceToColors = (source) ->
    source.split("\n").map (line) ->
      line.split(" ").map (value) ->
        parseInt value, 10

  paletteSource = Observable originalSource

  editSource = Observable paletteSource()

  toRGB = ([r, g, b]) ->
    "rgb(#{r},#{g},#{b})"

  self =
    element: null
    source: paletteSource
    editSource: editSource

    apply: ->
      self.source self.editSource()

      self.element.classList.remove "edit"

    edit: ->
      self.element.classList.toggle "edit"

    palette: ->
      sourceToColors self.source()

    paletteStrings: ->
      self.palette().map toRGB

    random4: ->
      self.source(
        shuffle(sourceToColors(originalSource))
        .slice(0, 4)
        .map (color) ->
          color.join(" ")
        .join("\n")
      )

    colorElements: ->
      self.paletteStrings().map (color) ->
        ColorTemplate
          color: color

  self.element = PaletteTemplate self

  return self
