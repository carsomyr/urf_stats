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
            "./index_route",
            "./introduction_route",
            "./stats_route",
            "./champion_stats_route",
            "./champion_duo_stats_route",
            "./champion_lane_stats_route",
            "./item_stats_route",
            "./useless_rune_mastery_stats_route"], factory
).call(@, (Ember, #
           app, #
           IndexRoute, #
           IntroductionRoute, #
           StatsRoute, #
           ChampionStatsRoute, #
           ChampionDuoStatsRoute, #
           ChampionLaneStatsRoute, #
           ItemStatsRoute, #
           UselessRuneMasteryStatsRoute) ->
  app.Router.map ->
    @route("introduction")
    @resource("stats")
    @resource("champion_stats")
    @resource("champion_duo_stats")
    @resource("champion_lane_stats")
    @resource("item_stats")
    @resource("useless_rune_mastery_stats")

  app
)
