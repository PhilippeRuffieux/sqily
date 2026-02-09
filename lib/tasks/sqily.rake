namespace :sqily do
  desc "Daily tasks"
  task daily: :environment do
    RorVsWild.measure_code("DailySummaryJob.perform_now_for_all_users")
    RorVsWild.measure_code("WeeklySummaryJob.perform_for_all_membeships") if Date.today.wday == 1
  end

  desc "Hourly tasks"
  task hourly: :environment do
    RorVsWild.measure_code("Badge::Omnipresent.trigger_for_last_24h")
    RorVsWild.measure_code("Notification::PollFinished.trigger_for_last_24h")
  end

  desc "Update crontab via whenever"
  task :update_crontab do
    `bundle exec whenever --update-crontab`
  end

  desc "Called after deployment"
  task :after_deploy do
    Rake::Task["db:migrate"].invoke
    Rake::Task["assets:precompile"].invoke
    Rake::Task["sqily:update_crontab"].invoke
    Rake::Task["tolk:sync"].invoke
  end
end
