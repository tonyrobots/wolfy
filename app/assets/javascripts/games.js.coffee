jQuery ->
	$(".edit-alias").click ->
	  $(".rest-in-place.alias").trigger "click"
	  return
	  
	$(".pm-button").click ->
		#$("#comment_body").val $(this).attr("data")
		$(".pm-target").html "Private to #{$(this).attr("data")}"