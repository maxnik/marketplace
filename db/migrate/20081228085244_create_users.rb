class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table "users", :force => true do |t|
      t.column :login,                     :string, :limit => 40

      t.column :email,                     :string, :limit => 100
      t.column :crypted_password,          :string, :limit => 40
      t.column :salt,                      :string, :limit => 40
      t.column :created_at,                :datetime
      t.column :updated_at,                :datetime
      t.column :remember_token,            :string, :limit => 40
      t.column :remember_token_expires_at, :datetime

      t.column :wmz,                       :string
      t.column :last_login_at,             :datetime
      t.column :last_tasks_at,             :datetime
      t.column :last_messages_at,          :datetime

    end
    add_index :users, :login, :unique => true

    (1..200).each do |index|
      u = User.new(:login => "user#{index}", :email => "user#{index}@textino.ru",
                   :password => 'password', :password_confirmation => 'password')
      u.created_at = (index % 10).month.ago
      u.save!
    end
    User.create!(:login => '1234567890_123456789', :email => 'ttt@test.com',
                 :password => 'password', :password_confirmation => 'password')
  end

  def self.down
    drop_table "users"
  end
end
