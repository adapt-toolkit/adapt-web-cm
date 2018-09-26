# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

getBase64 = (file, fun) ->
  reader = new FileReader()
  reader.readAsDataURL(file)
  reader.onload = ->
    fun reader.result
  return

setPreviewImageURL = (file) ->
  reader = new FileReader
  reader.onload = (e) ->
    $('#collectible_preview_img').attr 'src', e.target.result
    return
  reader.readAsDataURL file
  $('#collectible_collectible_file_name').val file.name
  return

setPreviewJsonText = (file) ->
  reader = new FileReader
  reader.onload = (e) ->
    $('#json_preview_area').html PR.prettyPrintOne(e.target.result, 'JSON')
    return
  reader.readAsText file
  $('#collectible_json_file_name').val file.name
  return

$(document).on 'change', '#collectible_collectible_file', ->
  $('#collectible_collectible_file_base64').val null
  if this.files and this.files[0]
    setPreviewImageURL this.files[0]
  return

$(document).on 'change', '#collectible_json_file', ->
  $('#collectible_json_file_base64').val null
  if this.files and this.files[0]
    setPreviewJsonText this.files[0]
  return

$(document).on 'dragenter', '#collectible_drop_area', (e) ->
    e.preventDefault(); e.stopPropagation(); $('#collectible_drop_area').addClass('dragging'); return
$(document).on 'dragover', '#collectible_drop_area', (e) ->
    e.preventDefault(); e.stopPropagation(); $('#collectible_drop_area').addClass('dragging'); return
$(document).on 'dragleave', '#collectible_drop_area', (e) ->
    e.preventDefault(); e.stopPropagation(); $('#collectible_drop_area').removeClass('dragging'); return
$(document).on 'drop', '#collectible_drop_area', (e) ->
    e.preventDefault(); e.stopPropagation()
    droppedFiles = e.originalEvent.dataTransfer.files
    if droppedFiles[0].type.startsWith('image/')
      getBase64 droppedFiles[0], (file_base64) ->
        setPreviewImageURL droppedFiles[0]
        $('#collectible_collectible_file_base64').val file_base64
        $('#collectible_collectible_file').val null
        return
    else
      alert('Unable to upload. File type must be image/*')
    $('#collectible_drop_area').removeClass('dragging')
    return

$(document).on 'dragenter', '#json_drop_area', (e) ->
    e.preventDefault(); e.stopPropagation(); $('#json_drop_area').addClass('dragging'); return
$(document).on 'dragover', '#json_drop_area', (e) ->
    e.preventDefault(); e.stopPropagation(); $('#json_drop_area').addClass('dragging'); return
$(document).on 'dragleave', '#json_drop_area', (e) ->
    e.preventDefault(); e.stopPropagation(); $('#json_drop_area').removeClass('dragging'); return
$(document).on 'drop', '#json_drop_area', (e) ->
    e.preventDefault(); e.stopPropagation()
    droppedFiles = e.originalEvent.dataTransfer.files
    if droppedFiles[0].type == 'application/json'
      getBase64 droppedFiles[0], (file_base64) ->
        setPreviewJsonText droppedFiles[0]
        $('#collectible_json_file_base64').val file_base64
        $('#collectible_json_file').val null
        return
    else
      alert('Unable to upload. File type must be application/json')
    $('#json_drop_area').removeClass('dragging')
    return
