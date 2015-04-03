# -*- coding: utf-8 -*-
#
# Copyright 2015 Roy Liu
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not
# use this file except in compliance with the License. You may obtain a copy of
# the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations under
# the License.

source "https://rubygems.org"

gem "active_model_serializers",
    github: "rails-api/active_model_serializers",
    branch: "0-9-stable"
gem "activerecord-session_store"
gem "acts_as_list"
gem "airbrake"
gem "aws-sdk"
gem "devise"
gem "font-awesome-rails"
gem "haml"
gem "haml-rails"
gem "handlebars-source"
gem "paperclip"
gem "pg"
gem "pundit"
gem "rails", ">= 4.2.1"
gem "sidekiq", ">= 3.3.3"
gem "sidetiq"
gem "sqlite3"
gem "thin"

group :assets do
  gem "bower-rails"
  gem "coffee-rails"
  gem "ember-rails"
  gem "jquery-rails"
  gem "less-rails"
  gem "requirejs-rails",
      github: "jwhitley/requirejs-rails"
  gem "sass-rails"
  gem "therubyracer", platforms: :ruby
  gem "twitter-bootstrap-rails",
      github: "seyhunak/twitter-bootstrap-rails",
      branch: "bootstrap3"
  gem "uglifier"
end

group :development do
  gem "capistrano"
  gem "capistrano-bundler"
  gem "capistrano-rails"
  gem "capistrano-rbenv"
end

group :production do
  gem "unicorn"
end

group :test do
  gem "rspec-rails"
end
