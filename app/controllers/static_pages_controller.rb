class StaticPagesController < ApplicationController
  def home
    if logged_in?
      # Show user's stats and events coming up
      # Ex. 'You have 5 events coming up'
      # Ex. 'Link to my groups'
      redirect_to current_user
    end
  end

  def about
  end
end
