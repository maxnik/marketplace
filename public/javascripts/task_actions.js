$(document).ready(function () {

  $('a.delete-task-link').live('click', function () {
    if (!this.title || confirm(this.title)) {
      $.post(this.href, {_method: 'delete'}, function (data) {
        alert(data.test);
      }, 'json');
    }
    return false;
  });
		    
  $('a.free-task-link').live('click', function () {
    if (!this.title || confirm(this.title)) {
      $.post(this.href, {_method: 'put'}, function (data) {
        alert(data);
      }, 'json');
    }
    return false;
  });
		    
  $('a.assign-link').live('click', function () {
    if (!this.title || confirm(this.title)) {
       $.post(this.href, {_method: 'put'}, function (data) {
	 for (var id in data) {
	   $(id).replaceWith(data[id]);
	 }
       }, 'json');
    }
    return false;
  });
  
});
