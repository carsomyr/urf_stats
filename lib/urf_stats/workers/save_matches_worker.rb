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

      PROCESS_CONCURRENCY = Rails.application.config.urf_stats["process_concurrency"]

      def perform
        UrfStats.save_matches
      end
    end
  end
end
