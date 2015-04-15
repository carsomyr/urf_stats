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

class Stat < ActiveRecord::Base
  enum interval: [:minute, :hour, :day]

  validates :region, presence: true, uniqueness: {scope: [:start_time, :interval]}
  validates :start_time, presence: true, stat_start_time: true
  validates :interval, presence: true

  validates :n_matches, presence: true
  validates :total_duration, presence: true
  validates :total_kills, presence: true
  validates :total_assists, presence: true
  validates :n_first_blood_games, presence: true
  validates :total_time_first_blood, presence: true
  validates :total_gold, presence: true
  validates :total_minions_killed, presence: true
  validates :total_champion_level, presence: true
  validates :total_dragons, presence: true
  validates :n_first_dragon_games, presence: true
  validates :total_time_first_dragon, presence: true
  validates :total_barons, presence: true
  validates :n_first_baron_games, presence: true
  validates :total_time_first_baron, presence: true
end
