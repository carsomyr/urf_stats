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

require "spec_helper"
require "urf_stats"

describe UrfStats do
  context Riot::Api::Match do
    fixtures "riot/api/match"

    it "verifies the existence of fixtures" do
      matches = Riot::Api::Match.all

      expect(matches).not_to be_empty

      matches.each do |match|
        expect(match.creation_time).not_to be_nil
        expect(match.duration).not_to be_nil
        expect(match.content).not_to be_nil
      end
    end
  end
end
