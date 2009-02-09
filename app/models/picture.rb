class Picture < ActiveRecord::Base

  belongs_to :owner, :polymorphic => true

  has_attachment :content_type => :image, 
                 :storage => :file_system,
                 :max_size => 200.kilobytes,
                 :thumbnails => {:thumb => '80x80'},
                 :processor => :MiniMagick

  validates_as_attachment

  protected
  
  def validate
    if errors.size > 0
      error = case
              when errors.on(:content_type) == ActiveRecord::Errors.default_error_messages[:inclusion]
                'Загруженный файл не является изображением. Использовать его как иллюстрацию нельзя.'
              when errors.on(:size) == ActiveRecord::Errors.default_error_messages[:inclusion]
                'Размер файла превышает допустимые 200 кбайт.'
              end
      errors.add_to_base(error.nil? ? 'Неизвестная ошибка, попробуйте еще раз.' : error)      
    end
  end

end
