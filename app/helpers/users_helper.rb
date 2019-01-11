module UsersHelper

  # Returns the Gravatar picture HTML for the given user.
  def gravatar_for(user, size: 80)
    gravatar_id = Digest::MD5::hexdigest(user.email.squish.downcase)
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}"
    image_tag(gravatar_url, alt: '[' + user.name + ']', class: "gravatar")
  end
end
