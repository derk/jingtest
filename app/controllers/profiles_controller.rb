class ProfilesController < ApplicationController
  def show
    @user = User.find(params[:id])
    @posts = Post.paginate :per_page => 10, :page => params[:page], :conditions => "posts.user_id = #{@user.id}", :order => "created_at DESC"
  end
end
