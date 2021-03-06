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

module Riot
  module Api
    class Match < ActiveRecord::Base
      self.table_name_prefix = "riot_api_"

      validates :match_id, presence: true, uniqueness: {scope: :region}
      validates :region, presence: true
      validates :duration, numericality: {greater_than_or_equal_to: 0}, allow_nil: true
    end
  end
end
