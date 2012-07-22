class CreateVisitJournals < ActiveRecord::Migration
  def change
    create_table :visit_journals do |t|
      t.integer :user_id,  :null => false
      t.integer :guest_id, :null => false

      t.datetime :last_visited_at
    end

    add_index :visit_journals, :user_id
    add_index :visit_journals, :guest_id
    add_index :visit_journals, [:user_id, :guest_id]
  end
end
