Volunteer Versus
================

Volunteer Versus is an online application that allows volunteering organizations to better manage hours. Club officers simply check off members for events so that members can get hours credited. Through a leaderboard system, users and groups are able to see exactly who volunteers the most, which club has the most members, etc.

This application uses the Ruby on Rails framework (4.2.0).

## Setup

### Installation

Install Rails. Information on how to install Rails can be found [here.](http://rubyonrails.org/download/)
Make sure that you have sqlite3 installed. This can be accomplished with [precompiled binaries.](http://www.sqlite.org/download.html) Mac users can use [Homebrew](http://brew.sh) to install using ``brew install sqlite``.

Clone this repository and go into the folder:

```
git clone https://github.com/sdulal/volunteer-versus.git
cd volunteer-versus
```

Once in the folder, install all needed gems using ``bundle install``.

### Database Setup

Run the database migration tools and populate the site with seed data.

```ruby
rake db:migrate
rake db:seed
```

### Using the Application

#### Running Locally

Run either one of the two commands to get the server up and running!

```ruby
rails server                  // Default port listed in terminal
rails server -p PORT_NUMBER   // Pick the port to run server on
```

You can close the server using Ctrl-C.

#### Running Tests

Run tests with ``rake test``. As of this writing, ``Test::Unit`` is being used.
Measures of code coverage, given by the `simplecov` gem (installed already due to the Installation step) will be found in the coverage folder. As of this writing, the application is [well tested.](https://cloud.githubusercontent.com/assets/7890649/9156233/6cfb0608-3e87-11e5-9190-63ad6ba01f85.png)

## Making a contribution

There's always something that can be done to help improve the app! Feel free to report an issue if something's up. No problem in doing a pull request, either.

## License

The project is released under the [Apache License, Version 2.0.](LICENSE.md)

> Copyright 2015 Shafqat Dulal
>
> Licensed under the Apache License, Version 2.0 (the "License");
> you may not use this file except in compliance with the License.
> You may obtain a copy of the License at
>
>  http://www.apache.org/licenses/LICENSE-2.0
>
> Unless required by applicable law or agreed to in writing, software
> distributed under the License is distributed on an "AS IS" BASIS,
> WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
> See the License for the specific language governing permissions and
> limitations under the License.
