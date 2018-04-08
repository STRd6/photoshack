require "./lib/extensions"

Drop = require "./lib/drop"
Editor = require "./views/editor"

SystemClient = require "sys"
SystemClient.applyExtensions()
{system, application, postmaster, UI, Observable} = client = SystemClient()
{Modal} = UI

global.editor = editor = Editor(client)
document.body.appendChild editor.element

editor.openFromURL("https://picturepan2.github.io/instagram.css/assets/img/instagram.jpg")
# editor.openWebcam()

Drop document, (e) ->
  return if e.defaultPrevented

  files = e.dataTransfer.files

  if files.length
    e.preventDefault()

    file = files[0]
    editor.loadFile file

document.addEventListener "paste", (e) ->
  return if e.defaultPrevented

  {files, items, types} = e.clipboardData

  file = Array::reduce.call items, (file, item) ->
    file or (item.type.match(/^image\//) and item.getAsFile())
  , null

  if file
    editor.loadFile(file)

postmaster.delegate = editor

document.addEventListener "keydown", (e) ->
  {ctrlKey:ctrl, key} = e
  if ctrl
    switch key
      when "s"
        e.preventDefault()
        editor.save()
      when "o"
        e.preventDefault()
        editor.open()

system.ready()
.catch (e) ->
  ReaderInput = require "./templates/reader-input"

  # Override chooser to use local PC
  editor.open = ->
    Modal.show ReaderInput
      accept: "image/*"
      select: (file) ->
        Modal.hide()
        editor.loadFile file

  # Override save to present download
  editor.save = ->
    Modal.prompt "File name", "newfile.txt"
    .then (name) ->
      editor.saveData()
      .then (blob) ->
        url = window.URL.createObjectURL(blob)
        a = document.createElement("a")
        a.href = url
        a.download = name
        a.click()
        window.URL.revokeObjectURL(url)

  console.warn e

style = document.createElement "style"
style.innerHTML = require "./style"
document.head.appendChild style
