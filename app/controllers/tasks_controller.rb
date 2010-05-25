class TasksController < ApplicationController

  layout 'application', :except => [:propose, :assign, :destroy]

  before_filter :login_required, :except => :index
  before_filter :load_catalog, :except => [:propose, :assign, :close, :destroy]
  before_filter :find_my_task, :only => [:show, :edit, :update, :assign, :close, :destroy]
  rescue_from(ActiveRecord::RecordNotFound) {|e| redirect_to(tasks_path) }

  def index
    @tasks = Task.free_tasks
  end

  def new
    @task = current_user.my_tasks.new
  end

  def create
    @task = current_user.my_tasks.new(params[:task])
    if @task.save
      redirect_to(task_path(@task))
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
        render :json => {"task_#{deleted_param}" => render_to_string(:partial => 'task', :object => @task)}
      end
    end
  end

  def propose
    proposition = current_user.propositions.new(params[:proposition])
    proposition.task_id = params[:proposition][:task_id]
    proposition.save
    respond_to do |wants|
      wants.js { render :json => {"status_task_#{proposition.task_id}" => render_to_string(:partial => 'status_task',
                                                                                           :locals => 
                                                                                           {:proposition => proposition})}}
    end
  end

  def close
    @task.toggle!('closed')
    respond_to do |wants|
      wants.js do 
        task_actions = {"task_actions_#{@task.to_param}" => render_to_string(:partial => 'task_actions',
                                                                             :locals => {:task => @task})}
        render :json => task_actions
      end
    end
  end

  def assign
#     old_copywriter = @task.copywriter
#     copywriter = User.find_by_login(params[:copywriter_id])
#     @task.copywriter = copywriter

    proposition = @task.propositions.find(params[:proposition_id])
    proposition.toggle!('assigned')
    respond_to do |wants|
      wants.js do 
        render :json => { "proposition_#{proposition.to_param}" => 
                          render_to_string(:partial => 'proposition', :locals => {:proposition => proposition,
                                                                                  :task => @task}) }
      end
    end
  rescue ActiveRecord::RecordNotFound
    head :status => :unauthorized

#     if @task.save
#       @propositions = Proposition.find(:all, :conditions => {:sender_id => [old_copywriter, copywriter],
#                                                              :task_id => @task})
#       respond_to do |wants|
#         wants.js do 
#           task_actions = {"#task_actions_#{@task.to_param}" => render_to_string(:partial => 'task_actions',
#                                                                                 :locals => {:task => @task})}

#           task_actions["#copywriter_for_#{@task.to_param}"] = '' if copywriter.nil?

#           render :json => (@propositions.inject(task_actions) do |fragments, p| 
#                              fragments["#proposition_#{p.to_param}"] = render_to_string(:partial => 'proposition', 
#                                                                                         :locals => {:proposition => p,
#                                                                                                     :task => @task})
#                              fragments
#                            end)
#         end
#       end
#     else
#       respond_to do |wants|
#         wants.js do 
#           render :json => {:status => 'failed'}
#         end
#       end
#     end
  end
  
  def my

    # obsolete
    @my_tasks = current_user.my_tasks.find(:all, :include => {:articles => :author})
    # obsolete

    order_string, page, @order, @dir = filter_params(Task::COLUMNS[:my], 'last_proposition_at', 'desc')

    columns = Task.column_names.map {|c| "tasks.#{c}" }.join(',')
    @tasks = current_user.my_tasks.paginate(:all, 
                                        :select => 'tasks.name, tasks.created_at, articles_count, propositions_count,
                                                    tasks.closed, tasks.id,
                                                    MAX(propositions.created_at) AS last_proposition_at', 
                                        :joins => 'LEFT JOIN propositions ON propositions.task_id = tasks.id', 
                                        :group => "tasks.id, #{columns}",
                                        :order => order_string, :page => page)
  end

  def assigned
    # @assigned_tasks = current_user.assigned_tasks.find(:all, :include => {:articles => :author})
    @propositions = current_user.propositions.assigned
    task_ids = @propositions.map {|p| p.task_id}.uniq
    @tasks = Task.find(:all, :conditions => {:id => task_ids}, :include => :customer)
  end

  protected

  def find_my_task
    @task = current_user.my_tasks.find(params[:id])
  end
end
