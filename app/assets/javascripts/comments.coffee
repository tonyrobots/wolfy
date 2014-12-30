window.client = new Faye.Client('/faye')
boop = new Audio("/sounds/boop.mp3")


client.addExtension {
  outgoing: (message, callback) ->
    message.ext = message.ext || {}
    message.ext.csrfToken = $('meta[name=csrf-token]').attr('content')
    callback(message)
}

#console.log(document.visibilityState);

jQuery ->
  $('#new_comment').submit ->
    $(this).find("input[type='submit']").val('Sending...').prop('disabled', true)

  try
    client.unsubscribe gon.channel
  catch
    console?.log "Can't unsubscribe from broadcast channel."
	 
  try
   client.unsubscribe gon.private_channel
  catch
   console?.log "Can't unsubscribe from private channel."
	 

  client.subscribe gon.channel, (payload) ->
    $('#comments').find('.media-list').prepend(payload.message) if payload.message
  	 location.reload true if payload.reload
    boop.play() if document.hidden
	 
  client.subscribe gon.private_channel, (payload) ->
    $('#comments').find('.media-list').prepend(payload.message) if payload.message
    location.reload true if payload.reload
    boop.play() if document.hidden
	 

		