class CreateTasks < ActiveRecord::Migration
  def self.up
    create_table :tasks, :force => true do |t|
      t.string  :name
      t.text    :body
      t.integer :price
      t.integer :customer_id, :null => false
      t.integer :propositions_count, :default => 0
      t.integer :articles_count, :default => 0
      t.boolean :closed, :null => false, :default => false
      t.timestamps
    end
  end

  def self.down
    drop_table :tasks
  end
end
