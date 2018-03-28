module.exports = (clientId) ->
  search: (query) ->
    fetch("https://api.imgur.com/3/gallery/search?q=#{query}", {headers: {"Authorization": "Client-ID #{clientId}"}})
    .then (response) ->
      response.json()
    .then (json) ->
      json.data # wtf imgr :P
