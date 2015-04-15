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

  context UrfStats::ItemPurchaseAccumulator do
    it "counts item purchases by champion" do
      counts = ItemPurchaseCount.where(stat: @stat).eager_load(:item, :purchaser).map do |ipc|
        [ipc.purchaser.name, ipc.item.name, ipc.value]
      end

      sampled_counts = [
          ["Amumu", "Hextech Gunblade", 1],
          ["Anivia", "Rabadon's Deathcap", 1],
          ["Blitzcrank", "Iceborn Gauntlet", 1],
          ["Cassiopeia", "Abyssal Scepter", 1],
          ["Cho'Gath", "Abyssal Scepter", 1],
          ["Evelynn", "Hextech Gunblade", 1],
          ["Ezreal", "Lich Bane", 2],
          ["Fiddlesticks", "Liandry's Torment", 1],
          ["Fiora", "Blade of the Ruined King", 1],
          ["Hecarim", "Infinity Edge", 1],
          ["Heimerdinger", "Rabadon's Deathcap", 1],
          ["Jayce", "Banshee's Veil", 1],
          ["Kassadin", "Enchantment: Magus", 1],
          ["Katarina", "Liandry's Torment", 1],
          ["Kayle", "Lich Bane", 1],
          ["Leona", "Luden's Echo", 1],
          ["Lux", "Lich Bane", 1],
          ["Master Yi", "Blade of the Ruined King", 1],
          ["Nidalee", "Lich Bane", 1],
          ["Shaco", "Infinity Edge", 1],
          ["Sivir", "Banshee's Veil", 1],
          ["Syndra", "Abyssal Scepter", 1],
          ["Talon", "Infinity Edge", 1],
          ["Teemo", "Luden's Echo", 2],
          ["Twisted Fate", "Lich Bane", 1],
          ["Vayne", "Banshee's Veil", 1],
          ["Vel'Koz", "Luden's Echo", 1]
      ]

      expect(counts).to include(*sampled_counts)

      expected_average_times_first_item = {
          "Blade of the Ruined King" => 520845,
          "Enchantment: Magus" => 448358,
          "Enchantment: Warrior" => 319307,
          "Hextech Gunblade" => 946908,
          "Iceborn Gauntlet" => 536276,
          "Infinity Edge" => 555426,
          "Liandry's Torment" => 658586,
          "Lich Bane" => 555580,
          "Luden's Echo" => 728558,
          "Maw of Malmortius" => 759457,
          "Nashor's Tooth" => 503303,
          "Rabadon's Deathcap" => 768094,
          "Rod of Ages" => 427082,
          "Trinity Force" => 540856,
          "Void Staff" => 884100,
          "Will of the Ancients" => 419037,
          "Youmuu's Ghostblade" => 639428,
          "Zhonya's Hourglass" => 609478
      }

      counts = Hash[
          EntityCount.where(stat: @stat, count_type: "AVERAGE_TIME_FIRST_ITEM").eager_load(:entity).map do |ec|
            [ec.entity.name, ec.value]
          end
      ]

      expect(counts).to eq(expected_average_times_first_item)
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
