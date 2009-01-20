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

end
