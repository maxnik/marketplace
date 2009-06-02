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

  def self.per_page
    10
  end

  # [order param value, column header]
  # 4 elements arrays contain also ASC order string and DESC order string
  COLUMNS = {:my => [['name', 'Название'],
                     ['created_at', 'Размещен'],
                     ['articles_count', 'Готово'],
                     ['propositions_count', 'Заявок'],
                     ['last_proposition_at', 'Последняя заявка']]}

  protected

  def after_save
    Article.update_all("owner_name = '#{self.name}', owner_param = '#{self.to_param}'", 
                       {:owner_type => 'Task', :owner_id => self.id})
  end

end
