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

((factory) ->
  if typeof define is "function" and define.amd?
    define ["ember",
            "application-base",
            "./champion",
            "./champion_duo_stat",
            "./champion_lane_stat",
            "./champion_stat",
            "./item",
            "./item_stat",
            "./mastery",
            "./polymorphic",
            "./rune",
            "./spell",
            "./stat",
            "./static_entity",
            "./useless_rune_mastery_stat"], factory
).call(@, (Ember, #
           app, #
           Champion, #
           ChampionDuoStat, #
           ChampionLaneStat, #
           ChampionStat, #
           Item, #
           ItemStat, #
           Mastery, #
           Polymorphic, #
           Rune, #
           Spell, #
           Stat, #
           StaticEntity, #
           UselessRuneMasteryStat) ->
  app
)
