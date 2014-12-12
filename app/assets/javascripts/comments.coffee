window.client = new Faye.Client('/faye')
 
client.addExtension {
  outgoing: (message, callback) ->
    message.ext = message.ext || {}
    message.ext.csrfToken = $('meta[name=csrf-token]').attr('content')
    callback(message)
}

jQuery ->
  $('#new_comment').submit ->
    $(this).find("input[type='submit']").val('Sending...').prop('disabled', true)

  try
    client.unsubscribe gon.channel
  catch
    console?.log "Can't unsubscribe."

  client.subscribe gon.channel, (payload) ->
    $('#comments').find('.media-list').prepend(payload.message) if payload.message