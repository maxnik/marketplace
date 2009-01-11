class TasksController < ApplicationController

  layout 'application'

  before_filter :login_required, :except => :index
  before_filter :find_my_task, :only => [:show, :update]
  rescue_from(ActiveRecord::RecordNotFound) {|e| redirect_to(tasks_path) }

  def index
    @title = 'Новые заказы'
    @tasks = Task.free_tasks.find(:all, :order => 'created_at DESC')
  end

  def new
    @title = 'Добавить новый заказ'
    @task = current_user.my_tasks.new
  end

  def create
    @task = current_user.my_tasks.new(params[:task])
    if @task.save
      redirect_to(tasks_user_path(current_user))
    else
      render :action => 'new'
    end
  end

  def show
    @propositions = @task.propositions.find(:all, :include => :sender)    
  end

  def update
    @task.copywriter_id = params[:copywriter_id]
    @task.save
    show()
    render :action => 'show'
  end

  def create_proposition    
    @proposition = current_user.propositions.new(params[:proposition])
    if @proposition.save
      render :text => '<span style="color: #0a0;">Ваша заявка доставлена заказчику.</span>'
    else
      render :text => "<span style=\"color: #b20000;\">#{@proposition.errors.on_base}</span>"
    end
  end
  
  protected

  def find_my_task
    @task = current_user.my_tasks.find(params[:id])
  end
end
