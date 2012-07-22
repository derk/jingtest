class User < ActiveRecord::Base
  acts_as_tagger
  has_many :posts, :dependent => :destroy

  has_many :visit_journals, :foreign_key => :guest_id, :dependent => :destroy, :order => 'visit_journals.last_visited_at DESC'

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
end
