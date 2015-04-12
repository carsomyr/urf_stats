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
  module Workers
    class MatchCreationTimeWorker
      include Sidekiq::Worker

      CONCURRENCY = 4

      sidekiq_options queue: :worker, retry: false

      def perform(lower_id, upper_id, job_start_time_millis)
        riot_api_matches = Riot::Api::Match.arel_table

        thread_queue = Queue.new
        CONCURRENCY.times { thread_queue.push(true) }

        # Fill in any missing creation time and duration; process in small batches to prevent unbounded heap growth.
        Riot::Api::Match.where(
            (riot_api_matches[:creation_time].eq nil)
                .and(riot_api_matches[:id].gteq lower_id)
                .and(riot_api_matches[:id].lteq upper_id)
        ).find_in_batches(batch_size: 3).each do |matches|
          job_current_time_millis = DateTime.now.strftime("%Q").to_i

          return \
            if job_current_time_millis - job_start_time_millis > UrfStats::JOB_LENGTH_MILLIS

          thread_queue.shift

          Thread.new do
            matches.each do |m|
              content = m.content
              m.creation_time = DateTime.strptime(content["matchCreation"].to_s, "%Q")
              m.duration = content["matchDuration"].to_i
              m.save!

              Sidekiq::Logging.logger.info "Processed (match id, region) (#{m.match_id}, #{m.region})" \
                " with creation time #{m.creation_time.to_s.dump} and duration #{m.duration} seconds."
            end

            thread_queue.push(true)
          end
        end
      end
    end
  end
end
