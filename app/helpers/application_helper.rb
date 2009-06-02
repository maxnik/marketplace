# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def yield_authenticity_token
    if protect_against_forgery?
      <<-JAVASCRIPT
<script type='text/javascript'>
  //<![CDATA[
    window._auth_token_name = "#{request_forgery_protection_token}";
    window._auth_token = "#{form_authenticity_token}";
  //]]>
</script>
JAVASCRIPT
    end
  end

  def items(num, one, two, many)
    if num == 0
      'ни одной<br />' + two
    else
      num.to_s + ' ' + num.items(one, two, many)
    end    
  end

  def time_ago_in_words_or_never(date)
    if date.nil?
      'никогда'
    else
      time_ago_in_words(date) + '<br/>назад'
    end
  end

end
