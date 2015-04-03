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

class AddRiotApiMatches < ActiveRecord::Migration
  def change
    create_table :riot_api_matches do |t|
      t.integer :match_id, limit: 8
      t.string :region, limit: 4
      t.json :content

      t.index [:match_id, :region], unique: true
    end
  end
end
