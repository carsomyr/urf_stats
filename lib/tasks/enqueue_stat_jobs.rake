require "riot"
require "urf_stats"
require "urf_stats/workers/stat_worker"

namespace :urf_stats do
  desc "Enqueues Sidekiq jobs for computing `Stat`s"
  task enqueue_stat_jobs: :environment do
    urf_start_time = DateTime.strptime("2015-04-01T00:00:00-07:00")
    urf_end_time = DateTime.strptime("2015-04-13T00:00:00-07:00")

    (urf_start_time.to_time.to_i...urf_end_time.to_time.to_i).step(1.day).each do |time|
      start_time = DateTime.strptime(time.to_s, "%s")

      Riot::Api::REGIONS.each do |region|
        stats = Stat.arel_table
        stat = Stat.where((stats[:region].eq region).and(stats[:start_time].eq start_time)).first

        next \
          if stat

        UrfStats::Workers::StatWorker.perform_async(region, start_time.strftime("%Q").to_i, "day")
      end
    end
  end
end
