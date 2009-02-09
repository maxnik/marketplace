class CreateArticles < ActiveRecord::Migration
  def self.up
    create_table :articles, :force => true do |t|
      t.string    :title,     :null => false
      t.text      :body,      :null => false
      t.integer   :length
      t.integer   :buyer_id
      t.integer   :author_id, :null => false
      t.integer   :owner_id
      t.string    :owner_type
      t.integer   :price
      t.timestamps
    end
  end

  def self.down
    drop_table :articles
  end
end
