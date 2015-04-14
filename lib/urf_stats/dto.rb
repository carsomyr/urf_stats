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

require "urf_stats"

module UrfStats
  module Dto
    def self.events(match_json, opts = {})
      ((match_json["timeline"] || {})["frames"] || []).reduce([]) do |events, frame|
        events + (frame["events"] || []).map do |event|
          skip = opts.find do |key, value|
            value != event[key.to_s.camelize(:lower)]
          end

          if !skip
            event
          else
            nil
          end
        end.select do |event|
          !!event
        end.to_a
      end
    end

    def self.participant_frames(match_json, opts = {})
      ((match_json["timeline"] || {})["frames"] || []).reduce([]) do |participant_frame, frame|
        participant_frame + frame["participantFrames"].map do |_, participant_frame|
          skip = opts.find do |key, value|
            value != participant_frame[key.to_s.camelize(:lower)]
          end

          if !skip
            participant_frame
          else
            nil
          end
        end.select do |participant_frame|
          !!participant_frame
        end.to_a
      end
    end
  end
end
