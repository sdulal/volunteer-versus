# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


# Users
User.create!(name:  "Ank Dulla",
             email: "ank@example.com",
             password:              "123456",
             password_confirmation: "123456",
             admin:     true,
             activated: true,
             activated_at: Time.zone.now)

99.times do |n|
  name = Faker::Name.name
  email = "example-#{n+1}@example.com"
  password = "password"
  User.create!(name:  name,
               email: email,
               password:              password,
               password_confirmation: password,
               activated: true,
               activated_at: Time.zone.now)
end

# Groups
10.times do |n|
  name = Faker::Company.name
  description = Faker::Lorem.paragraph
  Group.create!(name: name, description: description)
end

# Memberships
users = User.all
groups = Group.all
prev = 0
groups.each do |group|
  members = users[(prev)...(group.id * 10 - 1)]
  members.each do |member|
    member.join(group)
  end
  prev = group.id * 10
end

# Events
10.times do
  for i in 1..10 do
    name = Faker::Lorem.word
    date = Faker::Date.between(2.days.ago, Date.today + 2.days)
    start_time = Faker::Time.between(2.days.ago, Time.now, :morning)
    start_time = start_time - (start_time.sec).seconds
    end_time = start_time + 2.hours
    location = Faker::Address.street_address
    description = Faker::Lorem.paragraph
    group_id = i
    Event.create!(name: name,
                  date: date,
                  start_time: start_time,
                  end_time: end_time,
                  location: location,
                  description: description,
                  group_id: group_id)
  end
end


# Attendances
groups = Group.all
groups.each do |group|
  events = group.events
  events.each do |event|
    users = group.users.all
    users.each do |user|
      user.attend(event)
    end
  end
end
