class VisitJournal < ActiveRecord::Base
  belongs_to :user, :foreign_key => :guest_id
  belongs_to :guest, :foreign_key => :user_id, :counter_cache => :view_count

  validates_uniqueness_of :user_id, :scope => :guest_id
  validates_associated :user
  validates_associated :guest
end
