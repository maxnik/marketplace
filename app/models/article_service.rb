class ArticleService
  
  def initialize(article, pictures)
    @article, @pictures = article, pictures
  end

  def save
    Article.transaction do 
      @article.save!
      if (1..5).include?(@pictures.size)
        @article.pictures << @pictures[0, (5 - @article.pictures.size)]
      end
    end
    true
  rescue ActiveRecord::RecordInvalid
    false
  end

  def update_attributes(*args)
    Article.transaction do 
      @article.update_attributes!(*args)
      if (1..5).include?(@pictures.size)
        @article.pictures << @pictures[0, (5 - @article.pictures.size)]
      end
    end
    true
  rescue ActiveRecord::RecordInvalid
    false
  end

end
