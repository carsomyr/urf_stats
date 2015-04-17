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
  class ChampionLaneStatsController < ApiController
    N_TOP_LANERS = 5

    LANE_VALUE_TYPES = [
        "CHAMPION_LANE_TOP",
        "CHAMPION_LANE_JUNGLE",
        "CHAMPION_LANE_MIDDLE",
        "CHAMPION_LANE_BOTTOM"
    ]

    LANE_VALUE_TYPE_PATTERN = Regexp.new("\\ACHAMPION_LANE_(.*)\\z")

    def index
      region = params[:region]
      start_time = params[:start_time]
      start_time &&= DateTime.strptime(start_time, "%s")

      eis = EntityInteger.arel_table
      ses = Riot::Api::StaticEntity.arel_table
      stats = Stat.arel_table

      where_node = eis.create_true

      if region || start_time
        eis_to_stats_node = eis.create_join(
            stats,
            eis.create_on(eis[:stat_id].eq stats[:id])
        )

        where_node = where_node.and(stats[:region].eq region) \
          if region

        where_node = where_node.and(stats[:start_time].eq start_time) \
          if start_time
      else
        eis_to_stats_node = nil
      end

      total_column_node = Arel::Nodes::SqlLiteral.new("total")

      champion_lanes_by_lane_type = Hash[LANE_VALUE_TYPES.zip(LANE_VALUE_TYPES.size.times.map { [] })]
      laner_ids = Set.new
      laner_count = 0

      EntityInteger
          .select(eis[:entity_id], eis[:value_type], (eis[:value].sum.as total_column_node))
          .joins(eis_to_stats_node)
          .where(where_node.and(eis[:value_type].in LANE_VALUE_TYPES))
          .group(eis[:entity_id], eis[:value_type])
          .order(total_column_node.desc)
          .each do |champion_lane|
        champion_lanes = champion_lanes_by_lane_type[champion_lane.value_type]

        if champion_lanes.size < N_TOP_LANERS && laner_ids.add?(champion_lane.entity_id)
          champion_lanes.push(champion_lane)
          laner_count += 1

          # Break out because we know that further processing is impossible.
          break \
            if laner_count == N_TOP_LANERS * LANE_VALUE_TYPES.size
        end
      end

      champions_by_champion_id = Hash[
          Riot::Api::Champion
              .where(ses[:id].in laner_ids)
              .map do |champion|
            [champion.id, champion]
          end
      ]

      champion_lane_stats = LANE_VALUE_TYPES.map do |lane_value_type|
        lane_type = LANE_VALUE_TYPE_PATTERN.match(lane_value_type)[1].downcase

        cls = ChampionLaneStat.new

        cls.id = "lane_#{lane_type}_#{region || "all"}_#{params[:start_time] || "0"}"
        cls.lane_type = lane_type

        cls.champions = champion_lanes_by_lane_type[lane_value_type].map do |champion_lane|
          champions_by_champion_id[champion_lane.entity_id]
        end

        cls
      end

      render json: champion_lane_stats
    end
  end
end
