class CreateOpenidServerStuff < ActiveRecord::Migration
  def self.up
    create_table :nonces do |t|
      t.string :nonce
      t.integer :created
      t.timestamps 
    end

    create_table :associations do |t|
      t.binary :server_url, :secret
      t.string :handle, :assoc_type
      t.integer :issued, :lifetime
      t.timestamps 
    end

    create_table :settings do |t|
      t.string :setting
      t.binary :value
      t.timestamps 
    end

    create_table :trusts do |t|
      t.integer :user_id
      t.string :trust_root
      t.timestamps 
    end
  end
  def self.down
    drop_table :nonces
    drop_table :associations
    drop_table :settings
    drop_table :trusts
  end
end
