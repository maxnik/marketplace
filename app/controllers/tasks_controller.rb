class TasksController < ApplicationController

  layout 'application', :except => [:propose, :destroy]

  before_filter :login_required, :except => :index
  before_filter :find_my_task, :only => [:show, :edit, :update, :assign, :destroy]
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
      redirect_to(my_tasks_path)
    else
      render :action => 'new'
    end
  end

  def show
    @title = 'Заказ и заявки на него'
    @propositions = @task.propositions.find(:all, :include => :sender)    
  end

  def edit
    @title = 'Редактирование заказа'
  end

  def update
    if @task.update_attributes(params[:task])
      redirect_to(task_path(@task))
    else
      render :action => 'edit'
    end
  end

  def destroy
    respond_to do |wants|
      wants.js do 
        render :text => "alert(ttt)"
      end
    end
  end

  def propose
    proposition = current_user.propositions.new(params[:proposition])
    proposition.task_id = params[:proposition][:task_id]
    render :json => if proposition.save
                      {:b_class => 'proposition-success', :text => 'Ваша заявка отправлена заказчику'}
                    else
                      {:b_class => 'proposition-error', :text => proposition.errors.on_base}
                    end
  end

  def assign
    fail
  end
  
  def my
    @title = 'Мои заказы'
    @my_tasks = current_user.my_tasks
  end

  def assigned
    # @assigned_tasks = current_user.assigned_tasks
    @assigned_tasks = []
  end

  protected

  def find_my_task
    @task = current_user.my_tasks.find(params[:id])
  end
end
