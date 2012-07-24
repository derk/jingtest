class Post < ActiveRecord::Base
  #acts_as_taggable_on :content

  belongs_to :user, :counter_cache => true, :touch => true
  has_one :shadow, :dependent => :destroy, :autosave => true
  belongs_to :parent, :class_name => "Post", :foreign_key => :parent_id
  has_many :children, :class_name => "Post", :foreign_key => :parent_id
  
  attr_accessible :content, :link_url, :parent_id
  # link_url can be set when shadow (child) does not yet exist
  attr_accessor :link_url
  validates :content, :length => {:in => 3..4096}, :presence => true
  validates_associated :user
  validates_associated :shadow 

  validate :create_shadow_if_needed, :on => :create, :unless => Proc.new { |post| post.shadow.present? }
  
  after_save :create_tags
  after_destroy :delete_tags

  scope :children, :condtions

  def increment_view_count
    begin
      self.class.record_timestamps = false
      self.increment!( :view_count )
    rescue
      # do nothing
    ensure
      self.class.record_timestamps = true
    end
  end

protected  
    # If child_id is not set, then link_url is used to find/create a Shadow and set the shadow_id
    def create_shadow_if_needed
      if self.link_url.present?
        self.shadow = Shadow.special_find_or_create_by_web_url( self.link_url )
        if( self.shadow.errors.empty? )
          write_attribute(:shadow_id, self.shadow.id)
          return true
        else
          errors.add_to_base( self.shadow.errors.full_messages.to_sentence )
          return false
        end
      else
        errors.add(:link_url, "can't be blank" )
        return false 
      end
    end

    def create_tags
      tag_ids = []
        
      matches = self.content.to_s.scan(/#([A-Z0-9a-z\-\_]+)/)
      matches.each do |content_tag|
        tag = Tag.find_or_create_with_like_by_name content_tag.first
        unless tag.nil?
          tag_ids << tag.id
          new_tag = Tagging.new(:tag_id => tag.id, :taggable => self, :user => self.user)
          if new_tag.valid?
            new_tag.save     
          end
        end
      end
      Tagging.update_by_user_id_and_tag_ids(self.user_id, tag_ids) unless tag_ids.empty?
      true
    end
    
    def delete_tags
      Tagging.delete_by_user_id_and_post_id(self.user_id, self.id)
    end
end
