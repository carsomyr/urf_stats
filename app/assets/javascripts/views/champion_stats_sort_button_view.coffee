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
            "./property_setter_view"], factory
).call(@, (Ember, #
           app, #
           PropertySetterView) ->
  app.ChampionStatsSortButtonView = PropertySetterView.extend
    templateName: "views/champion_stats_sort_button"
    classNames: ["btn-champion-stats-sort"]
    tagName: "button"
    sortBy: null
    value: Ember.computed.alias("controller.sort_direction")

    active: (->
      @get("controller.sort_by") is @get("sortBy")
    ).property("controller.changed", "sortBy")

    iconClasses: (->
      switch @get("value")
        when undefined
          "fa fa-lg fa-sort-desc"
        when "ascending"
          "fa fa-lg fa-sort-asc"
        else
          throw new Error("Invalid sort direction")
    ).property("controller.changed", "value")

    click: ->
      value = @get("value")

      if @get("active")
        switch value
          when undefined
            value = "ascending"
          when "ascending"
            value = undefined
          else
            throw new Error("Invalid sort direction")

      @set("controller.sort_by", @get("sortBy"))
      @set("value", value)

  app.ChampionStatsSortButtonView
)
