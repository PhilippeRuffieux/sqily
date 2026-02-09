class HomeworksToEvaluationsMigration
  def migrate
    Evaluation.where.not(file_node: nil).find_each(&method(:migrate_evaluation))
    Homework.where.not(file_node: nil).order(:created_at).find_each(&method(:migrate_homework))
  end

  private

  def migrate_evaluation(evaluation)
    if image?(evaluation.file_node)
      evaluation.update!(description: to_image(evaluation))
    else
      evaluation.update!(description: to_file_attachment(evaluation))
    end
  end

  def migrate_homework(homework)
    content = if image?(homework.file_node)
      to_image(homework)
    else
      to_file_attachment(homework)
    end

    if (exam = Evaluation::Exam.on_going_exam(homework.subscription.user, homework.subscription.skill))
      Evaluation::Note.create!(content: content, user: homework.subscription.user, exam: exam, created_at: homework.created_at)
    elsif (exam = homework.evaluation.start(homework.subscription, content))
      exam.notes.first.update(created_at: homework.created_at)
    else
      warn("failed to migration homework ##{homework.id}")
    end

    exam&.update!(created_at: homework.created_at)

    if exam && (message = Message::HomeworkUploaded.where(homework: homework).first)
      text = message.text? ? message.text : "-"
      Evaluation::Note.create!(content: text, user: homework.evaluation.user, exam: exam, is_accepted: homework.approved_at?, is_rejected: homework.rejected_at?,
        created_at: homework.approved_at || homework.rejected_at || homework.created_at)
    end
  end

  def image?(file_node)
    %w[.apng .avif .gif .jpg .jpeg .jfif .pjpeg .pjp .png .svg .webp].include?(File.extname(file_node.downcase))
  end

  def to_file_attachment(model)
    extension = File.extname(model.file_name)
    attachment = {
      contentType: content_type = extension_to_content_type(extension),
      filename: filename = model.file_name,
      filesize: "",
      href: model.file_url,
      url: url = model.file_url
    }

    html = <<-HTML
      <div>
        <figure data-trix-attachment="#{h(attachment.to_json)}" data-trix-content-type="#{h(content_type)}" class="attachment attachment--file attachment--#{h(extension[1..])}">
          <a href="#{h(url)}">
            <figcaption class="attachment__caption"><span class="attachment__name">#{h(filename)}</span></figcaption>
          </a>
        </figure>
      </div>
    HTML
    html.delete("\n")
  end

  def to_image(model)
    extension = File.extname(model.file_name)
    attachment = {
      contentType: content_type = extension_to_content_type(extension),
      filename: filename = model.file_name,
      filesize: "",
      href: model.file_url,
      url: url = model.file_url,
      height: "",
      width: ""
    }

    html = <<-HTML
      <div>
        <a href="#{h(url)}" data-trix-attachment="#{h(attachment.to_json)}" data-trix-content-type="#{h(content_type)}">
          <figure class="attachment attachment-preview attachment--#{h(extension[1..])}">
            <img src="#{h(url)}" width="" height="">
            <figcaption class="caption">#{h(filename)} <span class="size"></span></figcaption>
          </figure>
        </a>
      </div>
    HTML
    html.delete("\n")
  end

  def h(string)
    CGI.escapeHTML(string.to_s)
  end

  def extension_to_content_type(extension)
    extension = extension[1..] if extension[0] == "."
    {
      "txt" => "text/plain",
      "csv" => "text/csv",
      "html" => "text/html",
      "htm" => "text/html",
      "css" => "text/css",
      "rtf" => "text/rtf",
      "py" => "text/x-python",
      "rb" => "application/x-ruby",

      # Images
      "jpg" => "image/jpeg",
      "jpeg" => "image/jpeg",
      "png" => "image/png",
      "pn_g" => "image/png",
      "gif" => "image/gif",
      "tiff" => "image/tiff",
      "svg" => "image/svg+xml",
      "bmp" => "image/bmp",

      "psd" => "image/x-photoshop",

      # PHP
      "php" => "application/x-httpd-php",
      "phps" => "application/x-httpd-php-source",
      "php3" => "application/x-httpd-php3",
      "php3p" => "application/x-httpd-php3-preprocessed",
      "php4" => "application/x-httpd-php4",
      "php5" => "application/x-httpd-php5",

      # Video
      "mp3" => "audio/mp3",
      "aif" => "audio/x-aiff",
      "aiff" => "audio/x-aiff",
      "mp4" => "video/mp4",
      "m4v" => "video/mp4",
      "mov" => "video/quicktime",
      "flv" => "video/x-flv",
      "webm" => "video/webm",

      # Archives
      "zip" => "application/zip",
      "rar" => "application/rar",
      "7z" => "application/x-7z-compressed",
      "jar" => "application/java-archive",

      # PGP
      "pgp" => "application/pgp-encrypted",
      "key" => "application/pgp-keys",
      "sig" => "application/pgp-signature",

      "pdf" => "application/pdf",
      "ps" => "application/postscript",
      "stl" => "application/sla",
      "epub" => "application/epub+zip",

      "pages" => "application/pages",
      "numbers" => "application/numbers",
      "dmg" => "application/x-apple-diskimage",

      # MS office
      "doc" => "application/msword",
      "dot" => "application/msword",
      "xls" => "application/vnd.ms-excel",
      "xlt" => "application/vnd.ms-excel",
      "xla" => "application/vnd.ms-excel",
      "ppt" => "application/vnd.ms-powerpoint",
      "pot" => "application/vnd.ms-powerpoint",
      "pps" => "application/vnd.ms-powerpoint",
      "ppa" => "application/vnd.ms-powerpoint",
      "mdb" => "application/vnd.ms-access",

      # Open document
      "odc" => "application/vnd.oasis.opendocument.chart",
      "odb" => "application/vnd.oasis.opendocument.database",
      "odf" => "application/vnd.oasis.opendocument.formula",
      "odg" => "application/vnd.oasis.opendocument.graphics",
      "otg" => "application/vnd.oasis.opendocument.graphics-template",
      "odi" => "application/vnd.oasis.opendocument.image",
      "odp" => "application/vnd.oasis.opendocument.presentation",
      "otp" => "application/vnd.oasis.opendocument.presentation-template",
      "ods" => "application/vnd.oasis.opendocument.spreadsheet",
      "ots" => "application/vnd.oasis.opendocument.spreadsheet-template",
      "odt" => "application/vnd.oasis.opendocument.text",
      "odm" => "application/vnd.oasis.opendocument.text-master",
      "ott" => "application/vnd.oasis.opendocument.text-template",
      "oth" => "application/vnd.oasis.opendocument.text-web",

      # Open XML
      "pptx" => "application/vnd.openxmlformats-officedocument.presentationml.presentation",
      "sldx" => "application/vnd.openxmlformats-officedocument.presentationml.slide",
      "ppsx" => "application/vnd.openxmlformats-officedocument.presentationml.slideshow",
      "potx" => "application/vnd.openxmlformats-officedocument.presentationml.template",
      "xlsx" => "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
      "xltx" => "application/vnd.openxmlformats-officedocument.spreadsheetml.template",
      "docx" => "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
      "dotx" => "application/vnd.openxmlformats-officedocument.wordprocessingml.template",

      # Unknow
      "comiclife" => "application/octet-stream",
      "ggb" => "application/octet-stream",
      "webloc" => "application/octet-stream"
    }[extension.downcase]
  end
end
