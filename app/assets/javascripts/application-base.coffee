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
            "ember-data"], factory
).call(@, (Ember, #
           DS) ->
  app = Ember.Application.create
    LOG_TRANSITIONS: true

  app.ApplicationAdapter = DS.ActiveModelAdapter.extend
    namespace: "api"

  app.GAME_VERSION = "5.7.2"

  app.DATA_DRAGON_IMAGE_URL = "http://ddragon.leagueoflegends.com/cdn/" + app.GAME_VERSION + "/img"
  app.DATA_DRAGON_DATA_URL = "http://ddragon.leagueoflegends.com/cdn/" + app.GAME_VERSION + "/data/en_US"

  app.deferReadiness()

  app
)
