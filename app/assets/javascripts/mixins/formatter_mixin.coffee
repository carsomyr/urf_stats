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
  app.FormatterMixin = Ember.Mixin.create
    formatDecimal: (numerator, denominator) ->
      if numerator isnt null and denominator isnt null
        (numerator / denominator).toFixed(2) + ""
      else
        null

    formatPercent: (numerator, denominator) ->
      if numerator isnt null and denominator isnt null
        (100 * (numerator / denominator)).toFixed(2) + "%"
      else
        null

    formatTime: (nSeconds) ->
      nHours = Math.floor(nSeconds / 3600)
      nMinutes = Math.floor((nSeconds - (nHours * 3600)) / 60)
      nSeconds -= (nHours * 3600) + (nMinutes * 60)

      acc = ""

      if nHours > 0
        acc += nHours + ":"

      if nMinutes >= 10 or nHours is 0
        acc += nMinutes + ":"
      else
        acc += "0" + nMinutes + ":"

      if nSeconds >= 10 or (nHours is 0 and nMinutes is 0)
        acc += nSeconds
      else
        acc += "0" + nSeconds

      acc

  app.FormatterMixin
)
