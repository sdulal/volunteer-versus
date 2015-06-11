class StaticPagesController < ApplicationController
  def home
    if logged_in?
      # Show user's stats and events coming up
      redirect_to current_user
    end
  end

  def about
  end
end
