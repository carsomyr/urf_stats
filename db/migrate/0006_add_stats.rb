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

class AddStats < ActiveRecord::Migration
  def change
    create_table :stats do |t|
      t.string :region, limit: 4, null: false
      t.datetime :start_time, null: false
      t.integer :interval, default: Stat.intervals[:day]

      t.integer :n_matches, null: false
      t.integer :average_duration, null: false
      t.integer :average_n_kills, null: false
      t.integer :average_n_assists, null: false
      t.integer :average_time_first_blood, null: false
      t.integer :average_gold, null: false
      t.integer :average_n_minions_killed, null: false
      t.integer :average_n_dragons, null: false
      t.integer :average_time_first_dragon, null: false
      t.integer :average_n_barons, null: false
      t.integer :average_time_first_baron, null: false

      t.index [:region, :start_time, :interval], unique: true
    end
  end
end
