# Preview all emails at http://localhost:3000/rails/mailers/export_mailer
class ExportMailerPreview < ActionMailer::Preview
  def community_statistics
    csv = Community::Statistics.to_csv(Community.limit(100))
    ExportMailer.community_statistics("user@sqily.test", csv)
  end
end
