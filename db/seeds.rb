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

require "riot"
require "urf_stats"

start_time = UrfStats::CONTEST_START_TIME

ActiveRecord::Base.transaction do
  Riot::Api::REGIONS.each do |region|
    cbc = ChallengeBucketCounter.find_or_initialize_by(region: region)

    if cbc.new_record?
      cbc.bucket_time = start_time
    end

    cbc.save!
  end

  client = Riot::Api.client("na")

  client.champions.body["data"].each do |_, champion_info|
    champion = Riot::Api::Champion.find_or_initialize_by(id: champion_info["id"].to_i)
    champion.name = champion_info["name"]
    champion.image_path = champion_info["image"]["full"]
    champion.save!
  end

  client.items.body["data"].each do |_, item_info|
    item = Riot::Api::Item.find_or_initialize_by(id: item_info["id"].to_i)
    item.name = item_info["name"]
    item.image_path = item_info["image"]["full"]
    item.save!
  end

  client.masteries.body["data"].each do |_, mastery_info|
    mastery = Riot::Api::Mastery.find_or_initialize_by(id: mastery_info["id"].to_i)
    mastery.name = mastery_info["name"]
    mastery.image_path = mastery_info["image"]["full"]
    mastery.save!
  end

  client.runes.body["data"].each do |_, rune_info|
    rune = Riot::Api::Rune.find_or_initialize_by(id: rune_info["id"].to_i)
    rune.name = rune_info["name"]
    rune.image_path = rune_info["image"]["full"]
    rune.save!
  end
end
