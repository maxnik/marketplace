jQuery.fn.center = function() {
  var w = $(window);
  this.css("position","absolute");
  this.css("top",(w.height()-this.height())/2+w.scrollTop() + "px");
  this.css("left",(w.width()-this.width())/2+w.scrollLeft() + "px");
  return this;
};

$(document).ready(function () {

  $("a.proposition").click(function () {

    var $dialog = $("#proposition-dialog");
    $dialog.center();
    $("span", $dialog).text('"' + this.title + '"');
    $("input#proposition_task_id", $dialog).attr('value', this.name);
    $("input#propose", $dialog).attr('disabled', true);
    $dialog.show();
    $("textarea", $dialog).val('').focus();
    return false;
  });
		    
  $("#proposition-dialog a").click(function () {
    $("#proposition-dialog").hide();
    return false;
  });
  
  $("#proposition-dialog textarea").bind('keyup keydown', function () {
    var disabled = true;
    if (this.value != "") {
      disabled = false;
    } 
    $("#proposition-dialog input#propose").attr('disabled', disabled);
  });
		    
  $("input#propose").click(function () {
    if ($("#proposition-dialog textarea").val() != "") {
      var $form = $("#proposition-dialog form");
	$.ajax({
 	  beforeSend: function (XMLHttpRequest) {
 	    $('#status_task_'+$('input[name=proposition[task_id]]', $form).val())
	      .after('<img id="busy" src="/images/busy.gif" />');
 	  },
 	  complete: function (XMLHttpRequest, textStatus) {
 	    $('#busy').remove();
 	  },
 	  success: function (data, textStatus) {
 	    for (var id in data) {
	      $(id).replaceWith(data[id]);
	    }
 	  },
 	  type: 'POST',
 	  url: $form[0].action,
 	  data: $form.serialize(),
 	  dataType: 'json'
	});
      $("#proposition-dialog").hide();
    }
    return false;
  });

});
