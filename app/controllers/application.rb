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

  def filter_params(columns, default_column, default_direction)
    page = (params[:page].to_i == 0) ? 1 : params[:page].to_i

    sort_params = columns.find {|column, *| column == params[:order]}
    
    if sort_params.nil?
      # order column omitted in params or wrong sort column name passed
      order_string = "#{default_column} #{default_direction}"
      order, dir = default_column, default_direction
    else
      order = params[:order] # order column name passed is valid
      dir = ['asc', 'desc'].include?(params[:dir]) ? params[:dir] : 'asc'
      
      if (sort_params.size == 2)
        order_string = "#{order} #{dir}" # column name equals to param
      else
        # use hardcoded order strings from model
        if (dir == 'asc')
          order_string = "#{sort_params[2]}"
        else
          order_string = "#{sort_params[3]}"
        end
      end
    end
    return order_string, page, order, dir
  end
end
