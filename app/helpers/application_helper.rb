module ApplicationHelper

  # Returns the full page title generated on a per-page basis, with defaults.
  def full_title(page_title = '')
    base_title = "Ruby on Rails Tutorial Sample Application"
    if page_title.empty?
      base_title
    else
      page_title + " | " + base_title
    end
  end

end
