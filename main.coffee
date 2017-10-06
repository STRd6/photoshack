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

  document.addEventListener "paste", (e) ->
    return if e.defaultPrevented

    {files, items, types} = e.clipboardData

    file = Array::reduce.call items, (file, item) ->
      file or (item.type.match(/^image\//) and item.getAsFile())
    , null

    if file
      editor.open(file)

  editor = Editor(system)

  document.body.appendChild editor.element

style = document.createElement "style"
style.innerHTML = require "./style"
document.head.appendChild style
