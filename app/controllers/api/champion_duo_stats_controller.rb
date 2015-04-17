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
  class ChampionDuoStatsController < ApiController
    N_TOP_CHAMPION_DUOS = 20

    def index
      region = params[:region]
      start_time = params[:start_time]
      start_time &&= DateTime.strptime(start_time, "%s")

      kacs = KillAssistCount.arel_table
      stats = Stat.arel_table

      total_kill_assists_column_node = Arel::Nodes::SqlLiteral.new("total_kill_assists")
      total_matches_column_node = Arel::Nodes::SqlLiteral.new("total_matches")
      total_duo_kill_assists_column_node = Arel::Nodes::SqlLiteral.new("total_duo_kill_assists")
      total_duo_matches_column_node = Arel::Nodes::SqlLiteral.new("total_duo_matches")
      subtable = Arel::Table.new("subtable")
      subtable_again = Arel::Table.new("subtable", as: "subtable_again")

      subtable_to_subtable_again = subtable.create_join(
          subtable_again,
          subtable.create_on(
              (subtable[:assister_id].eq subtable_again[:killer_id])
                  .and((subtable[:killer_id].eq subtable_again[:assister_id]))
          )
      )

      if region || start_time
        where_node = kacs.create_true

        where_node = where_node.and(stats[:region].eq region) \
          if region

        where_node = where_node.and(stats[:start_time].eq start_time) \
          if start_time

        cte_subquery =
            kacs
                .project(
                    kacs[:killer_id],
                    kacs[:assister_id],
                    (kacs[:value].sum.as total_kill_assists_column_node),
                    (kacs[:n_matches].sum.as total_matches_column_node)
                )
                .join(stats)
                .on(kacs[:stat_id].eq stats[:id])
                .where(where_node)
                .group(kacs[:killer_id], kacs[:assister_id])
      else
        cte_subquery =
            kacs
                .project(
                    kacs[:killer_id],
                    kacs[:assister_id],
                    (kacs[:value].sum.as total_kill_assists_column_node),
                    (kacs[:n_matches].sum.as total_matches_column_node)
                )
                .group(kacs[:killer_id], kacs[:assister_id])
      end

      champion_duo_stats =
          KillAssistCount
              .with(subtable.name => cte_subquery)
              .select(
                  subtable[:killer_id],
                  subtable[:assister_id],
                  ((subtable[:total_kill_assists] + subtable_again[:total_kill_assists])
                       .expr.as total_duo_kill_assists_column_node),
                  ((subtable[:total_matches] + subtable_again[:total_matches])
                       .expr.as total_duo_matches_column_node)
              )
              .from(subtable)
              .joins(subtable_to_subtable_again)
              .where(subtable[:killer_id].lt subtable_again[:killer_id]) # Get rid of the symmetric case.
              .order(total_duo_kill_assists_column_node.desc)
              .limit(N_TOP_CHAMPION_DUOS)
              .preload(:killer, :assister)
              .map do |kill_assist_count|
            killer, assister = kill_assist_count.killer, kill_assist_count.assister

            cds = ChampionDuoStat.new

            cds.id = "#{killer.id.to_s}_#{assister.id.to_s}_#{region || "all"}_#{params[:start_time] || "0"}"
            cds.champions = [killer, assister].sort { |lhs, rhs| lhs.name <=> rhs.name }
            cds.n_kill_assists = kill_assist_count.total_duo_kill_assists
            cds.n_matches = kill_assist_count.total_duo_matches

            cds
          end

      render json: champion_duo_stats
    end
  end
end
