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
            "application-base"], factory
).call(@, (Ember, #
           app) ->
  app.ChampionStatsController = Ember.Controller.extend
    queryParams: ["region", "start_time", "sort_by", "sort_direction", "search"]
    region: undefined
    start_time: undefined
    sort_by: undefined
    sort_direction: undefined
    search: undefined
    changed: 0
    championTitle: null

    changeObserver: (->
      @set("changed", (@get("changed") + 1) % 64)
    ).observes("region", "start_time", "sort_by", "sort_direction", "search")

    championTitleObserver: (->
      if @get("model.length") isnt 1
        @set("championTitle", null)

        return

      championKey = @get("model").objectAt(0).get("champion.key")
      controller = @

      Ember.$.getJSON app.DATA_DRAGON_DATA_URL + "/champion/" + championKey + ".json", (json) ->
        controller.set("championTitle", json["data"][championKey]["title"])
    ).observes("model.@each.champion")

    backgroundStyle: (->
      if @get("model.length") isnt 1
        style = ""
      else
        championKey = @get("model").objectAt(0).get("champion.key")

        style = "background-image: url(http://ddragon.leagueoflegends.com/cdn/img/champion/splash/"
        style += championKey
        style += "_0.jpg);"

      style.htmlSafe()
    ).property("model.@each.champion")

    championNameTitle: (->
      if @get("model.length") isnt 1
        return "Champions"

      champion = @get("model").objectAt(0).get("champion")
      championTitle = @get("championTitle")

      if championTitle isnt null
        champion.get("name") + ": " + championTitle
      else
        "Champions"
    ).property("model.@each.champion", "championTitle")

  app.ChampionStatsController
)
