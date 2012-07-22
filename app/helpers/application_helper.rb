module ApplicationHelper
  def full_image_url(*args)
    home_url + image_path(*args)
  end

  #mark_required(@user, :email)
  def mark_required(object, attribute)
    "*" if object.class.validators_on(attribute).map(&:class).include? ActiveModel::Validations::PresenceValidator
  end

  def recognize_stamps_as_links(content, options={})
    unless options[:user].nil?
      content.gsub(/#[A-Z0-9a-z\-\_]+/){|stamp| link_to stamp, tag_by_user_url(stamp[1,stamp.length], options[:user]), :class => 'green'}
    else
      content.gsub(/#[A-Z0-9a-z\-\_]+/){|stamp| link_to stamp, tag_url(stamp[1,stamp.length]), :class => 'green'}      
    end
  end
end
