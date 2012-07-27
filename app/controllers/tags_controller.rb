#require 'will_paginate/array'
class TagsController < ApplicationController
  def show
    items_per_page = 10
    tagname = params[:id].present? ? params[:id].downcase : ""
    @tag = Tag.find(:first, :conditions => ["LOWER(name) like ?", tagname]) || raise(ActiveRecord::RecordNotFound, "Couldn't find tag #{tagname}")
    @related_tags = Tag.related_tags(@tag.id).first(5)
    @related_users = @tag.post_users.limit(10)

    #username = params[:user_id].present? ? params[:user_id].downcase : ""
    username = params[:user_id].present? ? params[:user_id] : ""
    unless username.blank?
      @user = User.find(username)
      @posts = @tag.posts.paginate :page => params[:page], :per_page => items_per_page, :conditions => "taggings.user_id = #{@user.id}"
      @total_num = @tag.posts.size
    else
      @ShowTagAllActive = 1
      @posts = @tag.posts.paginate :page => params[:page], :per_page => items_per_page
      @total_num = @posts.total_entries
    end
  end
end
