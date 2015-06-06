class StaticPagesController < ApplicationController
  def home
    if logged_in?
      # Show user's stats and events coming up
    end
  end

  def about
  end
end
