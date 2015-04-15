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

require "ice_cube/rule"

# Are we running in the Sidekiq process?
if Sidekiq.server?
  # Monkey patch IceCube so that Sidetiq doesn't go haywire.
  module IceCube
    class Rule
      def full_required?
        !@count.nil?
      end
    end
  end

  Sidekiq.configure_server do |config|
    config.error_handlers.push(
        Proc.new do |exception, context|
          Airbrake.notify_or_ignore(exception, parameters: context)
        end
    )

    # Hardcode the polling interval to 15 seconds. If we don't do this, Sidekiq will dynamically adjust it to the number
    # of workers, which may then depend on the number of cores on the host machine.
    config.poll_interval = 15
  end

  if !Sidekiq.options[:queues].include?("worker")
    require "urf_stats/workers/save_matches_worker"
  end

  require "urf_stats/workers/stat_worker"
end
