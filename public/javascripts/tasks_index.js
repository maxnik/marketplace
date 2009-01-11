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
//     $("span", $dialog).text('"' + $(this).parent().siblings("h2").eq(0).text() + '"');
//     $("input#proposition_task_id", $dialog).attr('value', this.name);
//     $("textarea", $dialog).val('');
//     $("input#propose", $dialog).attr('disabled', true);
//     $("div#right div#errors").html('');
    $dialog.show();
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
      var $proposition_form = $("#proposition-dialog form");
      $.post($proposition_form[0].action, 
	     $proposition_form.serialize(),
	     function (data) {
	       alert(data);
	     });
      $("#proposition-dialog").hide();
    }
    return false;
  });

});
