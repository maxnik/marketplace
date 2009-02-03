class ArticleService
  
  def initialize(article, pictures)
    @article, @pictures = article, pictures
  end

  def valid?
    @article.valid? && @pictures.all? {|p| p.valid? }
  end

  def save
    return false unless valid?
    begin 
      Article.transaction do 
        @article.save!
      end
      true
    rescue
      false
    end
  end

end
