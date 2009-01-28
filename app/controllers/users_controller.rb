class UsersController < ApplicationController

  layout 'application'

  before_filter :login_required, :except => [:index, :show, :new, :create]
  before_filter :find_user, :only => [:show, :edit, :update]
  before_filter :check_ownership, :only => [:edit, :update]

  def index
    @users = User.paginate(:page => params[:page])
  end

  def new
    @user = User.new
  end
 
  def create
    logout_keeping_session!
    @user = User.new(params[:user])
    success = @user && @user.save
    if success && @user.errors.empty?
      self.current_user = @user # !! now logged in
      redirect_back_or_default(user_path(@user))
    else
      render :action => 'new'
    end
  end

  def show
    @articles = nil
  end

  protected

  def find_user
    @user = User.find(:first, :conditions => {:login => params[:id]})
    if @user.nil?
      redirect_to(users_path)
      false
    end
  end

  def check_ownership
    redirect_to(new_session_path) unless @user.id == current_user.id
  end

end
