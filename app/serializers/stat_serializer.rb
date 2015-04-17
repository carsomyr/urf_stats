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

class StatSerializer < ActiveModel::Serializer
  attributes :id
  attributes :n_matches
  attributes :total_duration
  attributes :total_kills
  attributes :total_assists
  attributes :n_first_blood_games
  attributes :total_time_first_blood
  attributes :total_gold
  attributes :total_minions_killed
  attributes :total_champion_level
  attributes :total_dragons
  attributes :n_first_dragon_games
  attributes :total_time_first_dragon
  attributes :total_barons
  attributes :n_first_baron_games
  attributes :total_time_first_baron
end
