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

class AddNotNullConstraints < ActiveRecord::Migration
  def change
    change_column :challenge_bucket_counters, :region, :string, limit: 4, null: false
    change_column :challenge_bucket_counters, :bucket_time, :datetime, null: false
    change_column :riot_api_matches, :region, :string, limit: 4, null: false
    change_column :riot_api_matches, :match_id, :integer, limit: 8, null: false
  end
end
