Imgur = require "../lib/imgr"

InstagramFilters = require "./instagram-filters"

SearchResultsTemplate = require "../templates/search-results"

module.exports = (client) ->
  {system, UI, Observable, util:{FileIO}} = client
  {MenuBar, Modal, Progress, Util:{parseMenu}} = UI

  EditorTemplate = require "../templates/editor"
  FilterViewElementTemplate = require "../templates/filter-view"

  imgur = Imgur "bb9bdf4c3e7140e"

  showLoader = ->
    progressView = Progress
      message: "Loading..."

    Modal.show progressView.element,
      cancellable: false

  filterSelect = InstagramFilters()

  self = Object.assign FileIO(client),
    backgroundStyle: ->
      filterSelect.backgroundCSS()

    filterStyle: ->
      filterSelect.filterCSS()

    filterViewElement: null
    filterSelectElement: filterSelect.element

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
      Search
        Imgr -> searchImgur
      [H]elp
        [A]bout Photoshack
    """
    handlers: self

  document.body.appendChild menuBar.element

  self.filterViewElement = FilterViewElementTemplate self

  self.element = EditorTemplate self

  return self
