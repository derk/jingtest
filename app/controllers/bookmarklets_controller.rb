class BookmarkletsController < ApplicationController
  before_filter :setup
  before_filter :require_no_user, :only => [:login, :do_login]
  before_filter :require_user,    :except => [:jijing_bookmarklet, :login, :do_login]
  skip_before_filter :verify_authenticity_token

  def jijing_bookmarklet
    respond_to { |format| format.js }
  end

  def login    
    @user_session = UserSession.new
  end
  
  def do_login
    @user_session = UserSession.new( params[:user_session] )
    
    respond_to do |format|
      unless @user_session.save
        format.js do
          render :update do |page|
            page[:bookmarklets_login_form].reset
            page[:login_feedback].show            
          end
        end
      else
        format.js do
          render :update do |page|
            page.redirect_to :action => :new_post
          end
        end
      end
    end
  end

  def new_post
    @post = Post.new
  end

  def create_post
    @post = current_user.posts.build(params[:post])
  end

private
  
  def require_user
    unless current_user
      redirect_to :action => "login"
      return false
    end
  end
  
  # user must NOT be logged in
  def require_no_user
    if current_user
      current_user_session.destroy
      redirect_to :action => "login"
      return false
    end
  end
  
  # url and title of page user is on when he clicked the bookmarklet
  def setup
    @pg_url   = params[:link_url] || ""
    @pg_title = params[:page_title] || ""
    @pg_descr = params[:page_descr] || ""
  end
end
