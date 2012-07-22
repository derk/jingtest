class Tag < ActiveRecord::Base
  TAGS_SIZE = 5 # default Num shown on "stambs on Post"
  MAX_TAGS_SIZE = 20 # default Num shown at "explore" page
  has_many :taggings, :dependent => :destroy, :order => "taggings.created_at DESC"
  has_many :users, :through => :taggings
  has_many :post_users, :through => :taggings, :source => :user, :conditions => ["taggings.taggable_type = 'Post'"], :order => "taggings.created_at DESC"
  has_many :taggable, :as => :taggable, :class_name => "Tagging"
  has_many :posts, :through => :taggings,
                  :source => :taggable, 
                  :source_type => 'Post',
                  :uniq => true

  validates_presence_of :name,  :message => "Tag can't be blank"
  validates_uniqueness_of :name, :case_sensitive => false
  validates_length_of :name, :within => 1..20, :too_short => "A tag must be atlest 1 character", :too_long => "Your tag is over 20 characters.  It should be shorter."
  validates_format_of :name, :with => /^[A-Za-z0-9_-]+$/,  :message => "Can only contain letters, numbers, _ and -"
  
  attr_accessible :name
  attr_accessor :tagger
  
  def to_param  # overridden
    name
  end
      
  # LIKE is used for cross-database case-insensitivity
  def self.find_or_create_with_like_by_name(name)
    find(:first, :conditions => ["LOWER(name) LIKE ?", name.downcase]) || create(:name => name)
  end
  
  def ==(object)
    super || (object.is_a?(Tag) && name == object.name)
  end
  
  def to_s
    name
  end
  
  def count
    read_attribute(:count).to_i
  end
  
  def weight
    if has_attribute? :weight
      read_attribute(:weight).to_i
    else
      0
    end
  end

:protected 
  class << self
    def by_self(user_id, is_owner=true)
      if is_owner
        Rails.cache.fetch("user_#{user_id}_owner_tags", :expires_in => 30.minutes){ 
          self_sql=<<-SQL
            SELECT tags.*, COUNT(*) AS weight, MAX(taggings.created_at) AS latest_updated_at FROM tags 
              INNER JOIN taggings ON tags.id = taggings.tag_id 
              INNER JOIN posts ON posts.id = taggings.taggable_id 
              WHERE taggings.user_id = #{user_id} AND posts.user_id = #{user_id} 
              GROUP BY tags.id, tags.name 
            ORDER BY weight DESC, latest_updated_at DESC
          SQL
          find_by_sql(self_sql)
        }
      else
        Rails.cache.fetch("user_#{user_id}_guest_tags", :expires_in => 30.minutes){ 
          self_sql=<<-SQL
            SELECT tags.*, COUNT(*) AS weight, MAX(taggings.created_at) AS latest_updated_at FROM tags 
              INNER JOIN taggings ON tags.id = taggings.tag_id 
              INNER JOIN posts ON posts.id = taggings.taggable_id 
              WHERE taggings.user_id = #{user_id} AND posts.user_id = #{user_id} GROUP BY tags.id, tags.name 
            ORDER BY weight DESC, latest_updated_at DESC
          SQL
          find_by_sql(self_sql)
        }
      end
    end

    def by_others(user_id)
      Rails.cache.fetch("user_#{user_id}_others_tags", :expires_in => 30.minutes){
        others_sql=<<-SQL
          SELECT tags.*, COUNT(*) AS weight, MAX(taggings.created_at) AS latest_updated_at FROM tags
            INNER JOIN taggings ON tags.id = taggings.tag_id 
            INNER JOIN bags ON posts.id = taggings.taggable_id 
            WHERE taggings.user_id = #{user_id} AND posts.user_id != #{user_id} 
            GROUP BY tags.id, tags.name
          ORDER BY weight DESC, latest_updated_at DESC
        SQL
        find_by_sql(others_sql)
      }
    end

    def top_weighted(num = MAX_TAGS_SIZE)
      weight_sql=<<-SQL
        SELECT tags.*,  MAX(tgs.newest) AS latest_updated_at, COUNT(*) AS weight 
				  FROM tags INNER JOIN (SELECT tag_id, taggings.taggable_id, newest FROM taggings 
				  INNER JOIN (SELECT taggable_id, MAX(created_at) AS newest FROM taggings WHERE taggable_type = 'Post' GROUP BY taggable_id, tag_id) ts 
          ON ts.newest = taggings.created_at AND ts.taggable_id = taggings.taggable_id ) tgs 
				  ON tgs.tag_id = tags.id INNER JOIN posts ON posts.id = tgs.taggable_id 				  
				  GROUP BY tags.id, tags.name 
				ORDER BY weight DESC, latest_updated_at DESC LIMIT #{num}
      SQL
      find_by_sql(weight_sql)
    end

    def related_tags(id)
      related_sql=<<-SQL
        SELECT tags.*,  MAX(created_at) AS latest_updated_at, count(*) as weight FROM tags 
          INNER JOIN ( SELECT tag_id, taggings.taggable_id, created_at FROM taggings INNER JOIN 
          ( SELECT DISTINCT taggable_id FROM taggings WHERE taggable_type = 'Post' and tag_id = #{id} ) t 
          ON t.taggable_id = taggings.taggable_id ) tgs ON tgs.tag_id = tags.id 
          WHERE tag_id != #{id} 
        GROUP BY tags.id, tags.name ORDER BY weight DESC, latest_updated_at DESC
      SQL
      
      find_by_sql(related_sql)
    end

    def post_tags(options = {})
      conditions = "posts.user_id = #{options[:user_id]}"
      bag_sql=<<-SQL
        SELECT tags.*, COUNT(*) AS weight FROM tags 
          INNER JOIN (SELECT DISTINCT taggable_id, tag_id FROM taggings 
          INNER JOIN posts ON posts.id = taggings.taggable_id WHERE #{conditions}) tgs ON tgs.tag_id = tags.id 
        GROUP BY tags.id, tags.name ORDER BY weight DESC
      SQL
    
      find_by_sql(bag_sql)
    end

    # Calculate the tag counts for all tags.
    #  :start_at - Restrict the tags to those created after a certain time
    #  :end_at - Restrict the tags to those created before a certain time
    #  :conditions - A piece of SQL conditions to add to the query
    #  :limit - The maximum number of tags to return
    #  :order - A piece of SQL to order by. Eg 'count desc' or 'taggings.created_at desc'
    #  :at_least - Exclude tags with a frequency less than the given value
    #  :at_most - Exclude tags with a frequency greater than the given value
    def counts(options = {})
      find(:all, options_for_counts(options))
    end
    
    def options_for_counts(options = {})
      options.assert_valid_keys :start_at, :end_at, :group, :conditions, :at_least, :at_most, :order, :limit, :joins
      options = options.dup
      
      start_at = sanitize_sql(["#{Tagging.table_name}.created_at >= ?", options.delete(:start_at)]) if options[:start_at]
      end_at = sanitize_sql(["#{Tagging.table_name}.created_at <= ?", options.delete(:end_at)]) if options[:end_at]
      
      conditions = [
        (sanitize_sql(options.delete(:conditions)) if options[:conditions]),
        start_at,
        end_at
      ].compact
      
      conditions = conditions.join(' AND ') if conditions.any?
      
      joins = ["INNER JOIN #{Tagging.table_name} ON #{Tag.table_name}.id = #{Tagging.table_name}.tag_id"]
      joins << options.delete(:joins) if options[:joins]
      
      at_least  = sanitize_sql(['COUNT(*) >= ?', options.delete(:at_least)]) if options[:at_least]
      at_most   = sanitize_sql(['COUNT(*) <= ?', options.delete(:at_most)]) if options[:at_most]
      having    = [at_least, at_most].compact.join(' AND ')
      group_by  = options[:group] || "#{Tag.table_name}.id, #{Tag.table_name}.name HAVING COUNT(*) > 0"
      group_by << " AND #{having}" unless having.blank?
      
      { :select     => "#{Tag.table_name}.id, #{Tag.table_name}.name, COUNT(*) AS count", 
        :joins      => joins.join(" "),
        :conditions => conditions,
        :group      => group_by
      }.update(options)
    end
  end
end
