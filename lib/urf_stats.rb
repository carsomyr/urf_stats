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

require "riot"

module UrfStats
  CONTEST_START_TIME = DateTime.strptime("2015-03-31T22:00:00-07:00")

  REQUEST_SPACING_MILLIS = 10

  JOB_LENGTH_MILLIS = 600000

  def self.save_matches
    job_start_time = DateTime.now
    job_start_time_millis = job_start_time.strftime("%Q").to_i
    bucket_end_time = (job_start_time - 1.hour).to_time.to_i
    n_max_requests = JOB_LENGTH_MILLIS / REQUEST_SPACING_MILLIS

    request_param_tuples = ChallengeBucketCounter.all.reduce([]) do |acc, cbc|
      acc + (cbc.bucket_time.to_time.to_i...bucket_end_time).step(5.minutes).map do |time|
        [time, cbc]
      end
    end.sort do |lhs, rhs|
      lhs[0] <=> rhs[0]
    end[0, n_max_requests]

    # Read randomized 5-minute match id buckets from the challenge API.
    request_param_tuples.each do |time, cbc|
      job_current_time_millis = DateTime.now.strftime("%Q").to_i

      return \
        if job_current_time_millis - job_start_time_millis > JOB_LENGTH_MILLIS

      bucket_time = DateTime.strptime(time.to_s, "%s")
      region = cbc.region
      response = Riot::Api.client(region).api_challenge_game_ids(bucket_time)

      case response.status
        when 200
          response.body.each do |match_id|
            match = Riot::Api::Match.find_or_initialize_by(match_id: match_id, region: region)
            match.save!
          end

          cbc.bucket_time = bucket_time + 5.minutes
          cbc.save!
        when 404
          cbc.bucket_time = bucket_time + 5.minutes
          cbc.save!
        else
          # If 429 (rate limit exceeded) or anything unexpected, return immediately.
          return
      end

      sleep(REQUEST_SPACING_MILLIS / 1000.0)
    end

    # Now fill in any missing match JSON; process in small batches to prevent unbounded heap growth.
    Riot::Api::Match.where(content: nil).find_in_batches(batch_size: 10).each do |riot_api_matches|
      riot_api_matches.each do |riot_api_match|
        job_current_time_millis = DateTime.now.strftime("%Q").to_i

        return \
          if job_current_time_millis - job_start_time_millis > JOB_LENGTH_MILLIS

        response = Riot::Api.client(riot_api_match.region).match(riot_api_match.match_id)

        case response.status
          when 200
            riot_api_match.content = response.body
            riot_api_match.save!
          else
            # If 429 (rate limit exceeded) or anything unexpected, return immediately.
            return
        end

        sleep(REQUEST_SPACING_MILLIS / 1000.0)
      end
    end
  end
end
