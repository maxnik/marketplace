class DenormalizeArticles < ActiveRecord::Migration
  def self.up
    add_column :articles, :description, :text, :null => false
    add_column :articles, :owner_name, :string, :null => false
    add_column :articles, :owner_param, :string, :null => false

    articles = Article.find(:all, :include => 'owner')
    articles.each do |article|
      article.description = 'Короткое описание статьи, чисто заполнитель. Тут обязательно должен быть осмысленный текст'
      article.owner_name = article.owner.name
      article.owner_param = article.owner.to_param
      article.save!
    end
  end

  def self.down
    remove_columns(:articles, :description, :owner_name, :owner_param)
  end
end
