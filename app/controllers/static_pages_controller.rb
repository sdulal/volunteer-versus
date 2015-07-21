class StaticPagesController < ApplicationController
  def home
    # Show user's stats, upcoming events and groups if logged in.
    if logged_in?
      @upcoming_events = current_user.events
                .where(['date >= ?', Date.today]).paginate(page: params[:page])
      @recently_credited = []
      current_user.attendances.where(checked: true).first(5).each do |attendance|
        @recently_credited << attendance.event
      end
      @groups = current_user.groups.paginate(page: params[:page])
    end
  end

  def about
  end

  def contact
  end
end
