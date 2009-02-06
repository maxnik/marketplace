class TaskArticlesController < ArticlesController

  before_filter :find_task, :only => [:new, :create]

  rescue_from(ActiveRecord::RecordNotFound) {|_| redirect_to(assigned_tasks_path) }

  def show
  end

  def create
    @article = current_user.authored_articles.new(params[:article])
    @article.owner = @task
    @service = ArticleService.new(@article, @pictures) # add pictures to service.save

    if @service.save
      redirect_to(assigned_tasks_path)
    else
      render :action => 'new'
    end
  end

  protected

  def find_task
    @task = current_user.assigned_tasks.find(params[:task_id])
  end

end
