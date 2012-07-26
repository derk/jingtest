class Follow < ActiveRecord::Base

  extend ActsAsFollower::FollowerLib
  extend ActsAsFollower::FollowScopes

  # NOTE: Follows belong to the "followable" interface, and also to followers
  belongs_to :followable, :polymorphic => true
  belongs_to :follower,   :polymorphic => true

  after_create :init_visit_journal, :if => Proc.new { |f| f.follower.visit_journals.where(:user_id => f.followable_id).empty? }

  def block!
    self.update_attribute(:blocked, true)
  end

private
  def init_visit_journal
    VisitJournal.create!(:guest_id => self.follower_id, :user_id => self.followable_id, :last_visited_at => 1.year.ago)
  end

end
