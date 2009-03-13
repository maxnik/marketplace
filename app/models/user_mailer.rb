class UserMailer < ActionMailer::Base
  

  def recover(user)
    subject    'Восстановление пароля'
    recipients 'maxim.nikolenko@gmail.com'
    from       'Биржа Textino <textino.admin@gmail.com>'
    body       :user => 'mmm'
  end

end
