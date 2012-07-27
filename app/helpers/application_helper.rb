module ApplicationHelper
  def full_image_url(*args)
    home_url + image_path(*args)
  end

  def standard_date_text( datetime )
    datetime.strftime("%d/%m/%Y")
  end

  #mark_required(@user, :email)
  def mark_required(object, attribute)
    "*" if object.class.validators_on(attribute).map(&:class).include? ActiveModel::Validations::PresenceValidator
  end

  def recognize_stamps_as_links(content, options={})
    tags = []
    unless options[:user].nil?
      content.gsub(/#[A-Z0-9a-z\-\_]+/){|stamp| tags << link_to(stamp, tag_by_user_url(stamp[1,stamp.length], options[:user]), :class => 'green', :target => options[:target] || "_self") }
    else
      content.gsub(/#[A-Z0-9a-z\-\_]+/){|stamp| tags << link_to(stamp, tag_url(stamp[1,stamp.length]), :class => 'green', :target => options[:target] || "_self") }      
    end
    return tags.join(' ').html_safe
  end

  def string_from(text, options = {})
    text = text.dup

    length_with_room_for_omission = options[:length] - options[:omission].mb_chars.length
    chars = text.mb_chars
    stop = options[:separator] ?
     (chars.rindex(options[:separator].mb_chars, length_with_room_for_omission) || length_with_room_for_omission) : length_with_room_for_omission

    (chars.length > options[:length] ? chars[stop..-1]  : '').to_s
  end

  def delete_by(object)
    if user_signed_in? && current_user.name == "derk"
      link_to 'delete', object, method: :delete, data: { confirm: 'Are you sure?' }
    end
  end
end
