class CategoriesController < ApplicationController
  
  layout 'application'

  before_filter :load_catalog

  rescue_from(ActiveRecord::RecordNotFound) {|_| redirect_to(articles_path)}

  def index
    order_string, page, @order, @dir = filter_params(Article::COLUMNS[:category], 'created_at', 'desc')
    @category = Category.find_by_url_name(params[:id])
    unless @category
      redirect_to(articles_path)
    else
      categories = if @category.parent_id.blank?
                     # if selected category is parent category we grab all articles in its child categories
                     [@category] + @category.children.find(:all, :select => 'id').map {|c| c.id}
                   else
                     # if selected category is child category we are interested only in articles from it
                     @category
                   end
      @articles = Article.in_categories_with_author_paginate(categories, order_string, page)
    end
  end

  def show
    # show single article in category, thereby forsale article
    @category = Category.find_by_url_name(params[:category_id])
    unless @category
      redirect_to(articles_path)
    else
      # maybe also include pictures
      @article = @category.articles.forsale.find(params[:id], :include => :author)
    end
  end

end
