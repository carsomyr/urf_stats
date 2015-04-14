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

class AddCounts < ActiveRecord::Migration
  def change
    create_table :entity_counts do |t|
      t.references :stat, null: false
      t.integer :entity_id, null: false
      t.string :type, null: false
      t.integer :value, null: false

      t.index [:stat_id, :entity_id, :type], unique: true
    end

    add_foreign_key :entity_counts, :stats, dependent: :delete
    add_foreign_key :entity_counts, :riot_api_static_entities, column: :entity_id, dependent: :delete

    create_table :kill_assist_counts do |t|
      t.references :stat, null: false
      t.integer :killer_id, null: false
      t.integer :assister_id, null: false
      t.integer :value, null: false

      t.index [:stat_id, :killer_id, :assister_id], unique: true, name: "index_kill_assists_counts_uniqueness"
    end

    add_foreign_key :kill_assist_counts, :stats, dependent: :delete
    add_foreign_key :kill_assist_counts, :riot_api_static_entities, column: :killer_id, dependent: :delete
    add_foreign_key :kill_assist_counts, :riot_api_static_entities, column: :assister_id, dependent: :delete

    create_table :item_purchase_counts do |t|
      t.references :stat, null: false
      t.integer :purchaser_id, null: false
      t.integer :item_id, null: false
      t.integer :value, null: false

      t.index [:stat_id, :purchaser_id, :item_id], unique: true, name: "index_item_purchase_counts_uniqueness"
    end

    add_foreign_key :item_purchase_counts, :stats, dependent: :delete
    add_foreign_key :item_purchase_counts, :riot_api_static_entities, column: :purchaser_id, dependent: :delete
    add_foreign_key :item_purchase_counts, :riot_api_static_entities, column: :item_id, dependent: :delete
  end
end
