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
            "./item",
            "./champion",
            "mixins/formatter_mixin"], factory
).call(@, (Ember, #
           DS, #
           app, #
           Item, #
           Champion, #
           FormatterMixin) ->
  app.ItemStat = DS.Model.extend FormatterMixin,
    item: DS.belongsTo("item")
    topPurchasers: DS.hasMany("champion")
    nFirstPurchases: DS.attr("number")
    totalFirstPurchases: DS.attr("number")
    nPurchases: DS.attr("number")
    totalPurchases: DS.attr("number")

    percentPurchases: (->
      @formatPercent(@get("nPurchases"), @get("totalPurchases"))
    ).property("nPurchases", "totalPurchases")

    percentFirstPurchases: (->
      @formatPercent(@get("nFirstPurchases"), @get("totalFirstPurchases"))
    ).property("nFirstPurchases", "totalFirstPurchases")

  app.ItemStat
)
