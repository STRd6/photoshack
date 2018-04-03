{Observable} = require "sys"

filterData = require "../data/filters"

NullFilter = {}

module.exports = ->
  
  selectElement = document.createElement "select"
  keys = Object.keys(filterData)

  keys.forEach (key) ->
    option = document.createElement "option"
    option.value = key
    option.textContent = key
    selectElement.appendChild option

  selectedOption = Observable keys[0]

  selectElement.oninput = ->
    selectedOption selectElement.value
  
  selectedFilter = ->
    filterData[selectedOption()] or NullFilter

  element: selectElement

  filterCSS: ->
    filter: selectedFilter().filter
  
  backgroundCSS: ->
    filter = selectedFilter()

    background: filter.background
    "mix-blend-mode": filter["mix-blend-mode"]
