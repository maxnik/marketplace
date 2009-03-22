# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'e10bb980cde98ef06391b356b26888bf'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password

  include AuthenticatedSystem

  protected

  def load_catalog
    @catalog = Category.load_catalog
  end

  def filter_params(sort_columns, default_column, default_direction)
    page = (params[:page].to_i == 0) ? 1 : params[:page].to_i
    if sort_columns.include?(params[:order])
      dir = ['asc', 'desc'].include?(params[:dir]) ? params[:dir] : 'asc'
      return params[:order], dir, page
    else
      return default_column, default_direction, page
    end
  end
end
