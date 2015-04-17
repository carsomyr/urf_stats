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

class ChampionDuoStat
  # Because this is a synthetic model and doesn't inherit from `ActiveRecord::Base`.
  alias_method :read_attribute_for_serialization, :send

  attr_accessor :id
  attr_accessor :champions
  attr_accessor :n_kill_assists
  attr_accessor :n_matches
end