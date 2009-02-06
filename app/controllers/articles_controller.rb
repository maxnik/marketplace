class ArticlesController < ApplicationController

  before_filter :login_required, :except => [:index, :show]
  before_filter :find_my_article, :only => [:edit, :update, :destroy]
  before_filter :handle_pictures, :only => [:create]

  rescue_from(ActiveRecord::RecordNotFound) {|_| redirect_to(articles_path) }

  def index
    page = (params[:page].to_i == 0) ? 1 : params[:page].to_i
    if ['category_name', 'author_login', 'title', 'price', 'length', 'created_at'].include?(params[:order])
      @order = params[:order]
      @dir = ['asc', 'desc'].include?(params[:dir]) ? params[:dir] : 'asc'
    else
      @order, @dir = 'created_at', 'desc'      
    end
    @articles = Article.forsale.with_categories_and_author.paginate(:all, :order => "#{@order} #{@dir}", :page => page)
  end

  def show
    @article = Article.forsale.find(params[:id], :include => [:owner, :author])
    # @pictures = @article.pictures.fullsize
  end

  def new
    @article = Article.new
  end

  def create
    @article = current_user.authored_articles.new(params[:article])
    @article.owner = Category.find(params[:category_id]) 

    @service = ArticleService.new(@article, @pictures) # add pictures to service.save
    if @service.save
      redirect_to(user_path(current_user))
    else
       render :action => 'new'
    end                         
  end

  def edit
    @tasks = current_user.assigned_tasks
  end

  def update
    @article.owner = if params[:type] == 'task'
                       current_user.assigned_tasks.find(params[:task_id])
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
      render :action => 'edit'
    end
  end

  def destroy
    id = @article.id
    @article.destroy
    respond_to do |wants|
      wants.js { render :json => {"#article_#{id}" => render_to_string(:partial => '/articles/article_row', 
                                                                       :locals => {:article => nil})} }
    end
  end

  protected
  
  def find_my_article
    @article = current_user.authored_articles.find(params[:id], :include => :owner)
  end

  def handle_pictures
    @pictures = params[:article][:pic].inject([]) do |pics, file|
      pics << Picture.new(:uploaded_data => pic) if file.is_a?(ActionController::UploadedTempfile)
      pics
    end
  end

end
