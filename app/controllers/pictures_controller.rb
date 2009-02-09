class PicturesController < ApplicationController
  
  before_filter :check_authorization

  def create
    picture = Picture.new(:uploaded_data => params[:picture])
    
    respond_to do |wants|
      if (current_user.pictures.size < 5) && (current_user.pictures << picture)
        pictures = render_to_string(:partial => 'picture', :collection => current_user.pictures)
        pictures = ('<ol id="pictures">'+pictures+'</ol>').to_json
        wants.js do
          responds_to_parent { render :text => "replace_elements({'#pictures': #{pictures}})" }
        end
      else
        error = picture.errors.on(:base)
        error = 'Вы можете загрузить для одной статьи не более 5-ти иллюстраций.' if error.blank?
        wants.js { responds_to_parent { render :json => "alert('#{error}')" } }
      end
    end
  end

  def connect
    article = current_user.authored_articles.find(params[:id], :include => :pictures)
    picture = Picture.new(:uploaded_data => params[:picture])
    
    respond_to do |wants|
      if (article.pictures.size < 5) && (article.pictures << picture)
        pictures = render_to_string(:partial => 'picture', :collection => article.pictures)
        pictures = ('<ol id="pictures">'+pictures+'</ol>').to_json
        wants.js do 
          responds_to_parent { render :text => "replace_elements({'#pictures': #{pictures}})" }
        end
      else
        error = picture.errors.on(:base)
        error = 'Вы можете загрузить для одной статьи не более 5-ти иллюстраций.' if error.blank?
        wants.js { responds_to_parent { render :json => "alert('#{error}')" } }
      end
    end
  rescue ActiveRecord::RecordNotFound
    head :status => :unauthorized
  end

  def destroy
    picture = Picture.find(params[:id])
    if (picture.owner.is_a?(User) && picture.owner_id == current_user.id) ||
        (picture.owner.is_a?(Article) && picture.owner.author_id == current_user.id)
      id = picture.id
      picture.destroy
      respond_to do |wants|
        wants.js do 
          render :json => {"#picture_#{id}" => render_to_string(:partial => 'picture', :object => nil)} 
        end
      end
    end
  rescue ActiveRecord::RecordNotFound
    head :status => :unauthorized
  end

  protected

  def check_authorization
    unless logged_in?
      head :status => :unauthorized
      return false
    end
  end

end
