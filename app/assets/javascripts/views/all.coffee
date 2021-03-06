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
            "./property_setter_view",
            "./region_setter_view",
            "./sort_button_view",
            "./start_time_setter_view",
            "./champion_duo_stats_sort_bar_view",
            "./champion_stats_sort_bar_view",
            "./item_stats_sort_bar_view"], factory
).call(@, (Ember, #
           app, #
           PropertySetterView, #
           RegionSetterView, #
           SortButtonView, #
           StartTimeSetterView, #
           ChampionDuoStatsSortBarView, #
           ChampionStatsSortBarView, #
           ItemStatsSortBarView) ->
  app
)
