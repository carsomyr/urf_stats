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

class AddIndexes < ActiveRecord::Migration
  def change
    change_table :riot_api_matches do |t|
      t.index :region
      t.index :match_id
    end

    change_table :riot_api_static_entities do |t|
      t.index :entity_id
    end

    change_table :stats do |t|
      t.index :region
      t.index :start_time
    end

    change_table :entity_counts do |t|
      t.index :stat_id
      t.index :entity_id
    end

    change_table :item_purchase_counts do |t|
      t.index :stat_id
      t.index :item_id
      t.index :purchaser_id
    end

    change_table :kill_assist_counts do |t|
      t.index :stat_id
      t.index :killer_id
      t.index :assister_id
    end
  end
end
