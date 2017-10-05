require "./lib/extensions"

Drop = require "./lib/drop"
Editor = require "./views/editor"

SystemClient = require "sys"

SystemClient()
.then ({system, application}) ->
  {UI, Observable} = system
  {Modal} = UI

  Drop document, (e) ->
    return if e.defaultPrevented

    files = e.dataTransfer.files

    if files.length
      e.preventDefault()

      file = files[0]
      editor.open file

  editor = Editor()

  document.body.appendChild editor.element
