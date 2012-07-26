class Follow < ActiveRecord::Base

  extend ActsAsFollower::FollowerLib
  extend ActsAsFollower::FollowScopes

  # NOTE: Follows belong to the "followable" interface, and also to followers
  belongs_to :followable, :polymorphic => true
  belongs_to :follower,   :polymorphic => true

  after_create :init_visit_journal

  def block!
    self.update_attribute(:blocked, true)
  end

private
  def init_visit_journal
    journal = VisitJournal.where(:guest_id => self.follower_id, :user_id => self.followable_id).first
    unless journal
    	VisitJournal.create!(:guest_id => self.follower_id, :user_id => self.followable_id, :last_visited_at => Time.local(2012,1,1))
    end
    true
  end

end
