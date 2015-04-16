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
  class ChampionStatsController < ApiController
    N_TOP_CHAMPIONS = 20

    CHAMPION_VALUE_TYPES = [
        "CHAMPION_KILL",
        "CHAMPION_DEATH",
        "CHAMPION_ASSIST",
        "CHAMPION_PICK",
        "CHAMPION_BAN",
        "CHAMPION_WIN"
    ]

    def index
      region = params[:region]
      start_time = params[:start_time]
      start_time &&= DateTime.strptime(start_time, "%s")
      sort_by = params[:sort_by] || "wins-picks"
      sort_direction = params[:sort_direction] || "descending"

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

      kdapbws_by_champion_id = Hash.new { |hash, key| hash[key] = [0, 0, 0, 0, 0, 0] }

      EntityInteger
          .select(eis[:entity_id], eis[:value_type], (eis[:value].sum.as total_column_node))
          .joins(eis_to_stats_node)
          .where(where_node.and(eis[:value_type].in CHAMPION_VALUE_TYPES))
          .group(eis[:entity_id], eis[:value_type])
          .each do |champion_kdapbw|
        champion_id = champion_kdapbw.entity_id

        # PostgreSQL `bigint` gets converted into Ruby's `BigDecimal`.
        total = champion_kdapbw.total.to_i

        kdapbw = kdapbws_by_champion_id[champion_id]
        kdapbw[CHAMPION_VALUE_TYPES.find_index(champion_kdapbw.value_type)] += total
      end

      case sort_by
        when "kills"
          sort_proc = Proc.new do |lhs, rhs|
            _, lhs_kdapbw = *lhs
            _, rhs_kdapbw = *rhs

            lhs_kdapbw[0] <=> rhs_kdapbw[0]
          end
        when "deaths"
          sort_proc = Proc.new do |lhs, rhs|
            _, lhs_kdapbw = *lhs
            _, rhs_kdapbw = *rhs

            lhs_kdapbw[1] <=> rhs_kdapbw[1]
          end
        when "assists"
          sort_proc = Proc.new do |lhs, rhs|
            _, lhs_kdapbw = *lhs
            _, rhs_kdapbw = *rhs

            lhs_kdapbw[2] <=> rhs_kdapbw[2]
          end
        when "kills-deaths"
          sort_proc = Proc.new do |lhs, rhs|
            _, lhs_kdapbw = *lhs
            _, rhs_kdapbw = *rhs

            # Pad values by 1 to avoid 0 divide.
            (lhs_kdapbw[0] + 1).to_f / (lhs_kdapbw[1] + 1) <=> (rhs_kdapbw[0] + 1).to_f / (rhs_kdapbw[1] + 1)
          end
        when "picks"
          sort_proc = Proc.new do |lhs, rhs|
            _, lhs_kdapbw = *lhs
            _, rhs_kdapbw = *rhs

            lhs_kdapbw[3] <=> rhs_kdapbw[3]
          end
        when "bans"
          sort_proc = Proc.new do |lhs, rhs|
            _, lhs_kdapbw = *lhs
            _, rhs_kdapbw = *rhs

            lhs_kdapbw[4] <=> rhs_kdapbw[4]
          end
        when "wins"
          sort_proc = Proc.new do |lhs, rhs|
            _, lhs_kdapbw = *lhs
            _, rhs_kdapbw = *rhs

            lhs_kdapbw[5] <=> rhs_kdapbw[5]
          end
        when "wins-picks"
          sort_proc = Proc.new do |lhs, rhs|
            _, lhs_kdapbw = *lhs
            _, rhs_kdapbw = *rhs

            # Pad values by 1 to avoid 0 divide.
            (lhs_kdapbw[5] + 1).to_f / (lhs_kdapbw[3] + 1) <=> (rhs_kdapbw[5] + 1).to_f / (rhs_kdapbw[3] + 1)
          end
        else
          raise ArgumentError, "Invalid sort criterion #{sort_by.dump}"
      end

      case sort_direction
        when "descending"
          sort_signum = -1
        when "ascending"
          sort_signum = +1
        else
          raise ArgumentError, "Invalid sort direction #{sort_direction.dump}"
      end

      kdapbw_entries = kdapbws_by_champion_id.each_pair.sort do |lhs, rhs|
        sort_signum * sort_proc.call(lhs, rhs)
      end.first(N_TOP_CHAMPIONS)

      champions_by_champion_id = Hash[
          Riot::Api::Champion.where(ses[:id].in kdapbw_entries.map { |e| e[0] }).map do |champion|
            [champion.id, champion]
          end
      ]

      total_matches =
          # Convert to an array to prevent `first` from ordering by `id`.
          Stat
              .select(stats[:n_matches].sum.as total_column_node)
              .where(where_node)
              .to_a.first.total

      champion_stats = kdapbw_entries.map do |champion_id, kdapbw|
        cs = ChampionStat.new

        cs.id = "#{champion_id.to_s}_#{region || "all"}_#{params[:start_time] || "0"}_#{sort_by}_#{sort_direction}"
        cs.champion = champions_by_champion_id[champion_id]
        cs.n_kills, cs.n_deaths, cs.n_assists, cs.n_picks, cs.n_bans, cs.n_wins = *kdapbw
        cs.n_matches = total_matches

        cs
      end

      render json: champion_stats
    end
  end
end
