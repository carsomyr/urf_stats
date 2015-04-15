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

class ChangeStatsAveragesToTotals < ActiveRecord::Migration
  def change
    change_table :stats do |t|
      t.rename :average_duration, :total_duration
      t.rename :average_n_kills, :total_kills
      t.rename :average_n_assists, :total_assists
      t.rename :average_time_first_blood, :total_time_first_blood
      t.rename :average_gold, :total_gold
      t.rename :average_n_minions_killed, :total_minions_killed
      t.rename :average_champion_level, :total_champion_level
      t.rename :average_n_dragons, :total_dragons
      t.rename :average_time_first_dragon, :total_time_first_dragon
      t.rename :average_n_barons, :total_barons
      t.rename :average_time_first_baron, :total_time_first_baron

      t.integer :n_first_blood_games, null: false
      t.integer :n_first_dragon_games, null: false
      t.integer :n_first_baron_games, null: false
    end

    change_column :stats, :total_duration, :integer, limit: 8, null: false
    change_column :stats, :total_time_first_blood, :integer, limit: 8, null: false
    change_column :stats, :total_gold, :integer, limit: 8, null: false
    change_column :stats, :total_time_first_dragon, :integer, limit: 8, null: false
    change_column :stats, :total_time_first_baron, :integer, limit: 8, null: false
  end
end
