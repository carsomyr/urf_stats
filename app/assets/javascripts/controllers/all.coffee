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
            "./stats_controller",
            "./champion_stats_controller",
            "./champion_duo_stats_controller",
            "./champion_lane_stats_controller",
            "./item_stats_controller",
            "./useless_rune_mastery_stats_controller",
            "./introduction_controller"], factory
).call(@, (Ember, #
           app, #
           StatsController, #
           ChampionStatsController, #
           ChampionDuoStatsController, #
           ChampionLaneStatsController, #
           ItemStatsController, #
           UselessRuneMasteryStatsController, #
           IntroductionController) ->
  app
)
