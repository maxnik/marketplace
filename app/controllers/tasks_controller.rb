class TasksController < ApplicationController

  layout 'application', :except => [:propose, :assign, :destroy]

  before_filter :login_required, :except => :index
  before_filter :find_my_task, :only => [:show, :edit, :update, :assign, :destroy]
  rescue_from(ActiveRecord::RecordNotFound) {|e| redirect_to(tasks_path) }

  def index
    @tasks = Task.free_tasks.find(:all, :order => 'created_at DESC')
  end

  def new
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
    @propositions = @task.propositions.find(:all, :include => :sender)    
  end

  def edit
  end

  def update
    if @task.update_attributes(params[:task])
      redirect_to(task_path(@task))
    else
      render :action => 'edit'
    end
  end

  def destroy
    deleted_param = @task.to_param
    @task.destroy
    @task = nil
    respond_to do |wants|
      wants.js do 
        render :json => {"#task_#{deleted_param}" => render_to_string(:partial => 'task', :object => @task)}
      end
    end
  end

  def propose
    proposition = current_user.propositions.new(params[:proposition])
    proposition.task_id = params[:proposition][:task_id]
    proposition.save
    respond_to do |wants|
      wants.js { render :json => {"#status_task_#{proposition.task_id}" => render_to_string(:partial => 'status_task',
                                                                                            :locals => 
                                                                                            {:proposition => proposition})}}
    end
  end

  def assign
    old_copywriter = @task.copywriter
    copywriter = User.find_by_login(params[:copywriter_id])
    @task.copywriter = copywriter
    if @task.save
      @propositions = Proposition.find(:all, :conditions => {:sender_id => [old_copywriter, copywriter],
                                                             :task_id => @task})
      respond_to do |wants|
        wants.js do 
          task_actions = {"#task_actions_#{@task.to_param}" => render_to_string(:partial => 'task_actions',
                                                                                :locals => {:task => @task})}

          task_actions["#copywriter_for_#{@task.to_param}"] = '' if copywriter.nil?

          render :json => (@propositions.inject(task_actions) do |fragments, p| 
                             fragments["#proposition_#{p.to_param}"] = render_to_string(:partial => 'proposition', 
                                                                                        :locals => {:proposition => p,
                                                                                                    :task => @task})
                             fragments
                           end)
        end
      end
    else
      respond_to do |wants|
        wants.js do 
          render :json => {:status => 'failed'}
        end
      end
    end
  end
  
  def my
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
