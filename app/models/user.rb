class User < ActiveRecord::Base
  acts_as_tagger
  acts_as_followable
  acts_as_follower
  has_many :posts, :dependent => :destroy

  has_many :visit_journals, :dependent => :destroy, :order => 'visit_journals.last_visited_at DESC'
  has_many :users, :through => :visit_journals, :source => :user, :source_type => 'User', :foreign_key => :guest_id
  has_many :guests, :through => :visit_journals, :source => :user, :source_type => 'User', :foreign_key => :user_id

  has_many :taggings, :dependent => :destroy, :order => 'taggings.created_at DESC'
  has_many :tags, :through => :taggings, :uniq => true

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  # attr_accessible :title, :body

  def name
    self.email.split('@').first
  end
  
  # Get the updated posts number from last visited on the following profile page
  def following_posts_count
    count_sql=<<-SQL
        SELECT COUNT(*) AS num FROM posts p
          INNER JOIN follows f ON f.followable_id = p.user_id         
          INNER JOIN visit_journals v ON v.user_id = p.user_id
	  WHERE f.follower_id = #{self.id} AND p.created_at > v.last_visited_at
	GROUP BY p.user_id
    SQL
    User.find_by_sql(count_sql)
  end
end
