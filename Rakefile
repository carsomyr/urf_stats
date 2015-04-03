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
require Pathname.new("../config/application").expand_path(__FILE__)

Rails.application.load_tasks

# Extremely important: Stage JavaScript dependencies before RequireJS' own staging process.
task "requirejs:precompile:prepare_source" => ["bower:install:deployment"]

# We use RSpec; remove Test::Unit tasks.
["test",
 "test:all",
 "test:all:db"].each do |task_name|
  Rake::Task[task_name].clear
end
