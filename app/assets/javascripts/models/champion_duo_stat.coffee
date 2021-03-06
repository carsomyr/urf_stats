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
            "./champion",
            "mixins/formatter_mixin"], factory
).call(@, (Ember, #
           DS, #
           app, #
           Champion, #
           FormatterMixin) ->
  app.ChampionDuoStat = DS.Model.extend FormatterMixin,
    champions: DS.hasMany("champion")
    nKillAssists: DS.attr("number")
    nMatches: DS.attr("number")

    averageKillAssistsPerMatch: (->
      @formatDecimal(@get("nKillAssists"), @get("nMatches"))
    ).property("nKillAssists", "nMatches")

  app.ChampionDuoStat
)
