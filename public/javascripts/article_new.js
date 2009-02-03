$(document).ready(function () {
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

/*		    
  $('#pic').MultiFile({
    max: 5,
    accept: 'gif|jpg|png|bmp',
    namePattern: '$name$i'
  });
*/
});
