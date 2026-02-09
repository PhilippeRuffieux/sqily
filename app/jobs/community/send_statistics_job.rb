class Community::SendStatisticsJob < ApplicationJob
  queue_as :default

  def perform(email)
    csv = Community::Statistics.to_csv(Community.all)
    ExportMailer.community_statistics(email, csv).deliver_now
  end
end
