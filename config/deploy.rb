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

require "pathname"
require "shellwords"

# Use SSH key forwarding because we assume that the GitHub access keys are in the user's keychain.
set :ssh_options, forward_agent: true

# Provide some information about the rbenv installation. We set the desired rbenv version to `""` to force usage of the
# one set with `rbenv global VERSION`.
set :rbenv_ruby, ""
set :rbenv_path, "/usr/lib/rbenv"

# The application.
set :deploy_to, "/home/ubuntu/apps/application"
set :repo_url, "git@github.com:organization/application"
set :branch, "master"
set :rails_env, "production"

set :linked_files, fetch(:linked_files, []) + ([
                     "action_mailer.yml",
                     "airbrake.yml",
                     "aws.yml",
                     "google_analytics.yml",
                     "secrets.yml"
                 ].map do |filename|
                   (Pathname.new("config") + filename).to_s
                 end)

set :linked_dirs, fetch(:linked_dirs, []) + [
                    "public/system",
                    "vendor/assets/bower_components"
                ]

# Restart Unicorn.
namespace :deploy do
  task :restart do
    on release_roles :all do
      execute "sudo -- service nginx restart"
      execute "sudo -- service sidekiq restart"
      execute "sudo -- service unicorn restart"
    end
  end

  after "deploy", "deploy:restart"
end

# Symlink the pertinent configuration files.
namespace :deploy do
  task :symlink_config do
    on release_roles :all do
      # Link to the public-facing web server directory.
      execute "rm -rf -- #{shared_path.to_s.shellescape}/public/system" \
        " && mkdir -p -- #{shared_path.to_s.shellescape}/public" \
        " && ln -sfn -- /var/www/system #{shared_path.to_s.shellescape}/public/system"
    end
  end

  after "deploy:symlink:shared", "deploy:symlink_config"
end
