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
