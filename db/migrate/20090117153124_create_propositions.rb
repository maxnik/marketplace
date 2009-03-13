class CreatePropositions < ActiveRecord::Migration
  def self.up
    create_table :propositions, :force => true do |t|
      t.integer :sender_id
      t.text :body
      t.integer :task_id
      t.boolean :assigned, :null => false, :default => false
      t.timestamps
    end
  end

  def self.down
    drop_table :propositions
  end
end
