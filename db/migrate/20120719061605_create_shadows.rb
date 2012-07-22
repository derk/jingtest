class CreateShadows < ActiveRecord::Migration
  def change
    create_table :shadows do |t|
      t.text    :web_url,     :null => false, :length => 1024, :unique => true
      t.string  :title,       :default => ""
      t.text    :description, :default => ""
      t.integer :post_id      # if the shadow is a post page, save the post_id

      t.datetime :created_at
    end
    
    add_index :shadows, :web_url
    add_index :shadows, :title
    add_index :shadows, :post_id
  end
end
