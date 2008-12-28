#require 'rutils'

class CreateCategories < ActiveRecord::Migration
  def self.up
    create_table :categories, :force => true do |t|
      t.string  :name
      t.string  :url_name
      t.integer :parent_id, :null => true
      t.integer :articles_count, :default => 0
      t.timestamps
    end
    
    { 'Hi-Tech' => ['Компьютеры', 'Программирование', 'Телефония', 'Техника'],
      'Бизнес' => ['Недвижимость', 'Персонал', 'Производство', 'Реклама', 'Страхование',
                   'Строительство', 'Транспорт', 'Финансы', 'Фирменный стиль', 'Экология',
                   'Форекс', 'Экономика', 'Юриспруденция'],
      'Дом' => ['Бытовая техника', 'Детки', 'Животный мир', 'Интерьер', 'Красота и здоровье',
                'Кулинария', 'Ландшафтный дизайн', 'Личная жизнь', 'Мебель', 'Медицина',
                'Мода', 'Моделирование', 'Праздники и подарки', 'Растения', 'Фэн-шуй'],
      'Культура' => ['Знаменитости', 'Искусство', 'История', 'Кино', 'Книжный мир', 'Музыка',
                     'Паранормальное', 'Проза', 'Рассказы', 'Стихи', 'Театр', 'Фантастика и фэнтези',
                     'Фотография', 'Этикет']}.each do |section, categories|
      new_section = Category.create!(:name => section, :url_name => section.dirify, :parent_id => nil)
      categories.each do |category|
        Category.create!(:name => category, :url_name => category.dirify, :parent_id => new_section.id)
      end
    end    
  end

  def self.down
    drop_table :categories
  end
end
