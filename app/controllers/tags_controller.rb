#require 'will_paginate/array'
class TagsController < ApplicationController
  def show
    items_per_page = 10
    tagname = params[:id].present? ? params[:id].downcase : ""
    @tag = Tag.find(:first, :conditions => ["LOWER(name) like ?", tagname]) || raise(ActiveRecord::RecordNotFound, "Couldn't find tag #{tagname}")
    @related_tags = Tag.related_tags(@tag.id)

    username = params[:user_id].present? ? params[:user_id].downcase : ""
    unless username.blank?
      @user = User.find_with_username!(username)
      if current_user == @user
        @posts = @tag.posts.paginate :page => params[:page], :per_page => items_per_page, :conditions => "taggings.user_id = #{@user.id}"
      else
        @posts = @tag.posts.paginate :page => params[:page], :per_page => items_per_page
      end
    else
      @ShowTagAllActive = 1
      @posts = @tag.posts.paginate :page => params[:page], :per_page => items_per_page
    end
  end
end
