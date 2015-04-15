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
  class UselessRuneMasteryAccumulator < Accumulator
    USELESS_RUNE_IDS = Set.new(
        [
            5295, # Greater Glyph of Cooldown Reduction
            5301, # Greater Glyph of Mana Regeneration
            5296, # Greater Glyph of Scaling Cooldown Reduction
            5302, # Greater Glyph of Scaling Mana Regeneration
            5265, # Greater Mark of Cooldown Reduction
            5355, # Greater Quintessence of Cooldown Reduction
            5373, # Greater Quintessence of Energy Regeneration
            5361, # Greater Quintessence of Mana Regeneration
            5356, # Greater Quintessence of Scaling Cooldown Reduction
            5362, # Greater Quintessence of Scaling Mana Regeneration
            5325, # Greater Seal of Cooldown Reduction
            5369, # Greater Seal of Energy Regeneration
            5331, # Greater Seal of Mana Regeneration
            5370, # Greater Seal of Scaling Energy Regeneration
            5332 # Greater Seal of Scaling Mana Regeneration
        ]
    )

    USELESS_MASTERY_IDS = Set.new(
        [
            4353, # Intelligence
            4113, # Sorcery
            4322 # Summoner's Insight
        ]
    )

    def initialize(parent)
      super(parent)

      @useless_rune_counts = {}
      @useless_rune_counts.default = 0

      @useless_mastery_counts = {}
      @useless_mastery_counts.default = 0
    end

    def accumulate(match)
      match_json = match.content

      match_json["participants"].each do |participant|
        (participant["runes"] || []).each do |rune|
          rune_id = rune["runeId"]

          @useless_rune_counts[rune_id] += 1 \
            if USELESS_RUNE_IDS.include?(rune_id)
        end

        (participant["masteries"] || []).each do |mastery|
          mastery_id = mastery["masteryId"]

          @useless_mastery_counts[mastery_id] += 1 \
            if USELESS_MASTERY_IDS.include?(mastery_id)
        end
      end
    end

    def save!
      stat = parent.stat

      runes_by_rune_id = Hash[
          Riot::Api::Rune.all.map do |rune|
            [rune.entity_id, rune]
          end
      ]

      masteries_by_mastery_id = Hash[
          Riot::Api::Mastery.all.map do |mastery|
            [mastery.entity_id, mastery]
          end
      ]

      @useless_rune_counts.each do |rune_id, count|
        useless_rune_count = EntityCount.new(
            stat: stat,
            entity: runes_by_rune_id[rune_id],
            count_type: "USELESS_RUNE",
            value: count
        )
        useless_rune_count.save!
      end

      @useless_mastery_counts.each do |mastery_id, count|
        useless_mastery_count = EntityCount.new(
            stat: stat,
            entity: masteries_by_mastery_id[mastery_id],
            count_type: "USELESS_MASTERY",
            value: count
        )
        useless_mastery_count.save!
      end
    end
  end
end
