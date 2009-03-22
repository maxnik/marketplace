class Category < ActiveRecord::Base

  def self.load_catalog
    categories = Category.find(:all)
    # {parent_category1_id => [parent_category1], parent_category2_id => [parent_category2], ...}
    sections = categories.inject({ }) do |sections, category|
      sections[category.id] = [category] if category.parent_id.nil?
      sections
    end
    # {parent_category1_id => [parent_category1, child1_of_parent_category1, child2_of_parent_category1, ...], ...}
    categories.each do |category|
      sections[category.parent_id] << category unless category.parent_id.nil?
    end    
    # parent_categories_sorted_by_name - [[parent_catecory1, [childs_of_parent_category1_sorted_by_name]]...]
    sections.map do |section_id, section_categories|
      [section_categories[0], section_categories.slice(1..-1).sort! {|a, b| a.name <=> b.name}]
    end.sort! {|a, b| a[0].name <=> b[0].name}
  end

  def to_param
    url_name
  end

  has_many :articles, :as => 'owner'

  has_many :children, :class_name => 'Category', :foreign_key => 'parent_id'

end
