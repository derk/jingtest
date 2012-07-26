class ProfilesController < ApplicationController
  before_filter :find_user
  before_filter :authenticate_user!, :except => [:show]

  def show    
    @posts = Post.paginate :per_page => 10, :page => params[:page], :conditions => "posts.user_id = #{@user.id}", :order => "created_at DESC"
    @tags = Tag.by_self(@user.id).first(5)
    @following = @user.all_following

    if user_signed_in? and current_user!= @user
      journal = VisitJournal.where(:guest_id => current_user.id, :user_id => @user.id).first
      if journal
	journal.update_attribute(:last_visited_at, Time.new) if journal.last_visited_at > 3.minutes.ago 
      else
	VisitJournal.create!(:guest_id => current_user.id, :user_id => @user.id, :last_visited_at => Time.new)
      end
    end    
  end

  def follow
    current_user.follow(@user)
    respond_to do |format|
      format.js
    end
  end

  def unfollow
    current_user.stop_following(@user)
    respond_to do |format|
      format.js
    end
  end

private
  def find_user
    @user = User.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    logger.error("Oops, can't find user with id = #{params[:id]}")
  end
end
