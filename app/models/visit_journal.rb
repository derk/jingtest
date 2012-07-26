class VisitJournal < ActiveRecord::Base
  belongs_to :user, :foreign_key => :user_id, :class_name => 'User'
  belongs_to :guest, :foreign_key => :guest_id, :class_name => 'User', :counter_cache => :view_count

  validates_uniqueness_of :user_id, :scope => :guest_id
  validates_associated :user
  validates_associated :guest

  attr_accessible :guest_id, :user_id, :last_visited_at
end
