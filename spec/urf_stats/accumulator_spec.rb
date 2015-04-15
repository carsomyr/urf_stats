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

require "spec_helper"
require "urf_stats"

describe UrfStats::Accumulator do
  fixtures "riot/api/match"

  before(:example) do
    acc = UrfStats.match_accumulator
    matches = Riot::Api::Match.all
    matches.each { |match| acc.accumulate(match) }

    @stat = acc.save!
  end

  context UrfStats::MatchAccumulator do
    it "summarizes match information" do
      expect(@stat).to_not eq(nil)
      expect(@stat.n_matches).to eq(3)
      expect(@stat.average_duration).to eq(1977)
      expect(@stat.average_n_kills).to eq(122)
      expect(@stat.average_n_assists).to eq(105)
      expect(@stat.average_time_first_blood).to eq(148954)
      expect(@stat.average_gold).to eq(194753)
      expect(@stat.average_n_minions_killed).to eq(1468)
      expect(@stat.average_n_dragons).to eq(4)
      expect(@stat.average_time_first_dragon).to eq(464228)
      expect(@stat.average_n_barons).to eq(1)
      expect(@stat.average_time_first_baron).to eq(1442746)
    end
  end

  context UrfStats::UselessRuneMasteryAccumulator do
    it "counts the number of instances where participants have useless runes and masteries equipped" do
      expected_useless_rune_counts = {
          "Greater Glyph of Cooldown Reduction" => 1,
          "Greater Glyph of Mana Regeneration" => 1,
          "Greater Glyph of Scaling Cooldown Reduction" => 1,
          "Greater Seal of Mana Regeneration" => 1
      }

      expected_useless_mastery_counts = {
          "Sorcery" => 20,
          "Summoner's Insight" => 3
      }

      [["USELESS_RUNE", expected_useless_rune_counts],
       ["USELESS_MASTERY", expected_useless_mastery_counts]].each do |count_type, expected_rune_mastery_counts|
        counts = Hash[
            EntityCount.where(stat: @stat, count_type: count_type).eager_load(:entity).map do |ec|
              [ec.entity.name, ec.value]
            end
        ]

        expect(counts).to eq(expected_rune_mastery_counts)
      end
    end
  end

  after(:example) do
    @stat.destroy!
  end
end
