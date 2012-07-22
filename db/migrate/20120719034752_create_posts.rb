class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.text    :content,   :null => false
      t.integer :user_id,   :null => false
      t.integer :shadow_id, :null => false
      t.integer :parent_id
      t.integer :view_count, :default => 0
      
      t.timestamps
    end
    
    add_index :posts, :content
    add_index :posts, :user_id
    add_index :posts, :shadow_id
    add_index :posts, :parent_id
    add_index :posts, [:user_id, :content]
    add_index :posts, [:user_id, :shadow_id]
  end
end
