class UserMailer < ActionMailer::Base
  

  def recover(user)
    subject    'Восстановление пароля'
    recipients user.email
    from       'Биржа Textino <textino.admin@gmail.com>'
    body       :user => user
  end

end
