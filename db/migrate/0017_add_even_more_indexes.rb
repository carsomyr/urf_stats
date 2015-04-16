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

class AddEvenMoreIndexes < ActiveRecord::Migration
  def change
    change_table :kill_assist_counts do |t|
      t.index [:killer_id, :assister_id]
    end

    change_table :item_purchase_counts do |t|
      t.index [:item_id, :purchaser_id]
    end
  end
end
