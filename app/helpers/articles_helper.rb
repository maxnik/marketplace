module ArticlesHelper

  def sort_link(order, dir, column, link_text)
    link_class = nil
    if order == column
        link_class = "%s-link" % dir
        dir = (dir == 'asc') ? 'desc' : 'asc'
    else
        dir = 'asc'
    end
    link_to(link_text, {:order => column, :dir => dir}, :class => link_class)
  end

  def author_link_for(article)
    if logged_in? && (current_user.login == article.author_login)
      'Ваша статья'
    else
      link_to(article.author_login, user_path(article.author_login), :class => 'user-link')
    end
  end

end
