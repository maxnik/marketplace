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

  def owner_link_to(article)
    owner_type = article.owner_type.downcase

    link_to(article.owner_name, 
            send("#{owner_type}_path".to_sym, article.owner_param),
            :class => "#{owner_type}-link")
  end

  def buyer_link_or_nobody(article)
    if article.buyer_login.blank?
      'еще нету'
    else
      link_to(article.buyer_login, user_path(article.buyer_login), :class => 'user-link')
    end
  end

  def formatted_article_length(article)
    sprintf('%.1f', article.length / 1000.0).gsub('.', ',') + ' тыс.<br />знаков'
  end

  def formatted_article_price(article)
    number_to_currency(article.price, :format => '%n<br />WMZ', :separator => ',', :delimiter => '')
  end

  def formatted_article_time(article)
    time_ago_in_words(article.created_at).gsub('около ', 'около<br />') + '<br />назад'
  end

  def public_or_personal_article_link(article, user)
    if article.author_id == user.id
      # personal link, only for author
      link_to(h(article.title), article_path(article), :class => 'article-link')
    else
      # public link
      link_to(h(article.title), category_article_path(article.owner_param, article), :class => 'article-link')
    end
  end

end
