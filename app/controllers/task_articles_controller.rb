class TaskArticlesController < ArticlesController

  before_filter :find_task, :only => [:new, :create]

  rescue_from(ActiveRecord::RecordNotFound) {|_| redirect_to(assigned_tasks_path) }

  def show
  end

  def create
    @article = current_user.authored_articles.new(params[:article])
    @article.owner = @task
    if @article.save
      Picture.update_all("owner_type = 'Article', owner_id = #{@article.id}", {:id => current_user.picture_ids})
      redirect_to(my_articles_path)
    else
      @pictures = current_user.pictures
      render :action => 'new'
    end
  end

  protected

  def find_task
    @task = current_user.assigned_tasks.find(params[:task_id])
  end

end
