$(document).ready(function() {
  // All non-GET requests will add the authenticity token
  // if not already present in the data packet
  $("body").bind("ajaxSend", function(elm, xhr, s) {
    if (s.type == "GET") return;
    if (s.data && s.data.match(new RegExp("\\b" + window._auth_token_name + "="))) return;
    if (s.data) {
      s.data = s.data + "&";
    } else {
      s.data = "";
      // if there was no data, jQuery didn't set the content-type
      xhr.setRequestHeader("Content-Type", s.contentType);
    }
    s.data = s.data + encodeURIComponent(window._auth_token_name)
		    + "=" + encodeURIComponent(window._auth_token);
  });
		    
  var post_methods = ['put', 'delete'];
  for (var index in post_methods) {
    (function (method) {

      $('a.'+method).live('click', function () {
	if (!this.title || confirm(this.title)) {
	  $.ajax({
	    clickedLink: this,
	    beforeSend: function (XMLHttpRequest) {
	      $(this.clickedLink).replaceWith('<img id="busy" src="/images/busy.gif" />');
	    },
	    error: function (XMLHttpRequest) {
	      $('#busy').replaceWith(this.clickedLink);
	    },
	    success: function (data, textStatus) {
	      for (var id in data) {
		$(id).replaceWith(data[id]);
	      }
	    },
	    type: 'POST',
	    url: this.href,
	    data: '_method='+method,
	    dataType: 'json'
	  });
	}
	return false;
      }).attr('rel', 'nofollow');
      
    })(post_methods[index]);
  }
});
		  
// All ajax requests will trigger the wants.js block
// of +respond_to do |wants|+ declarations
$.ajaxSetup({
  'beforeSend': function(xhr) {
    xhr.setRequestHeader("Accept", "text/javascript");
  }
});
