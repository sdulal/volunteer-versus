require 'simplecov'
SimpleCov.start 'rails'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'minitest/reporters'
Minitest::Reporters.use!


class ActiveSupport::TestCase
  include ActionView::Helpers::NumberHelper
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Note that application helpers are not available in tests.
  # So, add test helper methods here...

  # Returns true if a test user is logged in.
  def is_logged_in?
    !session[:user_id].nil?
  end

  # Logs in a test user.
  def log_in_as(user, options = {})
    password        = options[:password]    || 'password'
    remember_me     = options[:remember_me] || '1'
    if integration_test?
      post login_path, session: { email:       user.email,
                                  password:    password,
                                  remember_me: remember_me }
    else
      session[:user_id] = user.id
    end
  end

  # Add some random events to a given group.
  def add_n_random_events_to(group, options = { n: 5 })
    options[:n].times do
      name = Faker::Lorem.word
      date = Faker::Date.between(2.days.ago, Date.today + 2.days)
      start_time = Faker::Time.between(2.days.ago, Time.now, :morning)
      start_time = start_time - (start_time.sec).seconds
      end_time = start_time + 2.hours
      location = Faker::Address.street_address
      description = Faker::Lorem.paragraph
      Event.create!(name: name,
                    date: date,
                    start_time: start_time,
                    end_time: end_time,
                    location: location,
                    description: description,
                    group_id: group.id)
    end
  end

  # Getting the formatted version that views of the application use for decimal numbers
  def formatted_number(number)
    number_with_precision(number, precision: 2, strip_insignificant_zeros: true)
  end

  # Getting the formatted version that views of the application use for days
  def formatted_day(date)
    date.strftime("%B %d, %Y")
  end

  # Getting the formatted version that views of the application use for times
  def formatted_time(time)
    time.strftime("%l:%M %p")
  end

  private

    # Returns true inside an integration test.
    def integration_test?
      defined?(post_via_redirect)
    end
end
