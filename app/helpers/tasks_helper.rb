module TasksHelper

  def is_not_mine?(task)
    (!logged_in?) || task.customer.id != current_user.id
  end

end
