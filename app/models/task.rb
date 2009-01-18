class Task < ActiveRecord::Base

  belongs_to :customer,   :class_name => 'User', :foreign_key => 'customer_id'
  belongs_to :copywriter, :class_name => 'User', :foreign_key => 'copywriter_id'

  named_scope :free_tasks, :conditions => {:copywriter_id => nil}, :include => :customer, :order => 'created_at DESC'

  attr_accessible :name, :body, :price

  has_many :propositions, :order => 'created_at ASC'

#  has_many :articles, :as => 'owner'

  def price=(price)
    write_attribute(:price, (price.to_s.gsub(',', '.').to_f * 100).to_i)
  end

  def price
    unless read_attribute(:price).blank?
      float_price = read_attribute(:price)  / 100.0
      (float_price.round == float_price) ? float_price.to_i : float_price
    end
  end

  protected 

  def validate
    errors.clear

    name_error = case
                 when name.blank? then 'у каждого заказа должно быть название'
                 when name.size < 15 then 'слишком короткое название для заказа'
                 when name.size > 120 then 'слишком длинное название для заказа'
                 end
    errors.add(:name, name_error) unless name_error.nil?

    body_error = case
                 when body.blank? then 'для заказа нужно подробное описание'
                 when body.size < 100 then 'слишком короткое описание заказа'
                 when body.size > 500 then 'слишком длинное описание заказа'
                 end
    errors.add(:body, body_error) unless body_error.nil?

    price_error = case
                  when price <= 0.0 then 'цена за тысячу знаков указана неправильно'
                  end
    errors.add(:price, price_error) unless price_error.nil?

#     pretender_ids = propositions.map {|p| p.sender_id }
#     unless copywriter_id.nil? || pretender_ids.any? {|p_id| p_id == copywriter_id}
#       errors.add(:copywriter_id, 'Заказ можно назначить только тому, кто подавал заявку.')
#     end
  end

end
