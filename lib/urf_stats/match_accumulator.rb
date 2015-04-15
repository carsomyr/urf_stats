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
  class MatchAccumulator < Accumulator
    attr_reader :stat

    def initialize(region, start_time, interval = :day, &block)
      super(&block)

      @stat = Stat.new(region: region, start_time: start_time, interval: :day)

      @n_matches = 0
      @total_duration = 0
      @total_kills = 0
      @total_assists = 0
      @n_first_blood_games = 0
      @total_time_first_blood = 0
      @total_gold = 0
      @total_minions_killed = 0
      @total_champion_level = 0
      @total_dragons = 0
      @n_first_dragon_games = 0
      @total_time_first_dragon = 0
      @total_barons = 0
      @n_first_baron_games = 0
      @total_time_first_baron = 0
    end

    def accumulate(match)
      match_json = match.content
      dto = UrfStats::Dto

      # Champion kills.

      kill_events = dto.events(match_json, event_type: "CHAMPION_KILL")

      @total_kills += kill_events.size
      @total_assists += kill_events.reduce(0) do |total, kill_event|
        total + (kill_event["assistingParticipantIds"] || []).size
      end

      if kill_events.size > 0
        @n_first_blood_games += 1
        @total_time_first_blood += kill_events.first["timestamp"] / 1000
      end

      # Gold and minions.

      (1...11).each do |participant_id|
        participant_frames = dto.participant_frames(match_json, participant_id: participant_id)

        if participant_frames.size > 0
          participant_frame = participant_frames.last

          @total_gold += participant_frame["totalGold"]
          @total_minions_killed += participant_frame["minionsKilled"] + participant_frame["jungleMinionsKilled"]
        end
      end

      # Dragon kills.

      kill_events = dto.events(match_json, event_type: "ELITE_MONSTER_KILL", monster_type: "DRAGON")

      @total_dragons += kill_events.size

      if kill_events.size > 0
        @n_first_dragon_games += 1
        @total_time_first_dragon += kill_events.first["timestamp"] / 1000
      end

      # Baron kills.

      kill_events = dto.events(match_json, event_type: "ELITE_MONSTER_KILL", monster_type: "BARON_NASHOR")

      @total_barons += kill_events.size

      if kill_events.size > 0
        @n_first_baron_games += 1
        @total_time_first_baron += kill_events.first["timestamp"] / 1000
      end

      # Champion levels.

      match_json["participants"].each do |participant|
        @total_champion_level += participant["stats"]["champLevel"]
      end

      @n_matches += 1
      @total_duration += match.duration

      super
    end

    def save!
      @stat.attributes = Hash[
          ["n_matches",
           "total_duration",
           "total_kills",
           "total_assists",
           "n_first_blood_games",
           "total_time_first_blood",
           "total_gold",
           "total_minions_killed",
           "total_champion_level",
           "total_dragons",
           "n_first_dragon_games",
           "total_time_first_dragon",
           "total_barons",
           "n_first_baron_games",
           "total_time_first_baron"].map do |attribute|
            [attribute, instance_variable_get("@#{attribute}")]
          end
      ]
      @stat.save!

      super

      @stat
    end
  end
end
