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
            "application-base",
            "mixins/formatter_mixin"], factory
).call(@, (Ember, #
           DS, #
           app, #
           FormatterMixin) ->
  app.Stat = DS.Model.extend FormatterMixin,
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

    averageDuration: (->
      totalDuration = @get("totalDuration")
      nMatches = @get("nMatches")

      if totalDuration isnt null and nMatches isnt null
        @formatTime(Math.floor(totalDuration / nMatches))
      else
        null
    ).property("totalDuration", "nMatches")

    averageKills: (->
      totalKills = @get("totalKills")
      nMatches = @get("nMatches")

      if totalKills isnt null and nMatches isnt null
        @formatDecimal(totalKills, 10 * nMatches)
      else
        null
    ).property("totalKills", "nMatches")

    averageAssists: (->
      totalAssists = @get("totalAssists")
      nMatches = @get("nMatches")

      if totalAssists isnt null and nMatches isnt null
        @formatDecimal(totalAssists, 10 * nMatches)
      else
        null
    ).property("totalAssists", "nMatches")

    averageTimeFirstBlood: (->
      totalTimeFirstBlood = @get("totalTimeFirstBlood")
      nFirstBloodGames = @get("nFirstBloodGames")

      if totalTimeFirstBlood isnt null and nFirstBloodGames isnt null
        @formatTime(Math.floor(totalTimeFirstBlood / nFirstBloodGames))
      else
        null
    ).property("totalTimeFirstBlood", "nFirstBloodGames")

    averageGold: (->
      totalGold = @get("totalGold")
      nMatches = @get("nMatches")

      if totalGold isnt null and nMatches isnt null
        Math.floor(totalGold / (10 * nMatches))
      else
        null
    ).property("totalGold", "nMatches")

    averageMinionsKilled: (->
      totalMinionsKilled = @get("totalMinionsKilled")
      nMatches = @get("nMatches")

      if totalMinionsKilled isnt null and nMatches isnt null
        Math.floor(totalMinionsKilled / (10 * nMatches))
      else
        null
    ).property("totalMinionsKilled", "nMatches")

    averageChampionLevel: (->
      totalChampionLevel = @get("totalChampionLevel")
      nMatches = @get("nMatches")

      if totalChampionLevel isnt null and nMatches isnt null
        Math.floor(totalChampionLevel / (10 * nMatches))
      else
        null
    ).property("totalChampionLevel", "nMatches")

    averageDragons: (->
      @formatDecimal(@get("totalDragons"), @get("nMatches"))
    ).property("totalDragons", "nMatches")

    averageTimeFirstDragon: (->
      totalTimeFirstDragon = @get("totalTimeFirstDragon")
      nFirstDragonGames = @get("nFirstDragonGames")

      if totalTimeFirstDragon isnt null and nFirstDragonGames isnt null
        @formatTime(Math.floor(totalTimeFirstDragon / nFirstDragonGames))
      else
        null
    ).property("totalTimeFirstDragon", "nFirstDragonGames")

    averageBarons: (->
      @formatDecimal(@get("totalBarons"), @get("nMatches"))
    ).property("totalBarons", "nMatches")

    averageTimeFirstBaron: (->
      totalTimeFirstBaron = @get("totalTimeFirstBaron")
      nFirstBaronGames = @get("nFirstBaronGames")

      if totalTimeFirstBaron isnt null and nFirstBaronGames isnt null
        @formatTime(Math.floor(totalTimeFirstBaron / nFirstBaronGames))
      else
        null
    ).property("totalTimeFirstBaron", "nFirstBaronGames")

  app.Stat
)
