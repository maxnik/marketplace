class Proposition < ActiveRecord::Base

  attr_accessible :body

  belongs_to :task, :counter_cache => true
  belongs_to :sender, :class_name => 'User'

  named_scope :assigned, :conditions => {:assigned => true}

  protected

  def validate_on_create
    task = Task.free_tasks.find_by_id(self.task_id)
    error = case
            when task.nil? then "заказ уже выполняется"
            when task.customer.id == self.sender_id then "Ваш собственный заказ"
            when body.blank? || body.length < 7 then "слишком короткая заявка"
            when body.length > 500 then "слишком длинная заявка"
            end
    errors.add_to_base(error) unless error.nil?
  end

end
