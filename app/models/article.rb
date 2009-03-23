class Article < ActiveRecord::Base

  belongs_to :author, :class_name => 'User'
  belongs_to :owner, :polymorphic => true

  has_many :pictures, :as => 'owner', :dependent => :destroy

  named_scope :forsale, :conditions => {:buyer_id => nil, :owner_type => 'Category'}

  COLUMNS = {:all => [ ['category_name', 'Раздел и название'], 
                       ['author_login', 'Автор'], 
                       ['price', 'Цена'],
                       ['length', 'Объем'],
                       ['created_at', 'Дата'] ] }
  COLUMNS[:category] = [['title', 'Название']] + COLUMNS[:all].slice(1..-1)
  COLUMNS[:user] = COLUMNS[:all].slice(0, 1) + COLUMNS[:all].slice(2..-1)

  def self.sort_columns(type)
    self::COLUMNS[type].map {|column, _| column}
  end

  def self.in_categories_with_author_paginate(categories, order, dir, page)
    paginate(:all, :select => 'articles.title, articles.price, articles.length, articles.created_at, articles.id,
                               users.login AS author_login', 
             :joins => 'LEFT JOIN users ON users.id = articles.author_id',
             :conditions => {:buyer_id => nil, :owner_type => 'Category', :owner_id => categories}, 
             :order => "#{order} #{dir}", :page => page)
  end

  def self.authored_by_user_paginate(user, order, dir, page)
    paginate(:all, :select => 'articles.title, articles.price, articles.length, articles.created_at, articles.id,
                               categories.name AS category_name, categories.url_name AS category_url_name',
             :joins => 'LEFT JOIN categories ON articles.owner_id = categories.id',
             :conditions => {:buyer_id => nil, :owner_type => 'Category', :author_id => user.id},
             :order => "#{order} #{dir}", :page => page)
  end

  def self.with_category_and_author_paginate(order, dir, page)
    paginate(:all, :select => 'articles.title, articles.price, articles.length, articles.created_at, articles.id,
                               categories.name AS category_name, categories.url_name AS category_url_name,
                               users.login AS author_login',
             :joins => 'LEFT OUTER JOIN categories ON categories.id = articles.owner_id 
                        LEFT OUTER JOIN users ON users.id = articles.author_id',
             :conditions => {:buyer_id => nil, :owner_type => 'Category'},
             :order => "#{order} #{dir}", :page => page)
  end

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

  validates_presence_of :author, :message => 'анонимные статьи не допускаются'

  def self.per_page
    10
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
