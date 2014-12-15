jQuery ->
	$(".edit-alias").click ->
	  $(".rest-in-place").trigger "click"
	  console.log "click!"
	  return
