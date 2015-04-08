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

require "riot/api/client"

module Riot
  module Api
    REGIONS = ["br", "eune", "euw", "kr", "lan", "las", "na", "oce", "tr", "ru"]

    class << self
      attr_reader :config
    end

    def self.config=(config)
      @config = config
    end

    def self.client(region = "na", options = {})
      options[:is_development] ||= false

      if options[:is_development]
        api_key = @config[:development_key]
      else
        api_key = @config[:production_key]
      end

      Riot::Api::Client.new(region, api_key, options)
    end
  end
end
