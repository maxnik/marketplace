class CreatePictures < ActiveRecord::Migration
  def self.up
    create_table :pictures, :force => true do |t|
      t.integer :owner_id
      t.string :owner_type
      t.integer :parent_id, :size, :width, :height
      t.string :content_type, :filename, :thumbnail
      t.timestamps
    end
  end

  def self.down
    drop_table :pictures
  end
end
