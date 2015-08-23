module ApplicationHelper
  include ActionView::Helpers::NumberHelper

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

  # Getting the formatted version that views of the application use for decimal
  # numbers.
  def formatted_number(number)
    number_with_precision(number, precision: 2, strip_insignificant_zeros: true)
  end

  # Getting the formatted version that views of the application use for days.
  def formatted_day(date)
    date.strftime("%B %d, %Y")
  end

  # Getting the formatted version that views of the application use for times.
  def formatted_time(time)
    time.strftime("%l:%M %p")
  end
end
