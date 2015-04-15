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

  context UrfStats::ChampionAccumulator do
    it "summarizes champion information" do
      expected_pick_counts = {
          "Amumu" => 1, "Anivia" => 1, "Blitzcrank" => 1, "Cassiopeia" => 1, "Cho'Gath" => 1, "Evelynn" => 1,
          "Ezreal" => 3, "Fiddlesticks" => 1, "Fiora" => 1, "Hecarim" => 1, "Heimerdinger" => 1, "Jayce" => 1,
          "Kassadin" => 1, "Katarina" => 1, "Kayle" => 1, "Leona" => 1, "Lux" => 1, "Master Yi" => 1, "Nidalee" => 1,
          "Shaco" => 1, "Sivir" => 1, "Syndra" => 1, "Talon" => 1, "Teemo" => 2, "Twisted Fate" => 1, "Vayne" => 1,
          "Vel'Koz" => 1
      }

      expected_ban_counts = {
          "Ahri" => 1, "Blitzcrank" => 1, "Kassadin" => 1, "Katarina" => 1, "Kayle" => 1, "Kog'Maw" => 1,
          "LeBlanc" => 2, "Lucian" => 1, "Master Yi" => 2, "Nidalee" => 1, "Ryze" => 1, "Shaco" => 1, "Sona" => 2,
          "Zed" => 1
      }

      expected_win_counts = {
          "Amumu" => 1, "Anivia" => 1, "Cassiopeia" => 1, "Ezreal" => 2, "Fiddlesticks" => 1, "Fiora" => 1,
          "Kayle" => 1, "Leona" => 1, "Lux" => 1, "Master Yi" => 1, "Nidalee" => 1, "Sivir" => 1, "Syndra" => 1,
          "Talon" => 1
      }

      expected_kill_counts = {
          "Amumu" => 8, "Anivia" => 8, "Blitzcrank" => 14, "Cassiopeia" => 10, "Cho'Gath" => 9, "Evelynn" => 27,
          "Ezreal" => 32, "Fiddlesticks" => 14, "Fiora" => 8, "Hecarim" => 12, "Heimerdinger" => 4, "Jayce" => 19,
          "Kassadin" => 3, "Katarina" => 4, "Kayle" => 12, "Leona" => 13, "Lux" => 4, "Master Yi" => 20,
          "Nidalee" => 11, "Shaco" => 8, "Sivir" => 14, "Syndra" => 34, "Talon" => 23, "Teemo" => 25,
          "Twisted Fate" => 6, "Vayne" => 16, "Vel'Koz" => 10
      }

      expected_death_counts = {
          "Amumu" => 18, "Anivia" => 13, "Blitzcrank" => 10, "Cassiopeia" => 17, "Cho'Gath" => 8, "Evelynn" => 17,
          "Ezreal" => 38, "Fiddlesticks" => 10, "Fiora" => 7, "Hecarim" => 17, "Heimerdinger" => 10, "Jayce" => 10,
          "Kassadin" => 10, "Katarina" => 19, "Kayle" => 5, "Leona" => 17, "Lux" => 6, "Master Yi" => 4,
          "Nidalee" => 21, "Shaco" => 9, "Sivir" => 12, "Syndra" => 12, "Talon" => 14, "Teemo" => 28,
          "Twisted Fate" => 11, "Vayne" => 15, "Vel'Koz" => 10
      }

      expected_assist_counts = {
          "Amumu" => 11, "Anivia" => 12, "Blitzcrank" => 8, "Cassiopeia" => 22, "Cho'Gath" => 8, "Evelynn" => 15,
          "Ezreal" => 34, "Fiddlesticks" => 9, "Fiora" => 6, "Hecarim" => 13, "Heimerdinger" => 5, "Jayce" => 15,
          "Kassadin" => 3, "Katarina" => 7, "Kayle" => 14, "Leona" => 15, "Lux" => 13, "Master Yi" => 1,
          "Nidalee" => 15, "Shaco" => 10, "Sivir" => 9, "Syndra" => 9, "Talon" => 9, "Teemo" => 30, "Twisted Fate" => 9,
          "Vayne" => 9, "Vel'Koz" => 5
      }

      [["CHAMPION_PICK", expected_pick_counts],
       ["CHAMPION_BAN", expected_ban_counts],
       ["CHAMPION_WIN", expected_win_counts],
       ["CHAMPION_KILL", expected_kill_counts],
       ["CHAMPION_DEATH", expected_death_counts],
       ["CHAMPION_ASSIST", expected_assist_counts]].each do |count_type, expected_champion_counts|
        counts = Hash[
            EntityCount.where(stat: @stat, count_type: count_type).eager_load(:entity).map do |ec|
              [ec.entity.name, ec.value]
            end
        ]

        expect(counts).to eq(expected_champion_counts)
      end

      n_laners = 0

      [[:top,
        "Amumu" => 1, "Blitzcrank" => 1, "Cho'Gath" => 1, "Evelynn" => 1, "Ezreal" => 1, "Fiddlesticks" => 1,
        "Fiora" => 1, "Nidalee" => 1, "Shaco" => 1, "Teemo" => 1],
       [:jungle,
        "Cassiopeia" => 1, "Kassadin" => 1, "Katarina" => 1, "Master Yi" => 1],
       [:middle,
        "Anivia" => 1, "Jayce" => 1, "Kayle" => 1, "Talon" => 1, "Twisted Fate" => 1],
       [:bottom,
        "Ezreal" => 2, "Hecarim" => 1, "Heimerdinger" => 1, "Leona" => 1, "Lux" => 1, "Sivir" => 1, "Syndra" => 1,
        "Teemo" => 1, "Vayne" => 1, "Vel'Koz" => 1]].each do |lane_type, expected_lane_counts|
        counts = Hash[
            EntityCount.where(stat: @stat, count_type: "CHAMPION_LANE_#{lane_type.to_s.upcase}")
                .eager_load(:entity).map do |ec|
              [ec.entity.name, ec.value]
            end
        ]

        expect(counts).to eq(expected_lane_counts)

        n_laners += counts.values.reduce(0) { |sum, count| sum + count }
      end

      # The total number of laners had better equal the number of games times 10.
      expect(n_laners).to eq(@stat.n_matches * 10)

      kill_assist_counts = KillAssistCount.arel_table

      # Note: We can't use `eager_load` here because of SQL grouping.
      alternate_assist_counts = Hash[
          KillAssistCount
              .select(kill_assist_counts[:assister_id], kill_assist_counts[:value].sum.as("total"))
              .where(
                  (kill_assist_counts[:stat_id].eq @stat.id)
                      .and(kill_assist_counts[:assister_id].not_eq nil)
              )
              .group(:assister_id)
              .preload(:assister).map do |kac|
            [kac.assister.name, kac.total]
          end
      ]

      # Arrive at the assist count in an alternate way.
      expect(alternate_assist_counts).to eq(expected_assist_counts)
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
