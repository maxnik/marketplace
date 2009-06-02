class Article < ActiveRecord::Base

  belongs_to :author, :class_name => 'User'
  belongs_to :owner, :polymorphic => true

  has_many :pictures, :as => 'owner', :dependent => :destroy

  named_scope :forsale, :conditions => {:buyer_id => nil, :owner_type => 'Category'}

  # [order param value, column header]
  # 4 elements arrays contain also ASC order string and DESC order string
  COLUMNS = {:all => [ ['owner_name', 'Раздел и название'], 
                       ['author_login', 'Автор'], 
                       ['price', 'Цена'],
                       ['length', 'Объем'],
                       ['created_at', 'Размещена'] ] }
  COLUMNS[:category] = [['title', 'Название']] + COLUMNS[:all].slice(1..-1)
  COLUMNS[:user] = COLUMNS[:all].slice(0, 1) + COLUMNS[:all].slice(2..-1)
  COLUMNS[:my] = [['type', 'Место и название', 
                   'articles.owner_type ASC, articles.owner_param ASC',
                   'articles.owner_type DESC, articles.owner_param ASC'],
                  ['buyer_id', 'Покупатель']] + COLUMNS[:all].slice(2..-1)

  def self.in_categories_with_author_paginate(categories, order_string, page)
    forsale.paginate(:all, :select => 'articles.title, articles.price, articles.length, articles.created_at, articles.id,
                                       users.login AS author_login, articles.author_id, articles.owner_param', 
                     :joins => 'LEFT JOIN users ON users.id = articles.author_id',
                     :conditions => {:owner_id => categories}, 
                     :order => order_string, :page => page)
  end

  def self.authored_by_user_paginate(author, order_string, page)
    forsale.paginate(:all, :select => 'articles.title, articles.price, articles.length, articles.created_at, articles.id,
                                       articles.owner_name, articles.owner_param, articles.author_id',
                     :conditions => {:author_id => author.id},
                     :order => order_string, :page => page)
  end

  def self.with_category_and_author_paginate(order_string, page)
    forsale.paginate(:all, :select => 'articles.title, articles.price, articles.length, articles.created_at, articles.id,
                                       articles.owner_name, articles.owner_param, articles.author_id,
                                       users.login AS author_login',
                     :joins => 'LEFT OUTER JOIN users ON users.id = articles.author_id',
                     :order => order_string, :page => page)
  end

  def self.authored_by_with_owner_and_buyer_paginate(author, order_string, page)
    paginate(:all, :select => 'articles.id, articles.title, articles.price, articles.length, articles.created_at,
                               articles.owner_type, articles.owner_name, articles.owner_param,
                               users.login AS buyer_login',
             :joins => 'LEFT JOIN users ON users.id = articles.buyer_id',
             :conditions => {:author_id => author.id},
             :order => order_string, :page => page)
  end

  belongs_to :buyer, :class_name => 'User'

  attr_accessible :title, :description, :body, :price

  include PriceInCents

  validates_presence_of :title, :message => 'у каждой статьи должно быть название'
  validates_length_of :title, :in => 10..120, :if => Proc.new {|a| a.errors.on(:title).blank? },
                      :too_short => 'слишком короткое название для статьи',
                      :too_long => 'слишком длинное название для статьи'

  validates_presence_of :description, :message => 'у каждой статьи должно быть описание'
  validates_length_of :description, :in => 100..500, :if => Proc.new {|a| a.errors.on(:description).blank? },
                      :too_short => 'слишком короткое описание для статьи',
                      :too_long => 'слишком длинное описание для статьи'

  validates_presence_of :body, :message => 'где же сама статья?'
  validates_length_of :body, :in => 100..10000, :if => Proc.new {|a| a.errors.on(:body).blank? },
                      :too_short => 'слишком мало текста для статьи',
                      :too_long => 'статья слишком длинная'

  validates_numericality_of :price, :greater_than => 0, :message => 'цена статьи указана неправильно'

  validates_presence_of :owner, :message => 'можно публиковать статью только для каталога или для заказа'

  validates_presence_of :author, :message => 'анонимные статьи не допускаются'

  def self.per_page
    10
  end

  def fullsize_picture_ids
    pictures.fullsize.find(:all, :select => 'id').map {|p| p.id}
  end

  protected

  def before_validation
    unless self.body.nil?
      self.length = self.body.chars.split(//u).inject(0) {|length, char| length += 1 unless char =~ /\s/; length}
    end
    if self.owner.is_a?(Task)
      self.price = owner.price * (self.length / 1000.0)
    end
    if !new_record? && (owner_type_changed? || owner_id_changed?)
      @old_owner = owner_type_was.constantize.find(owner_id_was)
    end
    if owner
      self.owner_name = owner.name
      self.owner_param = owner.to_param
    end
  end

  def after_save
    self.update_counter_cache
  end

  def after_destroy
    self.update_counter_cache
  end

  def update_counter_cache
    @old_owner.update_attribute('articles_count', @old_owner.articles.count) if @old_owner
    self.owner.update_attribute('articles_count', self.owner.articles.count)
    self.author.update_attribute('forsale_articles_count', self.author.authored_articles.forsale.count)
  end

end
