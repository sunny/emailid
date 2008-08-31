class CreateAuthentifications < ActiveRecord::Migration
  def self.up
    create_table :authentifications do |t|
      t.string :email, :null => false
      t.string :ok_hash, :null => false
      t.text :auth_data
      t.timestamps
    end
  end

  def self.down
    drop_table :authentifications
  end
end
