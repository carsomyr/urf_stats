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
    end

    def accumulate(match)
      # Implement me!

      super
    end

    def save!
      # Implement me!

      super
    end
  end
end
