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

require "date"
require "faraday"
require "time"

module Riot
  module Api
    class Client
      attr_reader :region
      attr_reader :key

      def initialize(region, key, options = {})
        options[:log_level] ||= :info

        @region = region
        @key = key
        @connection = Faraday.new(url: "https://#{region}.api.pvp.net") do |faraday|
          logger = Logger.new(STDOUT)
          logger.level = Logger.const_get(options[:log_level].to_s.upcase)

          faraday.request :json
          faraday.response :logger, logger
          faraday.response :json, content_type: Regexp.new("\\bjson$")
          faraday.adapter Faraday.default_adapter
        end
      end

      def match(id)
        @connection.get(
            "/api/lol/#{@region}/v2.2/match/#{id}",
            {
                "api_key" => @key,
                "includeTimeline" => true
            }
        )
      end

      def api_challenge_game_ids(begin_date = to_nearest_5_minutes(DateTime.now))
        @connection.get(
            "/api/lol/#{@region}/v4.1/game/ids",
            {
                "api_key" => @key,
                "beginDate" => to_epoch(begin_date)
            }
        )
      end

      def to_nearest_5_minutes(date_time)
        date_time - (to_epoch(date_time) % 300).seconds
      end

      def to_epoch(date_time)
        case date_time
          when DateTime, Date
            date_time.to_time.to_i
          when Time
            date_time.to_i
          else
            raise "Invalid object class #{date_time.class.name}"
        end
      end
    end
  end
end
