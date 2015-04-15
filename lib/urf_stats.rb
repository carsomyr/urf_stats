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
require "urf_stats/champion_accumulator"
require "urf_stats/dto"
require "urf_stats/item_purchase_accumulator"
require "urf_stats/match_accumulator"
require "urf_stats/useless_rune_mastery_accumulator"

module UrfStats
  CONTEST_START_TIME = DateTime.strptime("2015-03-31T22:00:00-07:00")

  REQUEST_SPACING_MILLIS = 20

  JOB_LENGTH_MILLIS = 600000

  CONCURRENCY = 6

  def self.save_matches
    job_start_time = DateTime.now
    job_start_time_millis = job_start_time.strftime("%Q").to_i
    bucket_end_time = (job_start_time - 1.hour).to_time.to_i

    request_param_tuples = ChallengeBucketCounter.all.reduce([]) do |acc, cbc|
      acc + (cbc.bucket_time.to_time.to_i...bucket_end_time).step(5.minutes).map do |time|
        [time, cbc]
      end
    end.sort do |lhs, rhs|
      lhs[0] <=> rhs[0]
    end

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
          ActiveRecord::Base.transaction do
            response.body.each do |match_id|
              match = Riot::Api::Match.find_or_initialize_by(match_id: match_id, region: region)
              match.save!
            end

            cbc.bucket_time = bucket_time + 5.minutes
            cbc.save!
          end
        when 404
          cbc.bucket_time = bucket_time + 5.minutes
          cbc.save!
        else
          # If 429 (rate limit exceeded) or anything unexpected, return immediately.
          return
      end

      sleep(REQUEST_SPACING_MILLIS / 1000.0)
    end

    thread_queue = Queue.new
    CONCURRENCY.times { thread_queue.push(true) }

    # Now fill in any missing match JSON; process in small batches to prevent unbounded heap growth.
    Riot::Api::Match.where(content: nil).find_in_batches(batch_size: 3).each do |matches|
      job_current_time_millis = DateTime.now.strftime("%Q").to_i

      return \
        if job_current_time_millis - job_start_time_millis > JOB_LENGTH_MILLIS

      thread_queue.shift

      Thread.new do
        matches.each do |m|
          response = Riot::Api.client(m.region).match(m.match_id)

          case response.status
            when 200
              content = response.body

              m.content = content
              m.creation_time = DateTime.strptime(content["matchCreation"].to_s, "%Q")
              m.duration = content["matchDuration"].to_i
              m.save!
            else
              # If 429 (rate limit exceeded) or anything unexpected, return immediately.
              return
          end

          sleep(REQUEST_SPACING_MILLIS / 1000.0)
        end

        thread_queue.push(true)
      end
    end
  end

  def self.save_stat(region = "na", start_time = CONTEST_START_TIME, interval = :day)
    stats = Stat.arel_table
    stat = Stat.where((stats[:region].eq region).and(stats[:start_time].eq start_time)).first

    return \
      if stat

    acc = match_accumulator(region, start_time, interval)
    riot_api_matches = Riot::Api::Match.arel_table

    Riot::Api::Match.where(
        (riot_api_matches[:content].not_eq nil)
            .and(riot_api_matches[:region].eq region)
            .and(riot_api_matches[:creation_time].gteq start_time)
            .and(riot_api_matches[:creation_time].lt (start_time + 1.send(interval.to_s)))
    ).find_in_batches(batch_size: 8).each do |matches|
      matches.each do |match|
        acc.accumulate(match)

        Sidekiq::Logging.logger.info "Processed (match id, region) (#{match.match_id}, #{match.region}) with creation" \
          " time #{match.creation_time.to_s.dump} for the #{interval.to_s} starting at #{start_time.to_s.dump}."
      end
    end

    # Make sure that this is an all-or-nothing operation.
    ActiveRecord::Base.transaction { acc.save! }

    Sidekiq::Logging.logger.info "Saved statistics for region #{region.dump} and the #{interval.to_s} starting at" \
      " #{start_time.to_s.dump}."
  end

  def self.match_accumulator(region = "na", start_time = CONTEST_START_TIME, interval = :day)
    UrfStats::MatchAccumulator.new(region, start_time, interval) do
      children.push(UrfStats::ChampionAccumulator.new(self))
      children.push(UrfStats::ItemPurchaseAccumulator.new(self))
      children.push(UrfStats::UselessRuneMasteryAccumulator.new(self))
    end
  end
end
