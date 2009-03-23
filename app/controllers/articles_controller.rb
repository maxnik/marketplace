class ArticlesController < ApplicationController

  before_filter :login_required, :except => [:index, :show]
  before_filter :load_catalog, :except => :destroy
  before_filter :find_my_article, :only => [:edit, :update]

  rescue_from(ActiveRecord::RecordNotFound) {|_| redirect_to(articles_path) }

  def index
    @order, @dir, @page = filter_params(Article.sort_columns(:all), 'created_at', 'desc')

    @articles = Article.with_category_and_author_paginate(@order, @dir, @page)
  end

  def show
    @article = Article.forsale.find(params[:id], :include => [:owner, :author])
    # @pictures = @article.pictures.fullsize
  end

  def new
    @article = Article.new
    @pictures = current_user.pictures
  end

  def create
    @article = current_user.authored_articles.new(params[:article])
    @article.owner = Category.find(params[:category_id]) 
    if @article.save
      Picture.update_all("owner_type = 'Article', owner_id = #{@article.id}", {:id => current_user.picture_ids})
      redirect_to(user_path(current_user))
    else
      @pictures = current_user.pictures
      render :action => 'new'
    end                         
  end

  def edit
    @tasks = current_user.assigned_tasks
  end

  def update
    @article.owner = if params[:type] == 'task'
                       current_user.assigned_tasks.find_by_id(params[:task_id])
                     else
                       Category.find(params[:category_id])              
                     end
    if @article.update_attributes(params[:article])
      if @article.owner_type == 'Task'
        redirect_to(assigned_tasks_path)
      else
        redirect_to(user_path(current_user))
      end
    else
      @tasks = current_user.assigned_tasks
      render :action => 'edit'
    end
  end

  def destroy
    @article = current_user.authored_articles.find(params[:id])
    id = @article.id
    @article.destroy
    respond_to do |wants|
      wants.js { render :json => {"#article_#{id}" => render_to_string(:partial => '/articles/article_row', 
                                                                       :locals => {:article => nil})} }
    end
  rescue ActiveRecord::RecordNotFound
    respond_to do |wants|
      wants.js { render :status => 401 }
    end
  end

  protected
  
  def find_my_article
    @article = current_user.authored_articles.find(params[:id], :include => [:pictures, :owner])
  end

end
