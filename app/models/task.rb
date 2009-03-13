class Task < ActiveRecord::Base

  belongs_to :customer,   :class_name => 'User', :foreign_key => 'customer_id'

  named_scope :free_tasks, :conditions => {:closed => false}, :include => :customer, :order => 'created_at DESC'

  attr_accessible :name, :body, :price

  has_many :propositions, :order => 'created_at ASC', :dependent => :destroy

  has_many :articles, :as => 'owner', :order => 'created_at ASC', :dependent => :nullify

  include PriceInCents

  validates_presence_of :name, :message => 'у каждого заказа должно быть название'
  validates_length_of :name, :in => 15..120, :if => Proc.new {|t| t.errors.on(:name).blank? },
                      :too_short => 'слишком короткое название для заказа',
                      :too_long => 'слишком длинное название для заказа'
  
  validates_presence_of :body, :message => 'для заказа нужно подробное описание'
  validates_length_of :body, :in => 100..800, :if => Proc.new {|t| t.errors.on(:body).blank? },
                      :too_short => 'слишком короткое описание заказа',
                      :too_long => 'слишком длинное описание заказа'

  validates_numericality_of :price, :greater_than => 0, :message => 'цена за тысячу знаков указана неправильно'

  validates_presence_of :customer_id, :message => 'анонимные заказы не допускаются'

end
