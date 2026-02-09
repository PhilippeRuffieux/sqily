class ExportMailer < ApplicationMailer
  def community_statistics(email, csv)
    attachments["Statistiques des communautés.csv"] = {mime_type: "text/csv", content: csv}
    mail(subject: "Statistiques des communautés", to: email, body: "")
  end
end
