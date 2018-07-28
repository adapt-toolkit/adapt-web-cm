# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

setPreviewImageURL = (input) ->
  if input.files and input.files[0]
    reader = new FileReader

    reader.onload = (e) ->
      $('#collectible_preview_img').attr 'src', e.target.result
      return

    reader.readAsDataURL input.files[0]
  return

setPreviewJsonText = (input) ->
  if input.files and input.files[0]
    reader = new FileReader

    reader.onload = (e) ->
      $('#json_preview_area').html PR.prettyPrintOne(e.target.result, 'JSON')
      return

    reader.readAsText input.files[0]
  return

$(document).on 'change', '#collectible_collectible_file', ->
  setPreviewImageURL this
  return

$(document).on 'change', '#collectible_json_file', ->
  setPreviewJsonText this
  return
