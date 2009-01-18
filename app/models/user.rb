require 'digest/sha1'

class User < ActiveRecord::Base
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken

  LOGIN_REGEX = /\A[a-z0-9][a-z0-9\.\-_@]+\z/

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

  has_many :my_tasks,       :class_name => 'Task', :foreign_key => 'customer_id', :order => 'created_at DESC'
#   has_many :assigned_tasks, :class_name => 'Task', :foreign_key => 'copywriter_id'

#   has_many :my_messages,       :class_name => 'Message', :foreign_key => 'sender_id'
#   has_many :received_messages, :class_name => 'Message', :foreign_key => 'recipient_id'

#   has_many :purchased_articles, :as => 'owner'
#   has_many :articles, :foreign_key => 'author_id'

  has_many :propositions, :foreign_key => 'sender_id'

  def validate
    errors.clear

    login_users = User.find(:all, :conditions => if new_record?
                                                   {:login => login}
                                                 else
                                                   ['login = ? AND id <> ?', login, id]
                                                 end)
    login_error = case 
                  when login.blank? then 'у каждого пользователя должно быть имя'
                  when login.size < 3 then 'слишком короткое имя'
                  when login.size > 40 then 'слишком длинное имя'
                  when login !~ LOGIN_REGEX then 'имя содержит недопустимые символы'
                  when ! login_users.blank? then 'это имя уже занято'
                  end
    errors.add(:login, login_error) unless login_error.nil?

    email_users = User.find(:all, :conditions => if new_record? 
                                                   {:email => email}
                                                 else
                                                   ['email = ? AND id <> ?', email, id]
                                                 end)
    email_error = case
                  when email.blank? then 'адрес e-mail нужен для регистрации'
                  when email !~ EMAIL_REGEX then 'что-то не похоже на адрес e-mail'
                  when ! email_users.blank? then 'этот адрес связан с другим именем'
                  end
    errors.add(:email, email_error) unless email_error.nil?

    password_error = case
                     when password.blank? then 'пароль нужен для защиты Ваших данных'
                     when password.size < 6 then 'слишком короткий пароль'
                     end
    errors.add(:password, password_error) unless password_error.nil?

   confirm_error = case
                   when ! errors.on(:password).nil? then 'повторите правильный пароль'
                   when password != password_confirmation
                     errors.add(:password, 'оба введенных пароля должны совпадать')
                     'повтор не совпадает с первым вводом'
                   end
    errors.add(:password_confirmation, confirm_error) unless confirm_error.nil?

    wmz_error = case
                when (!wmz.blank?) && wmz !~ /^Z(\d){12}$/ then 'неправильный формат номера кошелька'
                end
    errors.add(:wmz, wmz_error) unless wmz_error.nil?
  end

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
