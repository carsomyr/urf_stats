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
  class UselessRuneMasteryStatsController < ApiController
    USELESS_RUNE_MASTERY_VALUE_TYPES = [
        "USELESS_RUNE",
        "USELESS_MASTERY"
    ]

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

      rune_mastery_occurrences =
          EntityInteger
              .select(eis[:entity_id], eis[:value_type], (eis[:value].sum.as total_column_node))
              .joins(eis_to_stats_node)
              .where(where_node.and(eis[:value_type].in USELESS_RUNE_MASTERY_VALUE_TYPES))
              .group(eis[:entity_id], eis[:value_type])
              .order(total_column_node.desc)

      rune_ids, mastery_ids =
          *USELESS_RUNE_MASTERY_VALUE_TYPES.map do |value_type|
            rune_mastery_occurrences.select do |rune_mastery_occurrence|
              rune_mastery_occurrence.value_type == value_type
            end.map do |rune_mastery_occurrence|
              rune_mastery_occurrence.entity_id
            end
          end

      runes_by_rune_id = Hash[
          Riot::Api::Rune.where(ses[:id].in rune_ids).map do |rune|
            [rune.id, rune]
          end
      ]

      masteries_by_mastery_id = Hash[
          Riot::Api::Mastery.where(ses[:id].in mastery_ids).map do |mastery|
            [mastery.id, mastery]
          end
      ]

      total_matches =
          # Convert to an array to prevent `first` from ordering by `id`.
          Stat
              .select(stats[:n_matches].sum.as total_column_node)
              .where(where_node)
              .to_a.first.total

      useless_rune_mastery_stats = rune_mastery_occurrences.map do |rune_mastery_occurrence|
        urms = UselessRuneMasteryStat.new
        entity_id = rune_mastery_occurrence.entity_id

        urms.id = "#{entity_id.to_s}_#{region || "all"}_#{params[:start_time] || "0"}"
        urms.content = runes_by_rune_id[entity_id] || masteries_by_mastery_id[entity_id]

        # Somehow the total is a `BigDecimal`?
        urms.n_occurrences = rune_mastery_occurrence.total.to_i
        urms.n_participants = 10 * total_matches

        urms
      end

      render json: useless_rune_mastery_stats
    end
  end
end
