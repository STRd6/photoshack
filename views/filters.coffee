Template = require "../templates/filters"

{Observable} = require "sys"

module.exports = ->
  self =
    blur: Observable 0
    brightness: Observable 1
    contrast: Observable 1
    grayscale: Observable 0
    hue: Observable 0
    invert: Observable 0
    saturation: Observable 1
    sepia: Observable 0

    filter: ->
      """
        blur(#{self.blur()}px)
        brightness(#{self.brightness()})
        contrast(#{self.contrast()})
        grayscale(#{self.grayscale()})
        invert(#{self.invert()})
        hue-rotate(#{self.hue()}deg)
        saturate(#{self.saturation()})
        sepia(#{self.sepia()})
      """

  self.element = Template self

  return self
