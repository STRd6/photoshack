module.exports = ({Observable}) ->
  ColorTemplate = require "../templates/color"
  PaletteTemplate = require "../templates/palette"
  
  paletteSource = Observable """
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
      self.source().split("\n").map (line) ->
        line.split(" ").map (value) ->
          parseInt value, 10

    paletteStrings: ->
      self.palette().map toRGB

    colorElements: ->
      self.paletteStrings().map (color) ->
        ColorTemplate
          color: color

  self.element = PaletteTemplate self

  return self
