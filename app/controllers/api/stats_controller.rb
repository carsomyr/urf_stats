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

module Api
  class StatsController < ApiController
    def index
      region = params[:region]
      start_time = params[:start_time]
      start_time &&= DateTime.strptime(start_time, "%s")

      stats = Stat.arel_table

      where_node = stats.create_true

      if region || start_time
        where_node = where_node.and(stats[:region].eq region) \
          if region

        where_node = where_node.and(stats[:start_time].eq start_time) \
          if start_time
      end

      stat =
          # Convert to an array to prevent `first` from ordering by `id`.
          Stat
              .select(
                  (stats[:n_matches].sum.as "n_matches"),
                  (stats[:total_duration].sum.as "total_duration"),
                  (stats[:total_kills].sum.as "total_kills"),
                  (stats[:total_assists].sum.as "total_assists"),
                  (stats[:n_first_blood_games].sum.as "n_first_blood_games"),
                  (stats[:total_time_first_blood].sum.as "total_time_first_blood"),
                  (stats[:total_gold].sum.as "total_gold"),
                  (stats[:total_minions_killed].sum.as "total_minions_killed"),
                  (stats[:total_champion_level].sum.as "total_champion_level"),
                  (stats[:total_dragons].sum.as "total_dragons"),
                  (stats[:n_first_dragon_games].sum.as "n_first_dragon_games"),
                  (stats[:total_time_first_dragon].sum.as "total_time_first_dragon"),
                  (stats[:total_barons].sum.as "total_barons"),
                  (stats[:n_first_baron_games].sum.as "n_first_baron_games"),
                  (stats[:total_time_first_baron].sum.as "total_time_first_baron")
              )
              .where(where_node)
              .to_a.first

      stat.id = 0

      render json: [stat]
    end
  end
end
