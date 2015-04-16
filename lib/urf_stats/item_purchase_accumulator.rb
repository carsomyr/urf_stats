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
  class ItemPurchaseAccumulator < Accumulator
    BIG_TICKET_ITEM_IDS = Set.new(
        [
            3001, # Abyssal Scepter
            3003, # Archangel's Staff
            3504, # Ardent Censer
            3174, # Athene's Unholy Grail
            3102, # Banshee's Veil
            3060, # Banner of Command
            3071, # The Black Cleaver
            3153, # Blade of the Ruined King
            3072, # The Bloodthirster
            3721, # Enchantment: Cinderhulk (Poacher's Knife)
            3725, # Enchantment: Cinderhulk (Ranger's Trailblazer)
            3717, # Enchantment: Cinderhulk (Skirmisher's Sabre)
            3709, # Enchantment: Cinderhulk (Stalker's Blade)
            3722, # Enchantment: Devourer (Poacher's Knife)
            3726, # Enchantment: Devourer (Ranger's Trailblazer)
            3718, # Enchantment: Devourer (Skirmisher's Sabre)
            3710, # Enchantment: Devourer (Stalker's Blade)
            3720, # Enchantment: Magus (Poacher's Knife)
            3724, # Enchantment: Magus (Ranger's Trailblazer)
            3716, # Enchantment: Magus (Skirmisher's Sabre)
            3708, # Enchantment: Magus (Stalker's Blade)
            3719, # Enchantment: Warrior (Poacher's Knife)
            3723, # Enchantment: Warrior (Ranger's Trailblazer)
            3714, # Enchantment: Warrior (Skirmisher's Sabre)
            3707, # Enchantment: Warrior (Stalker's Blade)
            3508, # Essence Reaver
            3401, # Face of the Mountain
            3092, # Frost Queen's Claim
            3110, # Frozen Heart
            3022, # Frozen Mallet
            3026, # Guardian Angel
            3124, # Guinsoo's Rageblade
            3146, # Hextech Gunblade
            3025, # Iceborn Gauntlet
            3031, # Infinity Edge
            3035, # Last Whisper
            3151, # Liandry's Torment
            3100, # Lich Bane
            3190, # Locket of the Iron Solari
            3285, # Luden's Echo
            3004, # Manamune
            3156, # Maw of Malmortius
            3139, # Mercurial Scimitar
            3222, # Mikhael's Crucible
            3165, # Morellonomicon
            3115, # Nashor's Tooth
            3056, # Ohmwrecker
            3046, # Phantom Dancer
            3089, # Rabadon's Deathcap
            3143, # Randuin's Omen
            3074, # Ravenous Hydra
            3800, # Righteous Glory
            3027, # Rod of Ages
            2045, # Ruby Sighstone
            3085, # Runaan's Hurricane
            3116, # Rylai's Crystal Scepter
            3065, # Spirit Visage
            3087, # Statikk Shiv
            3068, # Sunfire Cape
            3069, # Talisman of Ascension
            3075, # Thornmail
            3078, # Trinity Force
            3023, # Twin Shadows
            3135, # Void Staff
            3083, # Warmog's Armor
            3152, # Will of the Ancients
            3091, # Wit's End
            3142, # Youmuu's Ghostblade
            3050, # Zeke's Herald
            3172, # Zephyr
            3157, # Zhonya's Hourglass
            3512 # Zz'Rot Portal
        ]
    )

    def initialize(parent)
      super(parent)

      # Keys are tuples of the form (item id, champion id).
      @item_champion_counts = {}
      @item_champion_counts.default = 0

      # Values are tuples of the form (total, number purchased).
      @total_time_first_items = {}
      @total_time_first_items.default = [0, 0]
    end

    def accumulate(match)
      match_json = match.content
      dto = UrfStats::Dto

      match_json["participants"].each do |participant|
        champion_id = participant["championId"]
        stats = participant["stats"]

        # Throw in a `uniq` to prevent counting of multiple purchases of the same item.
        (0...6).map do |i|
          stats["item#{i}"]
        end.uniq.select do |item_id|
          item_id > 0
        end.each do |item_id|
          @item_champion_counts[[item_id, champion_id]] += 1 \
            if BIG_TICKET_ITEM_IDS.include?(item_id)
        end
      end

      (1...11).each do |participant_id|
        first_purchase_event = dto.events(
            match_json,
            event_type: "ITEM_PURCHASED",
            participant_id: participant_id
        ).find do |event|
          BIG_TICKET_ITEM_IDS.include?(event["itemId"])
        end

        next \
          if !first_purchase_event

        item_id = first_purchase_event["itemId"]
        timestamp = first_purchase_event["timestamp"] / 1000
        total_time_first_item, n_purchases = *@total_time_first_items[item_id]

        @total_time_first_items[item_id] = [total_time_first_item + timestamp, n_purchases + 1]
      end
    end

    def save!
      stat = parent.stat

      items_by_item_id = Hash[
          Riot::Api::Item.all.map do |item|
            [item.entity_id, item]
          end
      ]

      champions_by_champion_id = Hash[
          Riot::Api::Champion.all.map do |champion|
            [champion.entity_id, champion]
          end
      ]

      @item_champion_counts.each do |tuple, count|
        item_id, champion_id = *tuple

        item_purchase_count = ItemPurchaseCount.new(
            stat: stat,
            item: items_by_item_id[item_id],
            purchaser: champions_by_champion_id[champion_id],
            value: count
        )
        item_purchase_count.save!
      end

      @total_time_first_items.each do |item_id, tuple|
        total_time_first_item, n_purchases = *tuple

        ei = EntityInteger.new(
            stat: stat,
            entity: items_by_item_id[item_id],
            value_type: "TOTAL_TIME_FIRST_ITEM",
            value: total_time_first_item
        )
        ei.save!

        ei = EntityInteger.new(
            stat: stat,
            entity: items_by_item_id[item_id],
            value_type: "N_FIRST_ITEM_PURCHASES",
            value: n_purchases
        )
        ei.save!
      end
    end
  end
end
