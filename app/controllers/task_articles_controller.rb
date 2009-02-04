class TaskArticlesController < ArticlesController

  before_filter :find_task, :only => [:new, :create]

  rescue_from(ActiveRecord::RecordNotFound) {|_| redirect_to(assigned_tasks_path) }

  def show
  end

  def create
    @article = current_user.authored_articles.new(params[:article])
    @article.owner = @task
#     @pictures = ['', '1', '2', '3', '4'].inject([]) do |pictures, postfix|
#       pic_file = params["pic#{postfix}"]
#       pictures << Picture.new(:uploaded_data => pic_file) unless pic_file.blank?
#       pictures
#     end    
    @pictures = []
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
