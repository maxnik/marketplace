# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController

  before_filter :load_catalog

  def new
  end

  def create
    params[:remember_me] = (params[:not_my_computer] == '1') ? "0" : "1"
    logout_keeping_session!
    user = User.authenticate(params[:login], params[:password])
    if user
      self.current_user = user
      new_cookie_flag = (params[:remember_me] == "1")
      handle_remember_cookie! new_cookie_flag
      redirect_back_or_default(user_path(current_user))
    else
      note_failed_signin
      @login           = params[:login]
      @not_my_computer = params[:not_my_computer]
      render :action => 'new'
    end
  end

  def destroy
    logout_killing_session!
    flash[:notice] = "You have been logged out."
    redirect_back_or_default('/')
  end

protected
  # Track failed login attempts
  def note_failed_signin
    flash[:error] = "Couldn't log you in as '#{params[:login]}'"
    logger.warn "Failed login for '#{params[:login]}' from #{request.remote_ip} at #{Time.now.utc}"
  end
end
