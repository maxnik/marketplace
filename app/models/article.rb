class Article < ActiveRecord::Base

  belongs_to :author, :class_name => 'User'
  belongs_to :owner, :polymorphic => true # , :counter_cache => true

  # has_many :pictures

  named_scope :forsale, :conditions => {:buyer_id => nil, :owner_type => 'Category'}

  belongs_to :buyer, :class_name => 'User'

  attr_accessible :title, :body, :price

  include PriceInCents

  validates_presence_of :title, :message => 'у каждой статьи должно быть название'
  validates_length_of :title, :in => 10..120, :if => Proc.new {|a| a.errors.on(:title).blank? },
                      :too_short => 'слишком короткое название для статьи',
                      :too_long => 'слишком длинное название для статьи'

  validates_presence_of :body, :message => 'где же сама статья?'
  validates_length_of :body, :in => 100..5000, :if => Proc.new {|a| a.errors.on(:body).blank? },
                      :too_short => 'слишком мало текста для статьи',
                      :too_long => 'статья слишком длинная'

  validates_numericality_of :price, :greater_than => 0, :message => 'цена статьи указана неправильно'

  validates_presence_of :owner, :message => 'можно публиковать статью только для каталога или для заказа'

  protected

  def before_validation
    if self.owner.is_a?(Task)
      self.price = owner.price * (self.body.chars.size / 1000.0)
    end
    if owner_type_changed? || owner_id_changed?
      @old_owner = owner_type_was.constantize.find(owner_id_was)
    end
  end

  def after_save
    self.update_counter_cache
  end

  def after_destroy
    self.update_counter_cache
  end

  def update_counter_cache
    if @old_owner
      @old_owner.update_attribute('articles_count',
                                  Article.count(:conditions => {:owner_id => @old_owner.id,
                                                                :owner_type => @old_owner.class.to_s}))
    end
    self.owner.update_attribute('articles_count', 
                                Article.count(:conditions => {:owner_id => self.owner_id,
                                                              :owner_type => self.owner_type}))
    self.author.update_attribute('forsale_articles_count', 
                                 Article.forsale.count(:conditions => {:author_id => self.author.id}))
  end

end
