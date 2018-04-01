FiltersTemplate = require "../templates/filters"
FilterSectionTemplate = require "../templates/filter-section"

{Observable} = require "sys"

module.exports = ->
  filterParams =
    blur:
      min: 0
      max: 10
      step: 0.1
      initial: 0
    brightness:
      min: 0
      max: 10
      step: 0.01
      initial: 1
    contrast:
      min: 0
      max: 10
      step: 0.01
      initial: 1
    grayscale:
      min: 0
      max: 1
      step: 0.01
      initial: 0
    hue:
      min: 0
      max: 360
      step: 1
      initial: 0
    invert:
      min: 0
      max: 1
      step: 0.01
      initial: 0
    saturation:
      min: 0
      max: 10
      step: 0.01
      initial: 1
    sepia:
      min: 0
      max: 1
      step: 0.01
      initial: 0

  filterNames = Object.keys(filterParams)

  self =
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
    toJSON: ->
      Object.keys(filterParams).reduce (data, key) ->
        data[key] = self[key]()

        return data
      , {}
    persist: ->
      console.log self.toJSON()

    filterElements: ->
      filterNames.map (name) ->
        params = filterParams[name]
        console.log name, params

        FilterSectionTemplate params

  filterNames.forEach (name) ->
    {initial} = param = filterParams[name]

    param.name = name
    self[name] = param.value = Observable initial

  self.element = FiltersTemplate self

  return self
