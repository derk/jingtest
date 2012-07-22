class Shadow < ActiveRecord::Base
  validates :web_url, :length => {:maximum => 1024}, :if => Proc.new { |p| p.web_url.present? }
  validates :web_url, :uniqueness => true, :if => Proc.new { |p| p.web_url.present? }
  
  # Provide alternative to the dynamic finder "find_or_create_by_web_url". Needed so we can apply the special text tranformation.
  def self.special_find_or_create_by_web_url( url_string )
    clean_url = url_string.strip
    clean_url = clean_url.downcase.match('https?://').nil? ? ('http://' + clean_url) : clean_url
    self.find_or_create_by_web_url( clean_url ) unless clean_url.blank?
  end
end
