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

class FixForeignKeys < ActiveRecord::Migration
  def change
    remove_foreign_key :entity_counts, column: :entity_id
    remove_foreign_key :entity_counts, :stats
    remove_foreign_key :item_purchase_counts, column: :item_id
    remove_foreign_key :item_purchase_counts, column: :purchaser_id
    remove_foreign_key :item_purchase_counts, :stats
    remove_foreign_key :kill_assist_counts, column: :assister_id
    remove_foreign_key :kill_assist_counts, column: :killer_id
    remove_foreign_key :kill_assist_counts, :stats

    add_foreign_key :entity_counts, :riot_api_static_entities, column: :entity_id, on_delete: :cascade
    add_foreign_key :entity_counts, :stats, on_delete: :cascade
    add_foreign_key :item_purchase_counts, :riot_api_static_entities, column: :item_id, on_delete: :cascade
    add_foreign_key :item_purchase_counts, :riot_api_static_entities, column: :purchaser_id, on_delete: :cascade
    add_foreign_key :item_purchase_counts, :stats, on_delete: :cascade
    add_foreign_key :kill_assist_counts, :riot_api_static_entities, column: :assister_id, on_delete: :cascade
    add_foreign_key :kill_assist_counts, :riot_api_static_entities, column: :killer_id, on_delete: :cascade
    add_foreign_key :kill_assist_counts, :stats, on_delete: :cascade
  end
end
