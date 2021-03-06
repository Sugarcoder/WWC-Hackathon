module LayoutHelper

  def site_name
    # Change the value below between the quotes.
    "RescuingLeftoverCuisine"
  end

  def site_url
    if Rails.env.production?
      # Place your production URL in the quotes below
      "http://www.rescuingleftovercuisine.org"
    else
      # Our dev & test URL
      "http://127.0.0.1:3000/"
    end
  end

  def meta_author
    # Change the value below between the quotes.
    "Runbai Ma"
  end

  def meta_description
    # Change the value below between the quotes.
    "The mission of Rescuing Leftover Cuisine is to become the world’s most widely used solution for companies and individuals to eliminate food waste in their communities, making food rescue sustainable and universal, and food hunger a thing of the past."
  end

  def meta_keywords
    # Change the value below between the quotes.
    "Add your keywords here"
  end

  # Returns the full title on a per-page basis.
  # No need to change any of this we set page_title and site_name elsewhere.
  def full_title(page_title)
    if page_title.empty?
      site_name
    else
      "#{page_title} | #{site_name}"
    end
  end

end