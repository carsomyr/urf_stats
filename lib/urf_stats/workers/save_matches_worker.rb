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
    class SaveMatchesWorker
      include Sidekiq::Worker
      include Sidetiq::Schedulable

      sidekiq_options retry: false

      recurrence { secondly(UrfStats::JOB_LENGTH_MILLIS / 1000) }

      PROCESS_CONCURRENCY = 2

      def perform
        job_start_time_millis = DateTime.now.strftime("%Q").to_i
        riot_api_matches = Riot::Api::Match.arel_table

        Riot::Api::Match.select(:id)
            .where((riot_api_matches[:creation_time].eq nil).and(riot_api_matches[:content].not_eq nil))
            .find_in_batches(batch_size: 6000)
            .first(PROCESS_CONCURRENCY)
            .each do |matches|
          UrfStats::Workers::MatchCreationTimeWorker.perform_async(
              matches.first.id,
              matches.last.id,
              job_start_time_millis
          )
        end

        UrfStats.save_matches
      end
    end
  end
end
