class CategoriesController < ApplicationController
  
  layout 'application'

  before_filter :load_catalog

  def show
    @order, @dir, @page = filter_params(Article.sort_columns(:category), 'created_at', 'desc')
    @category = Category.find_by_url_name(params[:id])
    categories = if @category.parent_id
                   # if selected category is child category we are interested only in articles from it
                   @category
                 else
                   # if selected category is parent category we grab all articles in its child categories
                   @category.children.find(:all, :select => 'id').map {|c| c.id}
                 end
    unless @category
      redirect_to('/')
    else
      @articles = Article.in_categories_with_author_paginate(categories, @order, @dir, @page)
    end
  end

end
