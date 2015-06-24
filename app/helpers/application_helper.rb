module ApplicationHelper

  # Returns the full title on a per-page basis.
  def full_title(page_title = '')
    base_title = "Volunteer Versus"
    if page_title.empty?
      base_title
    else
      page_title + " | " + base_title
    end
  end

  # Convenience method for getting by id.
  def by_id
    params[:id]
  end
end
