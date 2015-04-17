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
  app.StaticEntityImageComponent = Ember.Component.extend
    tagName: "a"
    attributeBindings: ["href", "dataToggle:data-toggle", "dataPlacement:data-placement", "title"]
    classNames: ["static-entity-link"]
    model: null

    href: (->
      model = @get("model")

      if model isnt null
        switch model.constructor.typeKey
          when "champion", "item", "mastery"
            "http://leagueoflegends.wikia.com/wiki/" + encodeURIComponent(model.get("name").replace(" ", "_"))
          when "rune"
            "http://leagueoflegends.wikia.com/wiki/List_of_runes"
          else
            throw new Error("Invalid static entity type")
      else
        null
    ).property("model")

    imageUrl: (->
      model = @get("model")

      if model isnt null
        app.DATA_DRAGON_IMAGE_URL + "/" + model.constructor.typeKey.toLowerCase() + "/" + model.get("imagePath")
      else
        null
    ).property("model")

    dataToggle: "tooltip"
    dataPlacement: "bottom"

    title: (->
      model = @get("model")

      if model isnt null
        model.get("name")
      else
        null
    ).property("model")

    didInsertElement: ->
      @.$().tooltip()

  app.StaticEntityImageComponent
)
