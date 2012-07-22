class Tagging < ActiveRecord::Base #:nodoc:
  belongs_to :tag
  belongs_to :taggable, :polymorphic => true
  belongs_to :user
  
  validates_associated :user, :taggable, :tag
  attr_accessible :tag_id, :taggable, :user
  
  validates_uniqueness_of :tag_id, :scope => [:taggable_id,:taggable_type,:user_id]
  
  scope :recent, :group => "taggings.taggable_type, taggings.taggable_id", :order => "taggings.created_at DESC, taggings.id DESC"
  
  def after_destroy
    if Tag.destroy_unused
      if tag.taggings.count.zero?
        tag.destroy
      end
    end
  end

 class << self
   def related_bag_ids_by_tag_name(name)
      related_sql=<<-SQL
        SELECT DISTINCT taggable_id FROM taggings INNER JOIN tags ON tags.id = taggings.tag_id 
        WHERE LOWER(tags.name) LIKE '%#{name.downcase}%' AND taggable_type = 'Post'
      SQL
      
      find_by_sql(related_sql).map(&:taggable_id)
    end

    def update_by_user_id_and_tag_ids(user_id, tag_ids)
      find_by_sql("DELETE FROM taggings WHERE user_id = #{user_id} AND tag_id NOT IN (#{tag_ids.join(',')}) AND taggable_type = 'Post'")
    end

    def delete_by_user_id_and_post_id(user_id, post_id)
      find_by_sql("DELETE FROM taggings WHERE user_id = #{user_id} AND taggable_id != #{post_id} AND taggable_type = 'Post'")
    end
 end
end
