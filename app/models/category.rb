class Category < ActiveRecord::Base

  def self.load_catalog
    categories = Category.find(:all)

    sections = categories.inject({ }) do |sections, category|
      sections[category.id] = [category] if category.parent_id.nil?
      sections
    end

    categories.each do |category|
      sections[category.parent_id] << category unless category.parent_id.nil?
    end

    sections.map do |section_id, section_categories|
      [section_categories[0], section_categories.slice(1..-1).sort! {|a, b| a.name <=> b.name}]
    end.sort! {|a, b| a[0].name <=> b[0].name}
  end

  def to_param
    url_name
  end
end
