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
	    success: function (data, textStatus) { replace_elements(data); },
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
		    
  $('form.new-form #picture').change(function () {
    if (this.value != '') {
      $('form.new-form').attr('action', '/pictures/create').attr('target', 'upload_frame').submit();
    }
  });
  $('form.edit-article #picture').change(function () {
    if (this.value != '') {
      var article_id = $('form.edit-article input#article_id').val();
      $('form.edit-article').attr('action', '/pictures/connect/'+article_id).attr('target', 'upload_frame').submit();
    }
  });
  
  $('form.forsale-article input.button').click(function () {
    $('form.forsale-article').attr('action', '/articles').attr('target', null).submit();
    return false;
  });
  $('form.edit-article input.button').click(function () {
    var article_id = $('form.edit-article input#article_id').val();
    $('form.edit-article').attr('action', '/articles/'+article_id).attr('target', null).submit();
    return false;
  });
  $('form.task-article input.button').click(function () {
    var task_id = $('form.task-article input#task_id').val();
    $('form.task-article').attr('action', '/tasks/'+task_id+'/articles').attr('target', null).submit();
    return false;
  });
  
  $('#main form div input.radio').click(function () {
    var radio_val = $(this).val();
    if (radio_val == 'category') {
      $('#main form #tasks').hide();
      $('#main form #categories').show();
      $('#main form #price-div').show();
      $('#main form #tags-div').show();
    } else if (radio_val == 'task') {
      $('#main form #price-div').hide();
      $('#main form #tags-div').hide();
      $('#main form #categories').hide();
      $('#main form #tasks').show();
    }
  });

});

function replace_elements(elems) {
  for (var id in elems) {
    $(id).replaceWith(elems[id]);
  }
}

// All ajax requests will trigger the wants.js block
// of +respond_to do |wants|+ declarations
$.ajaxSetup({
  'beforeSend': function(xhr) {
    xhr.setRequestHeader("Accept", "text/javascript");
  }
});
