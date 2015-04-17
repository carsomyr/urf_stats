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
            "ember-data",
            "application-base"], factory
).call(@, (Ember, #
           DS, #
           app) ->
  app.Stat = DS.Model.extend
    nMatches: DS.attr("number")
    totalDuration: DS.attr("number")
    totalKills: DS.attr("number")
    totalAssists: DS.attr("number")
    nFirstBloodGames: DS.attr("number")
    totalTimeFirstBlood: DS.attr("number")
    totalGold: DS.attr("number")
    totalMinionsKilled: DS.attr("number")
    totalChampionLevel: DS.attr("number")
    totalDragons: DS.attr("number")
    nFirstDragonGames: DS.attr("number")
    totalTimeFirstDragon: DS.attr("number")
    totalBarons: DS.attr("number")
    nFirstBaronGames: DS.attr("number")
    totalTimeFirstBaron: DS.attr("number")

  app.Stat
)
