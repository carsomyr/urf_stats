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

require "urf_stats/accumulator"

module UrfStats
  class ChampionAccumulator < Accumulator
    def initialize(parent)
      super(parent)

      @champion_pick_counts = {}
      @champion_pick_counts.default = 0

      @champion_ban_counts = {}
      @champion_ban_counts.default = 0

      @champion_win_counts = {}
      @champion_win_counts.default = 0

      @champion_kill_counts = {}
      @champion_kill_counts.default = 0

      @champion_death_counts = {}
      @champion_death_counts.default = 0

      @champion_assist_counts = {}
      @champion_assist_counts.default = 0

      # Keys are tuples of the form (lane type, champion id).
      @lane_champion_counts = {}
      @lane_champion_counts.default = 0

      # Keys are tuples of the form (killer champion id, assister champion id); values are tuples of the form (number of
      # kill-assists, number of matches).
      @kill_assist_counts = Hash.new { |hash, key| hash[key] = [0, 0] }
    end

    def accumulate(match)
      match_json = match.content
      dto = UrfStats::Dto

      champion_ids_by_participant = [nil] * 10

      match_json["participants"].each do |participant|
        champion_id = participant["championId"]
        stats = participant["stats"]

        @champion_pick_counts[champion_id] += 1

        @champion_win_counts[champion_id] += 1 \
          if stats["winner"]

        lane = (participant["timeline"] || {})["lane"] || "MIDDLE"

        case lane
          when "TOP"
            lane = :top
          when "JUNGLE"
            lane = :jungle
          when "MIDDLE", "MID"
            lane = :middle
          when "BOTTOM", "BOT"
            lane = :bottom
          else
            raise ArgumentError, "Invalid lane #{lane.dump}"
        end

        @lane_champion_counts[[lane, champion_id]] += 1

        champion_ids_by_participant[participant["participantId"] - 1] = champion_id
      end

      match_json["teams"].each do |team|
        (team["bans"] || []).each do |ban|
          @champion_ban_counts[ban["championId"]] += 1
        end
      end

      first_kill_assists = Set.new

      dto.events(match_json, event_type: "CHAMPION_KILL").each do |event|
        killer_id = champion_ids_by_participant[event["killerId"] - 1]
        victim_id = champion_ids_by_participant[event["victimId"] - 1]
        assister_ids = (event["assistingParticipantIds"] || []).map do |participant_id|
          champion_ids_by_participant[participant_id - 1]
        end

        @champion_kill_counts[killer_id] += 1
        @champion_death_counts[victim_id] += 1

        if assister_ids.size > 0
          assister_ids.each do |assister_id|
            @champion_assist_counts[assister_id] += 1

            key = [killer_id, assister_id]
            count, n_matches = *@kill_assist_counts[key]

            n_matches += 1 \
              if first_kill_assists.add?(key)

            @kill_assist_counts[key] = [count + 1, n_matches]
          end
        else
          # Denotes a solo kill.
          key = [killer_id, nil]
          count, n_matches = *@kill_assist_counts[key]

          n_matches += 1 \
            if first_kill_assists.add?(key)

          @kill_assist_counts[key] = [count + 1, n_matches]
        end
      end
    end

    def save!
      stat = parent.stat

      champions_by_champion_id = Hash[
          Riot::Api::Champion.all.map do |champion|
            [champion.entity_id, champion]
          end
      ]

      [[@champion_pick_counts, "CHAMPION_PICK"],
       [@champion_ban_counts, "CHAMPION_BAN"],
       [@champion_win_counts, "CHAMPION_WIN"],
       [@champion_kill_counts, "CHAMPION_KILL"],
       [@champion_death_counts, "CHAMPION_DEATH"],
       [@champion_assist_counts, "CHAMPION_ASSIST"]].each do |champion_counts, value_type|
        champion_counts.each do |champion_id, count|
          ei = EntityInteger.new(
              stat: stat,
              entity: champions_by_champion_id[champion_id],
              value_type: value_type,
              value: count
          )
          ei.save!
        end
      end

      @lane_champion_counts.each do |tuple, count|
        lane_type, champion_id = *tuple

        ei = EntityInteger.new(
            stat: stat,
            entity: champions_by_champion_id[champion_id],
            value_type: "CHAMPION_LANE_#{lane_type.to_s.upcase}",
            value: count
        )
        ei.save!
      end

      @kill_assist_counts.each do |key_tuple, value_tuple|
        killer_id, assister_id = *key_tuple
        count, n_matches = *value_tuple

        kac = KillAssistCount.new(
            stat: stat,
            killer: champions_by_champion_id[killer_id],
            assister: assister_id ? champions_by_champion_id[assister_id] : nil,
            value: count,
            n_matches: n_matches
        )
        kac.save!
      end
    end
  end
end
