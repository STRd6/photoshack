Thumbnail = require "./thumbnail"

module.exports = (data, clickHandler) ->
  container = document.createElement "container"

  container.classList.add("search-results")

  data.forEach (datum) ->
    {cover, id} = datum
    thumb = cover or id

    img = Thumbnail
      src: "https://i.imgur.com/#{thumb}t.jpg"
      click: ->
        clickHandler(datum)

    container.appendChild(img)

  return container
