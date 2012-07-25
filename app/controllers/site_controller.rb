class SiteController < ApplicationController
  def index
  end

  def following
  end

  def explore
    @posts = Post.paginate :per_page => 10, :page => params[:page], :order => "created_at DESC"
    @tags = Tag.top_weighted(10)
  end

  def about
  end

  def help
  end

  def tools
  end

  def blog
  end
end
