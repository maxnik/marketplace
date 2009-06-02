require 'digest/sha1'

class User < ActiveRecord::Base
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken

  LOGIN_REGEX = /\A[a-z0-9][a-z0-9\-_]+\z/

  EMAIL_NAME_REGEX  = '[a-z0-9\.%\+\-]+'.freeze
  EMAIL_REGEX       = /\A#{EMAIL_NAME_REGEX}@#{Authentication.domain_head_regex}#{Authentication.domain_tld_regex}\z/i

  
  attr_accessible :login, :email, :password, :password_confirmation, :wmz

  def self.authenticate(login, password)
    return nil if login.blank? || password.blank?
    u = find_by_login(login) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  def login=(value)
    write_attribute :login, (value ? value.downcase : nil)
  end

  def email=(value)
    write_attribute :email, (value ? value.downcase : nil)
  end

  has_many :my_tasks, 
           :class_name => 'Task', :foreign_key => 'customer_id', :dependent => :destroy

#   has_many :my_messages,       :class_name => 'Message', :foreign_key => 'sender_id'
#   has_many :received_messages, :class_name => 'Message', :foreign_key => 'recipient_id'

  has_many :bought_articles, :class_name => 'Article', :foreign_key => 'buyer_id'

  has_many :authored_articles, :class_name => 'Article', :foreign_key => 'author_id', :dependent => :nullify

  has_many :propositions, :foreign_key => 'sender_id'

  has_many :assigned_tasks, :through => :propositions, :source => :task,
                            :uniq => true, :conditions => 'propositions.assigned = true'

  has_many :pictures, :as => 'owner', :dependent => :destroy

  include MyValidations

  my_validates_presence_of :login, :message => 'у каждого пользователя должно быть имя'
  my_validates_length_of :login, :in => 3..40, :too_short => 'слишком короткое имя', :too_long => 'слишком длинное имя'
  my_validates_format_of :login, :with => LOGIN_REGEX, :message => 'имя содержит недопустимые символы'
  my_validates_uniqueness_of :login, :message => 'это имя уже занято другим пользователем'

  my_validates_presence_of :email, :message => 'адрес электронной почты нужен для регистрации'
  my_validates_format_of :email, :with => EMAIL_REGEX, :message => 'что-то не похоже это на адрес e-mail'
  my_validates_uniqueness_of :email, :message => 'этот адрес уже связан с другим именем пользователя'

  password_proc = Proc.new {|u| u.errors.on(:password).blank? && u.password_required? }

  validates_presence_of :password, :message => 'пароль нужен для защиты Ваших данных', :if => password_proc
  validates_length_of :password, :minimum => 6, :message => 'слишком короткий пароль', :if => password_proc
  validates_confirmation_of :password, :message => 'пароль и его подтверждение должны совпадать', :if => password_proc

  validates_format_of :wmz, :with => /^Z(\d){12}$/, :message => 'неправильный формат номера кошелька', 
                      :unless => Proc.new {|u| u.wmz.blank? }

  def self.per_page
    10
  end

  def to_param
    login
  end

  def initialize(*args)
    super
    self.last_login_at = self.last_tasks_at = self.last_messages_at = Time.now
  end

end
